type t =
  | DEBUG
  | INFO
  | WARN
  | ERROR

let to_string = function DEBUG -> "DEBUG" | INFO -> "INFO" | WARN -> "WARN" | ERROR -> "ERROR"

let to_color = function
  | DEBUG -> "\x1b[36m" (* Cyan *)
  | INFO -> "\x1b[32m" (* Green *)
  | WARN -> "\x1b[33m" (* Yellow *)
  | ERROR -> "\x1b[31m" (* Red *)
;;

let reset_color = "\x1b[0m"
