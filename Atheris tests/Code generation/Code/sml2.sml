datatype natural = NEXT of natural | ZERO;

(*exception PreviousOfZero;*)

(* Vrne true, če so podatki urejeni naraščajoče. *)
fun sorted (xs): bool =
	if null xs then true
	else if null(tl xs) then true
	else hd(xs) < hd(tl xs) andalso sorted(tl xs);

sorted ([]);
sorted ([1]);
sorted ([1, 2, 3]);
sorted ([2, 1, 3]);

(* Vrne seznam, ki ima na i-tem mestu terko (xs_i, ys_i),
   v kateri je xs_i i-ti element seznama xs, ys_i pa i-ti
   element seznama ys. Če sta dolžini seznamov različni, vrnite
   pare do dolžine krajšega. *)
fun zip (xs, ys) =
	if null xs orelse null ys then []
	else (hd xs, hd ys)::zip(tl xs, tl ys);

zip([1, 2, 3], ["a", "b", "c"]);
zip([1, 2, 3], ["a", "b", "c", "d"]);
zip([1, 2, 3, 4], ["a", "b", "c"]);

(* Vrne obrnjen seznam. Uporabite repno rekurzijo. *)
fun reverse (xs) =
	let
		fun reverse_(xs, acc) =
			if null xs then acc
			else reverse_(tl xs, (hd xs)::acc)
	in
		reverse_ (xs, [])
	end;

reverse ([1, 2, 3, 4]);

(* Vrne natural, ki predstavlja število a, ali proži izjemo
   PreviousOfZero, če a < 0. *)
fun toNatural (a: int): natural =
	if a < 0 then ZERO
	else if a = 0 then ZERO
	else NEXT(toNatural(a - 1));

toNatural 0;
toNatural 1;
toNatural 3;

(* Vrne true, če je a sodo število. *)
fun isEven (a: natural): bool =
	let fun toInt(a: natural): int =
			case a of
				ZERO => 0
				| NEXT b => 1 + toInt(b)
	in
		toInt(a) mod 2 = 0
	end;

isEven (toNatural 5);
isEven (toNatural 6);
isEven (toNatural 7);
isEven (toNatural 8);

(* Vrne true, če je a liho število. *)
fun isOdd (a: natural): bool =
	not (isEven a);

isOdd (toNatural 5);
isOdd (toNatural 6);
isOdd (toNatural 7);
isOdd (toNatural 8);

(* Vrne predhodnika naravnega števila a.
   Če je a ZERO, proži izjemo PreviousOfZero. *)
fun previous (a: natural): natural =
	case a of
		ZERO => ZERO
		| NEXT prev => prev;

previous (toNatural 3);
previous (toNatural 2);

(* Vrne naravno število, ki ustreza razliki števil a in b (a - b).
   Če rezultat ni naravno število, proži izjemo PreviousOfZero. *)
fun subtract (a: natural, b: natural): natural =
	case a of
		ZERO => (case b of
			ZERO => ZERO
			| NEXT _ => ZERO)
		| NEXT x => case b of
			ZERO => a
			| NEXT y => subtract(x, y);

subtract (toNatural(5), toNatural(3));
subtract (toNatural(5), toNatural(4));
subtract (toNatural(3), toNatural(3));
subtract (toNatural(0), toNatural(0));

(* Vrne true, če funkcija f vrne true za kateri koli element seznama.
   Za prazen seznam naj vrne false. *)
fun any (f, xs): bool =
	if null xs then false
	else f (hd xs) orelse any(f, tl xs);

any (fn (x) => x < 2, [1, 2, 3, 4, 5]);
any (fn (x) => x < 2, [3, 4, 5]);

(* Vrne true, če funkcija f vrne true za vse elemente seznama.
   Za prazen seznam naj vrne true. *)
fun all (f, xs): bool =
	if null xs then true
	else f (hd xs) andalso all(f, tl xs);

all (fn (x) => x < 2, [1, 1, 1, 1, 1]);
all (fn (x) => x < 2, [1, 2, 3, 4, 5]);
all (fn (x) => x < 2, [3, 4, 5]);
