open Sqlite3
open Lwt.Syntax

let db_path = Env.get "DB_PATH"
let db_handle = db_open db_path

let init () =
  let* result =
    Lwt_preemptive.detach
      (fun () ->
        match
          exec
            db_handle
            "CREATE TABLE IF NOT EXISTS players (id TEXT PRIMARY KEY, profile_id INT UNIQUE, name TEXT UNIQUE, \
             steam_id TEXT UNIQUE, xbox_id TEXT)"
        with
        | Rc.OK -> true
        | _ -> false)
      ()
  in
  Lwt.return result
;;

let create_player profile_id platform platform_id name country_code =
  let _ =
    Lwt_preemptive.detach
      (fun () ->
        let stmt =
          prepare
            db_handle
            "INSERT INTO players (id, profile_id, name, steam_id, xbox_id, country_code) VALUES (?, ?, ?, ?, ?, ?)"
        in
        bind_text stmt 1 (Uuidm.v `V4 |> Uuidm.to_string) |> ignore;
        bind_int stmt 2 profile_id |> ignore;
        bind_text stmt 3 name |> ignore;
        match platform with
        | `Steam -> bind_text stmt 4 platform_id |> ignore
        | `Xbox ->
          bind_text stmt 5 platform_id |> ignore;
          bind_text stmt 6 country_code |> ignore;
          ignore (step stmt))
      ()
  in
  Lwt.return_unit
;;

let player_exists_by_id id =
  let* result =
    Lwt_preemptive.detach
      (fun () ->
        let stmt = prepare db_handle "SELECT COUNT(*) FROM players WHERE id = ?" in
        bind_text stmt 1 id |> ignore;
        match step stmt with
        | Rc.ROW ->
          let count = column_int stmt 0 in
          count > 0
        | _ -> false)
      ()
  in
  Lwt.return result
;;

let player_exists_by_profile_id profile_id =
  let* result =
    Lwt_preemptive.detach
      (fun () ->
        let stmt = prepare db_handle "SELECT COUNT(*) FROM players WHERE profile_id = ?" in
        bind_int stmt 1 profile_id |> ignore;
        match step stmt with
        | Rc.ROW ->
          let count = column_int stmt 0 in
          count > 0
        | _ -> false)
      ()
  in
  Lwt.return result
;;

let player_exists ?id ?profile_id () =
  match id, profile_id with
  | Some id, None -> player_exists_by_id id
  | None, Some profile_id -> player_exists_by_profile_id profile_id
  | _ -> failwith "Invalid arguments: provide either 'id' or 'profile_id', but not both"
;;
