open Lwt.Syntax

(* open Relic_sdk *)

module type DBCONF = sig
  val db_path : string
end

module UnconfiguredDatabase (Config : DBCONF) = struct
    open Sqlite3
    let db_handle = db_open Config.db_path
    let init () = 
        let* result = Lwt_preemptive.detach (fun () ->
            match exec db_handle "CREATE TABLE IF NOT EXISTS players (id TEXT PRIMARY KEY, aoe_id INT, name TEXT)" with
            | Rc.OK -> true
            | _ -> false
        ) () in
        Lwt.return result
    ;;
    let create_player aoe_id name =
      let* result =
        Lwt_preemptive.detach (fun () ->
            let stmt = prepare db_handle "INSERT INTO players (id, aoe_id, name) VALUES (?, ?, ?)" in
            bind_text stmt 1 (Uuidm.v `V4 |> Uuidm.to_string) |> ignore;
            bind_int stmt 2 aoe_id |> ignore;
            bind_text stmt 3 name |> ignore;
            match step stmt with
            | Rc.DONE -> true
            | _ -> false
          )
          ()
      in
      Lwt.return result
    ;;
end

let get_env key =
  try Sys.getenv key with Not_found -> failwith (Printf.sprintf "Environment variable $%s is not set" key)
;;

let main () = 
    let db_path = get_env "DB_PATH" in
    let module Database = UnconfiguredDatabase(struct
      let db_path = db_path
    end) in
    let* _ = Database.init () in
    let* _ = Database.create_player 14 "ges" in
    Lwt.return_unit
    

let () =
 Lwt_main.run @@ main ()
