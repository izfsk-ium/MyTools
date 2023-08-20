let safe_div x y =
  try x / y with
  | Division_by_zero -> 0;;

assert( safe_div 0 0 = 0);;
assert( safe_div 1 0 = 0);;

type 'a tree =
  | Leaf 
  | Node of 'a * 'a tree * 'a tree;;

let my_tree = Node(4,
  Node(2,
    Node(1, Leaf, Leaf),
    Node(3, Leaf, Leaf)
  ),
  Node(5,
    Node(6, Leaf, Leaf),
    Node(7, Leaf, Leaf)
  )
);;

let rec tree_size  = function
  | Leaf -> 0
  | Node (_, left, right) -> 1 + tree_size left + tree_size right;;

let rec sum = function
  | Leaf -> 0
  | Node (value, left, right) -> value + sum left + sum right;;

let rec search target = function
  | Leaf -> false
  | Node (value, left, right) -> target = value || search target left || search target right;;

print_endline (string_of_int (sum my_tree));;

(* execises *)

(* Write a function that returns the product of all the elements in a list. 
   The product of all the elements of an empty list is 1.*)

let product list = 
  let rec _product result = function
    | [] -> result
    | h :: t -> _product (result * h) t
in
  _product 1 list;;

assert (product [1;2;3] = 6);;
assert (product [] = 1);;
assert (product [2;4;6;8;9] = 3456);;

(* Write a function that concatenates all the strings in a list.
   The concatenation of all the strings in an empty list is the empty string "".*)

let concat list = 
  let rec _concat result = function
    | [] -> result
    | h :: t -> _concat (result ^ h) t
in
  _concat "" list;;

assert (concat ["hello"; "world"] = "helloworld");;
assert (concat [] = "");;

(* Using pattern matching, write three functions, one for each of the following properties.
   Your functions should return true if the input list has the property and false otherwise.
      the list’s first element is "bigred"
      the list has exactly two or four elements; do not use the length function
      the first two elements of the list are equal
*)

let first_is = function
  | [] -> false
  | h :: t -> h = "bigred";;

assert (first_is ["bigred"] = true);;
assert (first_is ["sss"; "bigred"] = false);;

let length_is_two_or_four list = 
  let rec length result = function
    | [] -> result
    | h :: t -> length (1 + result) t
in
  length 0 list = 2 || length 0 list = 4;;

assert (length_is_two_or_four [] == false);;
assert (length_is_two_or_four [1;2] == true);;
assert (length_is_two_or_four [1;4;7;9] == true);;
assert (length_is_two_or_four [1] == false);;

let first_two_equal = function
  | a :: b :: _ -> a = b
  | _ -> false;;

assert (first_two_equal [1;3]=false);;
assert (first_two_equal [1;1]=true);;

(* Consult the List standard library to solve these exercises:
    Write a function that takes an int list and returns the fifth element of that list, if such an element exists.
       If the list has fewer than five elements, return 0.
       Hint: List.length and List.nth.
    Write a function that takes an int list and returns the list sorted in descending order.
       Hint: List.sort with Stdlib.compare as its first argument, and List.rev.
*)

let get_fifth_elem list = 
 if List.length list <= 5 then 0 
 else List.nth list 4;;

assert (get_fifth_elem [1;2;3;4;5;6;7;8] = 5);;
assert (get_fifth_elem [1;2] = 0);;

let sorted_list list = 
  List.sort Stdlib.compare list;;

assert (sorted_list [1;9;3;0] = [0;1;3;9]);;

(* 
  Write a function that returns the last element of a list
    Your function may assume that the list is non-empty.
    Hint: Use two library functions, and do not write any pattern matching code of your own.

  Write a function any_zeroes : int list -> bool that returns true if and only if the input list contains at least one 0.
    Hint: use one library function, and do not write any pattern matching code of your own.

  Your solutions will be only one or two lines of code each.
*)

let last_element_of_list list =
  List.nth (List.rev list) 0;;

assert (last_element_of_list [1;2;3;4;5] = 5);;

let any_zeros list =
  let eq_zero a = a = 0
in
  List.exists eq_zero list;;

assert (any_zeros [1;2;3;7;5] = false);;
assert (any_zeros [2;7;4;0;0] = true);;

(*
    Write a function take : int -> 'a list -> 'a list such that take n lst returns the first n elements of lst.
     If lst has fewer than n elements, return all of them.

    Write a function drop : int -> 'a list -> 'a list such that drop n lst returns all but the first n elements of lst.
     If lst has fewer than n elements, return the empty list.
*)

let take list num = 
  let rec _take result _list _num = 
    match _num with
    | 0 -> result
    | _ -> begin
      match _list with
      | [] -> result
      | h :: t -> h :: _take result t (_num - 1)
    end
  in
    _take [] list num;;

let rec take_n list num = 
  if num = 0 then [] else match list with
  | [] -> []
  | h :: t -> h :: take_n t (num - 1);;

