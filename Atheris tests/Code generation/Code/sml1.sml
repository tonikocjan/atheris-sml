(********************** Natural **********************)

(* Naravna števila definiramo tako:
 * - Obstaja ničla (ZERO).
 * - Vsako naravno število ima svojega naslednika (NEXT).
 * - Ničla ni naslednik nobenega naravnega števila.
 * - Če sta dve naravni števili enaki, potem sta enaka tudi njuna naslednika.
 *)
datatype natural = NEXT of natural | ZERO;

(* Vrne celoštevilsko vrednost (int) naravnega števila. *)
fun toInt (a: natural): int =
  case a of
    ZERO => 0
    | NEXT i => 1 + toInt(i);

toInt ZERO;
toInt(NEXT(ZERO));
toInt(NEXT(NEXT(ZERO)));
toInt(NEXT(NEXT(NEXT(NEXT(NEXT(ZERO))))));

(* Vrne vsoto naravnih števil a in b. Pretvorba v int ni dovoljena! *)
fun add (a: natural, b: natural): natural =
  case b of
    ZERO => a
    | NEXT i => add(NEXT(a), i);

val two = NEXT(NEXT(ZERO));
val four = NEXT(NEXT(NEXT(NEXT(ZERO))));
val eight = NEXT(NEXT(NEXT(NEXT(NEXT(NEXT(NEXT(NEXT(ZERO))))))));

toInt(add(two, four));
toInt(add(two, eight));
toInt(add(eight, eight));
toInt(add(ZERO, ZERO));
toInt(add(ZERO, two));

(********************** Tree **********************)

(* Binarno drevo celih števil definiramo tako:
 * - Obstaja vozlišče (NODE), ki ima poleg vrednosti tudi dve poddrevesi.
 * - Obstaja list (LEAF), ki ima le vrednost.
 *)
datatype tree = NODE of int * tree * tree | LEAF of int;

(* Vrne najmanjši element drevesa, če obstaja. *)
fun min (tree: tree): int =
  case tree of
    LEAF x => x
    | NODE (x, left, right) => let
      val l = min left
      val r = min right
    in
      if x < l andalso x < r then x
      else if l < r then l else r
    end;

val big_tree = NODE(1,
          NODE(2,
            LEAF 5,
            LEAF 7),
          NODE(10,
            LEAF ~10,
            NODE(1,
              NODE(100,
                LEAF 10,
                LEAF 100),
              LEAF 500)));
min(LEAF 10);
min(big_tree);

(* Vrne največji element drevesa, če obstaja. *)
fun max (tree: tree): int =
  case tree of
    LEAF x => x
    | NODE (x, left, right) => let
      val l = max left
      val r = max right
    in
      if x > l andalso x > r then x
      else if l > r then l else r
    end;

max(LEAF 10);
max(big_tree);

(* Vrne true, če drevo vsebuje element x. *)
fun contains (tree: tree, x: int): bool =
  case tree of
    LEAF a => a = x
    | NODE (a, left, right) => a = x orelse contains(left, x) orelse contains(right, x);

contains(big_tree, 123); (* false *)
contains(big_tree, 0); (* false *)
contains(big_tree, 1); (* true *)
contains(big_tree, ~10); (* true *)
contains(big_tree, 500); (* true *)

(* Vrne število listov v drevesu. *)
fun countLeaves (tree: tree): int =
  case tree of
    LEAF _ => 1
    | NODE (_, l, r) => countLeaves(l) + countLeaves(r);
countLeaves big_tree;

(* Vrne število število vej v drevesu. *)
fun countBranches (tree: tree): int =
  case tree of
    LEAF _ => 0
    | NODE (_, l, r) => 1 + countBranches(l) + countBranches(r);
countBranches big_tree;

(* Vrne višino drevesa. Višina lista je 1. *)
fun height (tree: tree): int =
  case tree of
    LEAF _ => 1
    | NODE (_, l, r) => let
      val left = 1 + height(l)
      val right = 1 + height(r)
    in
      if left > right then left else right
    end;
height(LEAF 10);
height big_tree;

fun append_lst(lst_a, lst_b) =
  let
    fun append(lst, a) =
      let
        fun insert(lst, x, n) =
          if null lst then x::[]
          else if n = 0 then x::lst
          else (hd lst)::insert(tl lst, x, n - 1)
        fun len lst =
          if null lst then 0
          else 1 + len(tl lst)
    in
      insert(lst, a, len lst)
    end
  in
    if null lst_b then lst_a
      else append_lst(append(lst_a, hd lst_b), tl lst_b)
  end;

append_lst([1], [4]);

(* Pretvori drevo v seznam z vmesnim prehodom (in-order traversal). *)
fun toList (tree: tree) =
  case tree of
    LEAF i => [i]
    | NODE (i, l, r) => append_lst(append_lst(toList(l), [i]), toList r);
toList big_tree;

(* Vrne true, če je drevo uravnoteženo:
 * - Obe poddrevesi sta uravnoteženi.
 * - Višini poddreves se razlikujeta kvečjemu za 1.
 * - Listi so uravnoteženi po definiciji.
 *)
fun isBalanced (tree: tree): bool =
  case tree of
    LEAF _ => true
    | NODE (_, l, r) => let
      val height_diff = height(l) - height(r)
    in
      height_diff <= 1 andalso height_diff >= ~1
    end;

isBalanced(LEAF 10);
isBalanced(big_tree);
isBalanced(NODE(0, NODE(0, LEAF 0, LEAF 0), NODE(0, LEAF 0, LEAF 0)));

(* Vrne true, če je drevo binarno iskalno drevo:
 * - Vrednosti levega poddrevesa so strogo manjši od vrednosti vozlišča.
 * - Vrednosti desnega poddrevesa so strogo večji od vrednosti vozlišča.
 * - Obe poddrevesi sta binarni iskalni drevesi.
 * - Listi so binarna iskalna drevesa po definiciji.
 *)
fun isBST (tree: tree): bool =
let
  fun eval tree =
    case tree of
      LEAF x => x
      | NODE (x, _, _) => x
in
  case tree of
    LEAF _ => true
    | NODE (x, l, r) =>
    let
      val left = eval l
      val right = eval r
    in
      x > left andalso x < right andalso isBST(l) andalso isBST(r)
    end
end;

val bst = NODE(20,
      NODE(10,
        NODE(5,
          LEAF 2,
          NODE(7,
            LEAF 6,
            LEAF 8)),
        NODE(15,
          LEAF 12,
          LEAF 17)),
      NODE(22,
        LEAF 18,
        LEAF 25));

isBST(LEAF 10);
isBST big_tree;
isBST bst;
