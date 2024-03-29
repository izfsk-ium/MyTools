(* Write a function last : 'a list -> 'a option that returns the last element of a list *)
let last list = 
  let rec _last target = function
    | [] -> target
    | h :: t -> _last h t
in
  _last (List.nth list 0) list;;

(assert (last [1;2;3;4;5] = 5));;

let rec last = function
  | [] -> None
  | [ e ] -> Some e
  | h :: t -> last t;;

(assert (last [1;2;3;4] = Some 4));;

(* Find the last but one (last and penultimate) elements of a list. *)

let rec last_two = function
  | [] -> None
  | [ e ] -> None
  | [x; y] -> Some (x,y)
  | h :: t -> last_two t;;

(assert (last_two [1;2;3] = Some (2,3)));;
(assert (last_two [1] = None));;

(* Find the N'th element of a list. *)
let rec nth target = function
  | [] -> failwith "Error"
  | h :: t -> if target = 0 then h else nth (target - 1) t;;

(assert (nth 2 [1;2;3;4;5] = 3));;

(* Find the number of elements of a list. *)

let len list = 
  let rec _len length = function
    | [] -> length
    | h :: t -> _len (length + 1) t
in
  _len 0 list;;

let long_list = List.init 1000000 (fun (x) -> x);;
assert(len long_list = 1000000);;

(* Reverse a list. *)
let reverse list = 
  let rec _reverse final = function
    | [] -> final
    | h :: t -> _reverse (h :: final) t
in
  _reverse [] list;;

assert(reverse [1;2;3] = [3;2;1]);;

(* Find out whether a list is a palindrome. *)

let is_palindrome list = list = reverse list;;

assert(is_palindrome [1;2;3;2;1]=true);;
assert(is_palindrome [1;2;3]=false);;