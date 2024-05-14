open Alcotest_lwt
open Lwt.Syntax

let () =
  Lwt_main.run
  @@
  let suite = [ "Database", [ test_case "Migration" `Slow @@ Test_case.Migration.test_migrations "migrations" ] ] in
  Alcotest_lwt.run "Relic Store" suite
;;
