open Relic_sdk
open Lwt.Syntax

let match_member avatars (match_member : Models.Stub.Match_member.t) =
  let open Models.Stub.Avatar in
  match List.find_opt (fun avatar -> avatar.profile_id = match_member.profile_id) avatars with
  | Some avatar ->
    (match Parser.Platform_id.from_str avatar.name with
     | Some (platform, platform_id) ->
       let* _ = Database.create_player match_member.profile_id platform platform_id avatar.alias avatar.country in
       Lwt.return_unit
     | None ->
       let* _ =
         Logger.Async.warn
           ~m:"Store"
           ~f:"match_member"
           "Warning: Invalid platform_id format for avatar with profile_id: %d: %s\n"
           match_member.profile_id
           avatar.name
       in
       Lwt.return_unit)
  | None -> Lwt.return_unit
;;
