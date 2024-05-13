open Relic_sdk
open Lwt.Syntax

let rec daemon_tick client () =
  let start_time = Unix.gettimeofday () in
  let* matches, avatars = Fetch.advertisements client in
  let* _ = Process.advertisements matches avatars in
  let* _ = Lwt_unix.sleep 4.0 in
  let end_time = Unix.gettimeofday () in
  let* _ = Lwt_io.printf "[daemon_tick] Tick took %d ms\n" (int_of_float @@ ((end_time -. start_time) *. 1000.0)) in
  daemon_tick client ()
;;

let run () =
  let domain = Env.get "RELIC_LINK_DOMAIN" in
  let game = Data.Game.Age2 in
  let client = Client.create domain game in
  let* _ =
    Lwt_io.printf
      "[Daemon::main] Launching with config\n       * Domain: %s\n       * Game: %s\n"
      domain
      (Data.Game.to_str game)
  in
  let* _ = Lwt_io.printf "" in
  let* _ = Database.init () in
  let* _ = Database.player_exists ~profile_id:14 () in
  daemon_tick client ()
;;
