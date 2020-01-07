datatype 'a O = J of 'a | N;
fun m x f = case x of J l => J (f l) | N => N;

val x = m (J 10) (fn x => x * x);
case x of
  J x => x
  | N => 0;