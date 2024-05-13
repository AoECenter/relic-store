open Relic_sdk
open Lwt.Syntax

let rec advertisements ?(idx = 0) ?(matches_list = []) ?(avatars_list = []) client =
  let count = 100 in
  let endpoint = Api.Community.Advertisement.get ~start:idx ~count in
  let* match_block = Client.get endpoint client in
  match match_block with
  | Some match_block ->
    let matches = match_block.matches in
    let avatars = match_block.avatars in
    let new_matches_list = matches @ matches_list in
    let new_avatars_list = avatars @ avatars_list in
    if List.length matches < count
    then Lwt.return (new_matches_list, new_avatars_list)
    else (
      let new_idx = idx + List.length matches in
      advertisements ~idx:new_idx ~matches_list:new_matches_list ~avatars_list:new_avatars_list client)
  | None -> Lwt.return (matches_list, avatars_list)
;;
