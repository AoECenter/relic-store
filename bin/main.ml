open Relic_store_lib

let () = Lwt_main.run @@ Daemon.run ()
