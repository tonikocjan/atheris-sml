datatype A = 
	X of int 
	| Y of int
	| Z;

case X 10 of
	X a => 1
	| Y a => 2
	| Z => 0;

case Y 10 of
	X a => 1
	| Y a => 2
	| Z => 0;

case Z of
	X a => 1
	| Y a => 2
	| Z => 0;

(*datatype A = 
	X of int 
	| Y of (int*int)
	| Z;

case (Y (10, 20)) of
	Z => 0
	| Y a => #2 a
	| X a => 1;*)

(*datatype List = 
	E
	| C of (int * List);

val u = C(1, C(2, C(3, E)));
case u of 
	E => 0
	| C (a, b) => a;*)