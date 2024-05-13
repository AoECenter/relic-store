let int_of_string_verbose (s : string) : int =
  try int_of_string s with
  | Failure _ ->
    let msg = "Unable to convert string '" ^ s ^ "' to an integer" in
    failwith msg
;;