assert (take_n [1;2;3;4;5] 3 = [1;2;3]);;
assert (take [1;2;3;4;5] 3 = [1;2;3]);;

let rec drop num list = 
  if num = 0 then list else match list with
  | [] -> [] 
  | h :: t -> drop (num - 1) t;;

assert (drop 2 [1;2;3;4;5;6] = [3;4;5;6]);;

(* Revise your solutions for take and drop to be tail recursive, if they aren’t already.
   Test them on long lists with large values of n to see whether they run out of stack space.
   To construct long lists, use the -- operator from the lists section.
   TODO
*)

let very_long_list = let gen x = x in List.init 30000 gen;;

(* Write a function is_unimodal : int list -> bool that takes an integer list and returns whether that list is unimodal.
    A unimodal list is a list that monotonically increases to some maximum value then monotonically decreases after that value.
    Either or both segments (increasing or decreasing) may be empty. A constant list is unimodal, as is the empty list.*)

let rec is_mon_decrease = function
  | [] | [_] -> true
  | a :: (b :: tail) -> a > b && is_mon_decrease tail;;

let rec is_unimodal = function
  | [] | [_] -> true
  | a :: (b :: tail) -> if a < b then is_unimodal tail else is_mon_decrease tail;;

(* Write a function powerset : int list -> int list list that takes a set S represented as a list and returns the set of all subsets of S.
   The order of subsets in the powerset and the order of elements in the subsets do not matter.

   Hint: Consider the recursive structure of this problem.
   Suppose you already have p, such that p = powerset s. How could you use p to compute powerset (x :: s)? 
*)

let rec print_int_list = function
  | [] -> ()
  | h :: t -> print_endline(string_of_int h) ; print_int_list t;;

print_int_list([1;2;3;4;5]);;

print_endline("\n");;

let print_int_list' lst =
  List.iter (fun x -> print_endline (string_of_int x)) lst;;

print_int_list'([1;2;3;4;5]);;

(* we are given this type *)
type student = { first_name : string ; last_name : string ; gpa : float };;

(* expression with type [student] *)
let exp_1 = {first_name = "izfsk"; last_name = "any"; gpa= 114.514};;

(* expression with type [student -> string * string] *)
let exp_2 student = (student.first_name, student.last_name);; 

(* expression with type [string -> string -> float -> student] *)
let exp_3 fname lname gpa = {first_name=fname;last_name=lname;gpa=gpa};;

type poketype = Normal | Fire | Water;;

type pokemon = {name : string; hp : int; ptype : poketype};;

let charizard = {name="charizard";hp=78;ptype=Fire};;
let squirtle = {name="squirtle";hp=44;ptype=Water};;

(* Write a function safe_hd : 'a list -> 'a option that returns Some x if the head of the input list is x, and None if the input list is empty.
Also write a function safe_tl : 'a list -> 'a list option that returns the tail of the list, or None if the list is empty.*)

let safe_hd = function
  | [] -> None
  | h :: t -> Some h;;

let rec safe_tl = function
  | [] -> None
  | [tail] -> Some tail
  | h :: t -> safe_tl t;;


(* Write a function max_hp : pokemon list -> pokemon option that, given a list of pokemon, finds the Pokémon with the highest HP. *)
let max_hp_wrong list = 
  let rec _max_hp maxium = function
    | [] -> maxium
    | h :: t -> if h.hp > maxium then _max_hp h.hp t else _max_hp maxium t
in
  _max_hp 0 list;;

let rec max_hp = function
  | [] -> None
  | h :: t -> begin
    match max_hp t with
    | None -> Some h
    | Some p -> Some (if p.hp > h.hp then p else h)
  end
;;

open_out (string_of_float (Random.float 20.));;

type date = (int * int * int);;

let is_valid date = 
  let (year, month, day) = date in 
    year > 0 && month >= 1 && month <= 12 && day >= 1 && day <= 31;;

let is_before date_1 date_2 =
  if not (is_valid date_1) || not (is_valid date_2) then false
  else begin
    let (y1, m1, d1) = date_1 in
    let (y2, m2, d2) = date_2 in 
      y1 < y2 && m1 < m2 && d1 < d2
  end;;

assert (is_before (2011, 11, 11) (2099, 11, 12) = false);;

(* Write a function earliest : (int*int*int) list -> (int * int * int) option.
    It evaluates to None if the input list is empty, and to Some d if date d is the earliest date in the list.
    Hint: use is_before.
*)

let earliest list = 
  let rec _earlist result = function
    | [] -> result
    | h :: t -> if is_before h result then _earlist result t else _earlist h t
in
  _earlist (List.nth list 0) list;;

(* Define a variant type suit that represents the four suits, ♣ ♦ ♦ ♠,
    in a standard 52-card deck. All the constructors of your type should be constant.*)

type suit = T1 | T2 | T3 | T4;;

