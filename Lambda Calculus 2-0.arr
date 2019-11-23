
provide *

######## None ########

fun f-none():
  f-none
end

######## Pair ########

fun f-first(a, b):
  doc: ```Returns the first of the two arguments.```
  a
end

fun f-second(a, b):
  doc: ```Returns the second of the two arguments.```
  b
end

fun f-pair(a, b):
  doc: ```Makes a pair of the two arguments, which is a function that takes
       ffirst or fsecond to choose which of the pair to retrieve.```
  lam(which):
    which(a, b)
  end
end

fun f-pair-first(pair):
  doc: ```Gets the first from a pair.```
  pair(f-first)
end

fun f-pair-second(pair):
  doc: ```Gets the second from a pair.```
  pair(f-second)
end

check "Pairs Functions":
  f-pair-first(f-pair(1, 2)) is 1
  f-pair-second(f-pair(1, 2)) is 2
end

######## Boolean ########

fun f-true(a, b):
  doc: ```Returns the first of the two arguments.```
  a
end

fun f-false(a, b):
  doc: ```Returns the second of the two arguments.```
  b
end

fun f-if(bool, true-val, false-val):
  doc: ```Bool will choose which val to return.```
  bool(true-val, false-val)
end

fun f-not(a):
  doc: ```Not```
  f-if(a, f-false, f-true)
end

fun f-and(a, b):
  doc: ```And```
  f-if(a, b, f-false)
end

fun f-or(a, b):
  doc: ```Or```
  f-if(a, f-true, b)
end

check "Boolean Functions":
  checker = f-if(_, true, false)

  f-or(f-true, f-true)
    satisfies checker
  f-or(f-true, f-false)
    satisfies checker
  f-or(f-false, f-true)
    satisfies checker
  f-not(f-or(f-false, f-false))
    satisfies checker


  f-and(f-true, f-true)
    satisfies checker
  f-not(f-and(f-true, f-false))
    satisfies checker
  f-not(f-and(f-false, f-true))
    satisfies checker
  f-not(f-and(f-false, f-false))
    satisfies checker
end

######## Natural ########

f-zero = f-pair(f-none, f-true)

fun f-is-zero(num):
  doc: ```The second item in the pair tells whether the number is fzero.```
  f-pair-second(num)
end

fun f-successor(num):
  doc: ```The successor of a number is a pair of the previous number and
       ffalse (since the successor of a number is not 0).```
  f-pair(num, f-false)
end

fun f-predecessor(num):
  doc: ```The predecessor of a number is just the first of its pair.
       Precondition: num is not fzero.```
  f-pair-first(num)
end

fun f-natural-equal(num1, num2):
  f-if(
    f-or(f-is-zero(num1), f-is-zero(num2)),
    {(): f-and(f-is-zero(num1), f-is-zero(num2))},
    {(): f-natural-equal(f-predecessor(num1), f-predecessor(num2))})()
end
