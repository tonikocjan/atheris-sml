val xs = [false, false, true];

case xs of
	true::tl => 1
	| false::tl => 2;

val xss = [(true, 10), (true, 20), (false, 30)];
case xss of
	(true, 10)::tl => 1
	| (false, 10)::tl => 2
	| (true, 12)::tl => 3;