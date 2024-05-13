open Relic_sdk
open Lwt.Syntax

let rec tick client () =
  let start_time = Unix.gettimeofday () in
  let* matches, avatars = Fetch.advertisements client in
  let* _ = Process.advertisements matches avatars in
  let* _ = Lwt_unix.sleep 4.0 in
  let end_time = Unix.gettimeofday () in
  let* _ = Lwt_io.printf "[Daemon::tick] Tick took %d ms\n" (int_of_float @@ ((end_time -. start_time) *. 1000.0)) in
  tick client ()
;;

let run () =
  let domain = Env.get "RELIC_LINK_DOMAIN" in
  let game = Data.Game.Age2 in
  let client = Client.create domain game in
  let* db_version = Migration.get_current_version () in
  let* _ =
    Lwt_io.printf
      "[Daemon::main] Launching with config\n\
      \       * Domain: %s\n\
      \       * Game: %s\n\
      \       * Database iteration: %04d\n"
      domain
      (Data.Game.to_str game)
      (match db_version with Some i -> i | None -> 0)
  in
  let* migration_result = Migration.upgrade "./migrations" in
  match migration_result with Ok () -> tick client () | Error _ -> Lwt.return_unit
;;
