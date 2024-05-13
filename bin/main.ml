open Relic_sdk
open Relic_store_lib

let () =
  let domain = Env.get "RELIC_LINK_DOMAIN" in
  let game = Data.Game.Age2 in
  Lwt_main.run @@ Daemon.run domain game
;;
