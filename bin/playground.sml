datatype natural = NEXT of natural | ZERO;

fun toInt (a) =
  case a of
    ZERO => 0
    | NEXT i => 1 + toInt(i);

val x = NEXT(ZERO);
val a = toInt x;