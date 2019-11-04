datatype ('a, 'b) X = A of ('a * int) | B of ('b * string);
val x: (int, bool) X = A (10, 20);
val y: (int, bool) X = B (true, "rocket");