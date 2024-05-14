open Relic_store_lib
open Lwt.Syntax

let test_migrations migrations_folder =
  (* Setup a temporary database path *)
  let temp_db_path = Filename.temp_file "test_migrations" ".sqlite" in
  (* Override the DB_PATH environment variable for testing *)
  Unix.putenv "DB_PATH" temp_db_path;
  Lwt.finalize
    (fun () ->
      let* _ = Migration.upgrade migrations_folder in
      let* current_version = Migration.get_current_version () in
      let* () =
        match current_version with
        | Some v ->
          Alcotest.(check int) "Upgraded to latest version" 2 v;
          Lwt.return_unit
        | None -> Lwt.fail_with "Failed to get current version"
      in
      let* _ = Migration.downgrade migrations_folder in
      let* current_version = Migration.get_current_version () in
      match current_version with
      | Some v ->
        Alcotest.(check int) "Downgraded to initial version" 0 v;
        Lwt.return_unit
      | None -> Lwt.fail_with "Failed to get current version")
    (fun () -> Lwt_unix.unlink temp_db_path)
;;
