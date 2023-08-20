let rec transfrom f = function
  | [] -> []
  | h :: t -> (f h) :: transfrom f t;;

let double x = x * 2;;

let square x =  x * x;;

let add_one = transfrom double;;

let rev list =
  let rec aux acc = function
    | [] -> acc
    | h :: t -> aux (h :: acc) t
  in
  aux [] list;;

let rec sum = function
  | [] -> 0
  | h :: t -> h + sum t;;

let rec better_sum list =  
  let rec _sum acc = function
    | [] -> acc
    | h :: t -> _sum (acc + h) t
in
  _sum 0 list;;

let big_list = List.init 1000000 (fun (x) -> x);;

let rec map f = function
  | [] -> []
  | h :: t -> let r = f h in r :: map f t;;

let map f list =
  let rec _map f acc = function
    | [] -> acc
    | h :: t -> _map f (f h :: t) t
in
  _map f [] list;;

let rec print_list = function
  | [] -> ()
  | h :: t -> print_int h;print_list t;;

print_list (List.map (fun (x) -> x * x) [1;2;3;4;5]);;

let rec combine init op = function
  | [] -> init
  | h :: t -> op h (combine init op t);;

let sum' list = combine 0 ( + ) list;;

assert(sum' [1;2;3] = 6);;

let rec fold_right f acc list = 
  match list with
  | [] -> acc
  | h :: t -> f h (fold_right f acc t);;

assert (fold_right ( + ) 0 [1;2;3] = 6);;

let rec fold_left f acc list = 
  match list with
  | [] -> acc
  | h :: t ->
    let acc' = f h acc in fold_left f acc' t;;

assert (fold_right ( * ) 1 [1;2;3] = 6);;

let map' f lst =
  List.fold_right (fun x acc -> f x :: acc) lst [];;

type 'a tree =
  | Leaf
  | Node of ('a * 'a tree * 'a tree);;

let rec map_t f = function
  | Leaf -> Leaf
  | Node (v, l, r) -> Node(f v, map_t f l, map_t f r);;

let rec fold_t f acc = function
  | Leaf -> acc
  | Node (v, l, r) -> f v + fold_t f acc l + fold_t f acc r;;

let size t = fold_t (fun (_, l, r) -> 1 + l + r) 0 t;;
let depth t = fold_t (fun (_, l, r) -> 1 + max l r) 0 t;;

let rec filter f = function
  | Leaf -> Leaf
  | Node(v, l, r) -> if f v then Node(v, filter f l, filter f r) else Leaf;;

(* def sum_sq(n):
    sum = 0
    for i in range(0, n+1):
      sum += i * i
    return sum
*)

let sum_sq n =
  let rec aux sum = function
    | 0 -> sum
    | n -> aux (sum + n * n) (n - 1)
in
  aux 0 n;;

let sum_sq' n =
  let rec loop i sum =
    if i > n then sum
    else loop (i + 1) (sum + i * i)
  in loop 0 0;;

assert(sum_sq 10 = sum_sq' 10);;

let rec ( --> ) n m = if n = 0 then [] else n :: (n + 1) --> m;;
let square x = x * x;;
let sum = List.fold_left ( + ) 0;;

let sum_sq'' n = 0 --> n |> List.map square |> sum;;

print_int (sum_sq'' 20);;

print_endline "";;

(*
Generalize twice to a function repeat, such that repeat f n x applies f to x a total of n times. That is,
    repeat f 0 x yields x
    repeat f 1 x yields f x
    repeat f 2 x yields f (f x) (which is the same as twice f x)
    repeat f 3 x yields f (f (f x))   
*)

let rec repeat f n x = if n = 0 then x else repeat f (n - 1) (f x);;

print_endline (string_of_int (repeat (fun (x) -> (x+x)) 30 1));;

(*
Use fold_left to write a function product_left that computes the product of a list of floats.
The product of the empty list is 1.0.
Hint: recall how we implemented sum in just one line of code in lecture.

Use fold_right to write a function product_right that computes the product of a list of floats. Same hint applies.   
*)

let product_left list = if list = [] then 1.0 else List.fold_left ( *. ) 1.0 list;;
assert(product_left [1.0;2.0;3.0] = 6.0);;

let product_right list = if list = [] then 1.0 else List.fold_right ( *. ) list 1.0;;
assert(product_right [1.0;2.0;3.0] = 6.0);;

(*
How terse can you make your solutions to the product exercise?

Hints: you need only one line of code for each, and you do not need the fun keyword.
For fold_left, your function definition does not even need to explicitly take a list argument.
If you use ListLabels, the same is true for fold_right.   
*)

let product list = List.fold_left ( *. ) 1.0 list;;

(*
Write a function sum_cube_odd n that computes the sum of the cubes of all the odd numbers between 0 and n inclusive.
Do not write any new recursive functions.
Instead, use the functionals map, fold, and filter, and the ( -- ) operator (defined in the discussion of pipelining).    
*)

let rec ( -- ) n l = if n = 0 then l else (n - 1) -- (n :: l);;

let get_odd_numbers list = List.filter (fun (x) -> x mod 2 = 0) list;;

let square list = List.map (fun (x) -> x * x) list;;

let sum list = List.fold_left (fun x y -> x + y) 0 list;;

let sum_cube_odd n = 
  n -- [] |> get_odd_numbers |> square |> sum;;

let sum_cube_odd' n =
  n -- [] |> List.filter (fun (x) -> x mod 2 = 0) |> List.map (fun (x) -> x * x) |> sum;;

(**
Consider writing a function exists: ('a -> bool) -> 'a list -> bool, such that exists p [a1; ...; an] 
returns whether at least one element of the list satisfies the predicate p. 
That is, it evaluates the same as (p a1) || (p a2) || ... || (p an). When applied to an empty list, it evaluates to false.

Write three solutions to this problem, as we did above:
    - exists_rec, which must be a recursive function that does not use the List module,
    - exists_fold, which uses either List.fold_left or List.fold_right, but not any other List module functions nor the rec keyword, and
    - exists_lib, which uses any combination of List module functions other than fold_left or fold_right, and does not use the rec keyword.
*)

let exists_rec f list = 
  let rec aux last = function
    | [] -> last
    | h :: t -> if last then last else aux (f h) t 
  in aux false list;;
  
assert( exists_rec (fun (x) -> x = 0) [1;2;3;4] = false);;
assert( exists_rec (fun (x) -> x = 0) [1;2;0;4] = true);;

let exists_fold f list = 
  List.fold_left (fun acc c -> if acc then acc else f c) false list;;

assert( exists_fold (fun (x) -> x = 0) [1;2;3;4] = false);;
assert( exists_fold (fun (x) -> x = 0) [1;2;0;4] = true);;

let exists_lib f list = 
  list |> List.map f |> List.filter (fun x -> x) |> List.length >= 1;;

assert( exists_lib (fun (x) -> x = 0) [1;2;3;4] = false);;
assert( exists_lib (fun (x) -> x = 0) [1;2;0;4] = true);;

(*
Write a function which, given a list of numbers representing debits, deducts them from an account balance,
and finally returns the remaining amount in the balance. 
编写一个函数，给定代表借方的数字列表，从帐户余额中扣除它们，最后返回余额中的剩余金额。

Write three versions: fold_left, fold_right, and a direct recursive implementation.   
*)

let rec balence account = function
  | [] -> account
  | h :: t -> balence (account - h) t;;

assert (balence 1000 [11;22;48;75;14] = 830);;

let balence' account debits = List.fold_left (fun acc c -> acc - c) account debits;;
assert (balence' 1000 [11;22;48;75;14] = 830);;

let balance'' account debits = account - (List.fold_right (fun x y -> x + y ) debits 0);;

assert (balance'' 1000 [11;22;48;75;14] = 830);;

(*
write uncurried versions of these library functions:
    List.append
    Char.compare
    Stdlib.max
*)

let ucd_append (lst1, lst2) = List.append lst1 lst2;;
let ucd_compare (a, b) = Char.compare a b;;
let ucd_max (a, b) = Stdlib.max a b;;

(*
Write functions that perform the following computations.
  * Find those elements of a list of strings whose length is strictly greater than 3.
  * Add 1.0 to every element of a list of floats.
  * Given a list of strings strs and another string sep,
      produce the string that contains every element of strs separated by sep.
      For example, given inputs ["hi";"bye"] and ",", produce "hi,bye",
      being sure not to produce an extra comma either at the beginning or end of the result string.
*)

let a1 lst = List.filter (fun x -> String.length x > 3) lst;;
let a1' lst= 
  let rec aux result = function
    | [] -> result
    | h :: t -> if String.length h > 3 then aux (h :: result) t else aux result t
  in aux [] lst;;

let a2 lst = List.map (fun acc c -> acc +. c ) lst;;

let a3 strs sep = List.fold_left (fun acc c -> if acc = "" then (acc ^ c) else(acc ^ sep ^ c)) "" strs;;

print_endline (a3 ["hello";"world"] ",");;

(*
Recall that an association list is an implementation of a dictionary in terms of a list of pairs,
 in which we treat the first component of each pair as a key and the second component as a value.

Write a function keys: ('a * 'b) list -> 'a list that returns a list of the unique keys in an association list.
 Since they must be unique, no value should appear more than once in the output list. 
 The order of values output does not matter. 
 How compact and efficient can you make your solution? Can you do it in one line and linearithmic space and time?
Hint: List.sort_uniq.   
*)

let keys lst = lst |> List.rev_map fst |> List.sort_uniq Stdlib.compare;;

let keys' lst = List.fold_left 
  (fun acc (k, v) -> if List.exists (( = ) k) acc then acc else k :: acc);;

(*
Implement a function is_valid_matrix: int list list -> bool that returns whether the input matrix is valid.    
*)

let is_valid_matrix matrix =
  List.map List.length matrix 
    |> List.fold_left (fun acc x -> if List.exists (( = ) x) acc then acc else x :: acc) [] 
    |> List.length = 1;;

assert (is_valid_matrix [[1; 2]; [3]] = false);;
assert (is_valid_matrix [] = false);;
assert (is_valid_matrix [[1; 1; 1]; [9; 8; 7]] = true);;

(*
Implement a function add_row_vectors: int list -> int list -> int list for the element-wise addition of two row vectors.
For example, the addition of [1; 1; 1] and [9; 8; 7] is [10; 9; 8]. 
If the two vectors do not have the same number of entries, 
the behavior of your function is unspecified—that is, it may do whatever you like. 

Hint: there is an elegant one-line solution using List.map2. Unit test the function.   
*)

let add_row_vectors v1 v2 = List.map2 (fun a b -> a + b) v1 v2;;

