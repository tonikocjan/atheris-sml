datatype (''a,'b) X =
  A of ''a
  | B of 'b;

val a: (int, int) X = A false; 