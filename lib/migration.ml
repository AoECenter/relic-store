open Lwt.Syntax
open Lwt_preemptive
open Sqlite3

let exec_query query = detach (fun () -> match exec Database.db_handle query with Rc.OK -> Some () | _ -> None) ()

let exec_prepared stmt params =
  detach
    (fun () ->
      List.iteri (fun i param -> bind_text stmt (i + 1) param |> ignore) params;
      match step stmt with Rc.DONE -> Some () | _ -> None)
    ()
;;

let ensure_migrations_table () = exec_query "CREATE TABLE IF NOT EXISTS migrations (version INTEGER PRIMARY KEY)"

let get_current_version () =
  let* _ = ensure_migrations_table () in
  detach
    (fun () ->
      let stmt = prepare Database.db_handle "SELECT version FROM migrations ORDER BY version DESC LIMIT 1" in
      match step stmt with Rc.ROW -> Some (column_int stmt 0) | _ -> None)
    ()
;;

let set_version version =
  let stmt = prepare Database.db_handle "INSERT INTO migrations (version) VALUES (?)" in
  exec_prepared stmt [ string_of_int version ]
;;

let read_sql_file path = Lwt_io.with_file ~mode:Lwt_io.input path Lwt_io.read

let apply_migration file_path version up =
  let* sql = read_sql_file file_path in
  let* _ = exec_query sql in
  let* _ = Lwt_io.printf "[Migration::apply_migration] Applied migration %s\n" file_path in
  if up then set_version version else set_version (version - 1)
;;

let backup_db () =
  let backup_path = Database.db_path ^ ".bak" in
  Lwt_unix.system ("cp " ^ Database.db_path ^ " " ^ backup_path) |> ignore
;;

let restore_backup () = Lwt_unix.system ("mv " ^ Database.db_path ^ ".bak " ^ Database.db_path) |> ignore

let upgrade migrations_folder =
  Lwt.catch
    (fun () ->
      let* _ = ensure_migrations_table () in
      let* current_version = get_current_version () in
      let start_version = match current_version with Some v -> v + 1 | None -> 1 in
      let* files = Lwt_unix.files_of_directory migrations_folder |> Lwt_stream.to_list in
      let* migration_files =
        Lwt_list.filter_s
          (fun file ->
            if Filename.check_suffix file ".up.sql"
            then (
              let file_version_str = Filename.chop_suffix (Filename.basename file) ".up.sql" in
              let* file_version = Lwt.return (Core.int_of_string_verbose file_version_str) in
              Lwt.return (file_version >= start_version))
            else Lwt.return_false)
          files
      in
      let sorted_files =
        List.sort
          (fun a b ->
            let version_a = Core.int_of_string_verbose (Filename.chop_suffix (Filename.basename a) ".up.sql") in
            let version_b = Core.int_of_string_verbose (Filename.chop_suffix (Filename.basename b) ".up.sql") in
            compare version_a version_b)
          migration_files
      in
      Lwt_list.iter_s
        (fun file_path ->
          let version = Core.int_of_string_verbose (Filename.chop_suffix (Filename.basename file_path) ".up.sql") in
          let* _ = apply_migration (migrations_folder ^ "/" ^ file_path) version true in
          Lwt.return_unit)
        sorted_files
      |> Lwt.map (fun () -> Ok ()))
    (fun e ->
      let error_msg = Printexc.to_string e in
      let* () = Lwt_io.printf "Failed to apply migrations: %s\n" error_msg in
      Lwt.return (Error (error_msg : string) : (unit, string) result))
;;

let downgrade migrations_folder =
  let* _ = ensure_migrations_table () in
  let* current_version = get_current_version () in
  match current_version with
  | Some v when v > 0 ->
    let file_path = migrations_folder ^ Printf.sprintf "/%04d-init.dn.sql" v in
    apply_migration file_path v false
  | _ -> Lwt.return @@ Some ()
;;
