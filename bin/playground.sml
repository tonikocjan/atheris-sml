datatype natural = NEXT of natural | ZERO;

(* Vrne celoštevilsko vrednost (int) naravnega števila. *)
fun toInt (a: int) =
	case a of
		ZERO => 0
		| NEXT i => 1 + toInt(i);