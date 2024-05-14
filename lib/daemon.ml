open Relic_sdk
open Lwt.Syntax

let rec tick client () =
  let start_time = Unix.gettimeofday () in
  let* matches, avatars = Fetch.advertisements client in
  let* _ = Process.advertisements matches avatars in
  let* _ = Lwt_unix.sleep 4.0 in
  let end_time = Unix.gettimeofday () in
  let* _ =
    Logger.Async.debug ~m:"Daemon" ~f:"tick" "Took %d ms" (int_of_float @@ ((end_time -. start_time) *. 1000.0))
  in
  tick client ()
;;

let run domain game =
  let client = Client.create domain game in
  let* db_version = Migration.get_current_version () in
  let* _ =
    Logger.Async.info
      ~m:"Daemon"
      ~f:"main"
      "Launching with config domain:%s game:%s db:%d"
      domain
      (Data.Game.to_str game)
      (match db_version with Some i -> i | None -> 0)
  in
  let* migration_result = Migration.upgrade "./migrations" in
  match migration_result with Ok () -> tick client () | Error _ -> Lwt.return_unit
;;
