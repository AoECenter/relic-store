open Relic_sdk
open Lwt.Syntax

let advertisements (matches : Models.Stub.Advertisement.t list) (avatars : Models.Stub.Avatar.t list) =
  let open Models.Stub.Advertisement in
  let all_match_members = List.concat (List.map (fun match_ -> match_.matchmembers) matches) in
  let* _ = Lwt_list.iter_s (Store.match_member avatars) all_match_members in
  let* _ = Lwt_io.printf "[Process:advertisements] Updated %d players\n" (List.length all_match_members) in
  Lwt.return_unit
;;
