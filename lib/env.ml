let get key =
  try Sys.getenv key with Not_found -> failwith (Printf.sprintf "Environment variable $%s is not set" key)
;;