(* Define a type rank that represents the possible ranks of a card: 2, 3, …, 10, Jack, Queen, King, or Ace.
  There are many possible solutions; you are free to choose whatever works for you.
  One is to make rank be a synonym of int, and to assume that Jack=11, Queen=12, King=13, and Ace=1 or 14. Another is to use variants. *)

type rank = Rank of int;;

(* Define a type card that represents the suit and rank of a single card. Make it a record with two fields. *)

type card = {suit : suit; rank : rank};;

(* Define a few values of type card: the Ace of Clubs, the Queen of Hearts, the Two of Diamonds, the Seven of Spades. *)

let the_Ace_of_Clubs = {suit=T1; rank=Rank(5)};;

print_endline;;

type quad = I | II | III | IV
type sign = Neg | Zero | Pos

let sign (x:int) : sign = 
  match x with
  | 0 -> Zero
  | num -> if num > 0 then Pos else Neg;;

let quadrant : int*int -> quad option = fun (x,y) ->
  match (sign x, sign y) with
    | (Pos, Pos) -> Some I
    | (Neg, Pos) -> Some II
    | (Neg, Neg) -> Some III
    | (Pos, Neg) -> Some IV
    | _ -> None;;

assert(quadrant (1, 5) = Some I);;
assert(quadrant (-1, 5) = Some II);;
assert(quadrant (1, 0) = None);;

let quadrant_when : int*int -> quad option = function
    | (x, y) when (x > 0 && y > 0) -> Some I
    | (x, y) when (x < 0 && y > 0) -> Some II
    | (x, y) when (x < 0 && y < 0) -> Some III
    | (x, y) when (x > 0 && y < 0) -> Some IV
    | _ -> None;;

assert(quadrant_when (1, 5) = Some I);;
assert(quadrant_when (-1, 5) = Some II);;
assert(quadrant_when (1, 0) = None);;

(* val sign : int -> [> `Neg | `Pos | `Zero ]
val quadrant : int * int -> [> `I | `II | `III | `IV ] option
*)

let sign2 x = 
  if x = 0 then `Zero
  else if x > 0 then `Pos else `Neg;;

let quadrant_2 (x, y) =
  match (sign2(x), sign2(y)) with
  | (`Pos, `Pos) -> Some `I
  | (`Pos, `Neg) -> Some `IV
  | (`Neg, `Neg) -> Some `III
  | (`Neg, `Pos) -> Some `II 
  | _ -> None



(* Write a function depth : 'a tree -> int that returns the number of nodes in any longest path from the root to a leaf.
  For example, the depth of an empty tree (simply Leaf) is 0,
  and the depth of tree t above is 3. Hint: there is a library function max : 'a -> 'a -> 'a that returns the maximum of any two values of the same type. *)

let rec depth = function
  | Leaf -> 0
  | Node (_, left, right) -> 1 + max (depth left) (depth right);;

(* Write a function same_shape : 'a tree -> 'b tree -> bool that determines whether two trees have the same shape,
 regardless of whether the values they carry at each node are the same. 
 
 Hint: use a pattern match with three branches, where the expression being matched is a pair of trees. 
   *)

let rec same_sharp tree_a tree_b =
  match (tree_a, tree_b) with
  | (Leaf, Leaf) -> true
  | (Node(_,al, ar), Node(_, bl, br)) -> same_sharp al bl && same_sharp ar br
  | _ -> false;;

assert(same_sharp my_tree my_tree = true);;

(* Write a function list_max : int list -> int that returns the maximum integer in a list, or raises Failure "list_max" if the list is empty. *)

let list_max list = 
  if List.length list = 0 then failwith "Empty list" else 
    let rec _list_max maxium = function
      | [] -> maxium
      | h :: t -> if h > maxium then _list_max h t else _list_max maxium t
  in
    _list_max (List.nth list 1) list;;

assert(list_max [1;2;3;4] = 4);;

(* Write a function list_max_string : int list -> string that returns a string containing the maximum integer in a list,
    or the string "empty" (note, not the exception Failure "empty" but just the string "empty") if the list is empty.
       Hint: string_of_int in the standard library will do what its name suggests. *)

let list_max_string list =
  if List.length list = 0 then "empty" else 
    let rec _lms maxium = function
      | [] -> maxium
      | h :: t -> if h > maxium then _lms h t else _lms maxium t
  in
    string_of_int (_lms (List.nth list 1) list);;

assert(list_max_string [1;2;3;4] = "4");;
assert(list_max_string [] = "empty");;

(* Write a function is_bst : ('a*'b) tree -> bool that returns true if and only if the given tree satisfies the binary search tree invariant.
  An efficient version of this function that visits each node at most once is somewhat tricky to write.

  Hint: write a recursive helper function that takes a tree and either gives you 
    (i) the minimum and maximum value in the tree, or 
    (ii) tells you that the tree is empty, or 
    (iii) tells you that the tree does not satisfy the invariant. 
  Your is_bst function will not be recursive, but will call your helper function and pattern match on the result.
  You will need to define a new variant type for the return type of your helper function.*)

