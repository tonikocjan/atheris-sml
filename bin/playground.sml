val x = {a = 10, b = "string", promise = {evaled = false, f = fn x => x * x}};
val a = (#f (#promise x)) 10;