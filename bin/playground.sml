datatype prevozno_sredstvo_t = 
	Bus of int
	| Avto of (string*string*int)
	| Pes;

val x = Bus 10;
val y = Avto ("abc", "efg", 10);
val z = Pes;