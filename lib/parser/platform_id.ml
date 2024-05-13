let from_str id_str =
  try
    let steam_regex = Str.regexp "/steam/\\([0-9]+\\)" in
    let xbox_regex = Str.regexp "/xboxlive/\\([A-F0-9]+\\)" in
    if Str.string_match steam_regex id_str 0
    then Some (`Steam, Str.matched_group 1 id_str)
    else if Str.string_match xbox_regex id_str 0
    then Some (`Xbox, Str.matched_group 1 id_str)
    else None
  with
  | Not_found ->
    Printf.printf "Error: ID not found in string: %s\n" id_str;
    None
  | ex ->
    Printf.printf "Error extracting ID: %s\n" (Printexc.to_string ex);
    None
;;
