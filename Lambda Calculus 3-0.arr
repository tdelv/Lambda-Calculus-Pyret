#|
provide {
    # Lambda calculus functions
    f-r : f-r,
    f-bind : f-bind,
    
    # None
    f-none : f-none,
    
    # Booleans
    f-true : f-true,
    f-false : f-false,
    
    f-if : f-if,
    f-if-lazy : f-if-lazy,
    f-and : f-and,
    f-and-lazy : f-and-lazy,
    f-or : f-or,
    f-or-lazy : f-or-lazy,
    f-not : f-not,

    m-print-bool : m-print-bool,
    m-make-bool : m-make-bool,

    # Pairs
    f-pair : f-pair,
    f-pfirst : f-pfirst,
    f-psecond : f-psecond,

    # Naturals
    f-zero : f-zero,
    f-one : f-one,
    f-two : f-two,

    f-succ : f-succ,
    f-pred : f-pred,

    f-is-zero : f-is-zero,

    f-num-equal : f-num-equal,
    f-lessthan : f-lessthan,
    f-greaterthan : f-greaterthan,

    f-add : f-add,
    f-sub : f-sub,
    f-mul : f-mul,
    f-div : f-div,
    f-mod : f-mod,

    m-print-num : m-print-num,
    m-make-num : m-make-num,

    # Lists
    f-empty : f-empty,
    f-link : f-link,
    f-lzlink : f-lzlink,

    f-is-empty : f-is-empty,
    f-is-link : f-is-link,

    f-lfirst : f-lfirst,
    f-lrest : f-lrest,

    f-1list : f-1ist,
    f-2list : f-2list,
    f-3list : f-3list,

    m-print-list : m-print-list,
    m-make-list : m-make-list,
    m-print-list-of-num : m-print-list-of-num,
    m-make-list-of-num : m-make-list-of-num
  }
   end
|#

provide *

# Necessary to do any kind of recursion.
# To use:
#  my-func = r({(my-func): {(arg1, arg2): r(my-func)(next-arg1, next-arg2)}})
f-r = {(func): func(func)}

# Necessary for name binding to avoid repeated computation
# It's small and seems silly, but will clean things up later.
# To use:
#  f-bind(calculation)({(name): 
#    # name is bound to calculation here}})
f-bind = {(value): {(func): func(value)}}

# A function used to fill in for thunks and in place with no meaning.
f-none = f-r({(f-none): {(_): f-r(f-none)}})

# Booleans
f-true = {(a): {(_): a}}
f-false = {(_): {(b): b}}

f-if = {(bool): {(if-true): {(if-false): bool(if-true)(if-false)}}}
f-if-lazy = {(bool): {(if-true): {(if-false): bool(if-true)(if-false)(f-none)}}}

f-and = {(bool1): {(bool2): f-if(bool1)(bool2)(f-false)}}
f-and-lazy = {(bool1): {(bool2): f-if-lazy(bool1(f-none))(bool2)({(_): f-false})}}
f-or = {(bool1): {(bool2): f-if(bool1)(f-true)(bool2)}}
f-or-lazy = {(bool1): {(bool2): f-if-lazy(bool1(f-none))({(_): f-true})(bool2)}}
f-not = {(bool): bool(f-false)(f-true)}

fun m-print-bool(bool) -> Boolean:
  bool(true)(false)
end

fun m-make-bool(bool):
  if bool:
    f-true
  else:
    f-false
  end
end

check "Booleans":
  # And
  f-and(f-true)(f-true) satisfies m-print-bool
  f-and(f-true)(f-false) violates m-print-bool
  f-and(f-false)(f-true) violates m-print-bool
  f-and(f-false)(f-false) violates m-print-bool
  
  # Or
  f-or(f-true)(f-true) satisfies m-print-bool
  f-or(f-true)(f-false) satisfies m-print-bool
  f-or(f-false)(f-true) satisfies m-print-bool
  f-or(f-false)(f-false) violates m-print-bool
  
  # Not
  f-not(f-true) violates m-print-bool
  f-not(f-false) satisfies m-print-bool
  
  # If
  f-if(f-true)(f-true)(f-false) satisfies m-print-bool
  f-if(f-false)(f-true)(f-false) violates m-print-bool
  
  # Lazy
  f-and-lazy({(_): f-false})({(_): raise("")}) violates m-print-bool
  f-or-lazy({(_): f-true})({(_): raise("")}) satisfies m-print-bool
  f-if-lazy(f-true)({(_): f-true})({(_): raise("")}) satisfies m-print-bool
  f-if-lazy(f-false)({(_): raise("")})({(_): f-false}) violates m-print-bool
end

# Pairs
h-first = {(a): {(_): a}}
h-second = {(_): {(b): b}}

f-pair = {(a): {(b): {(which): which(a)(b)}}}
f-pfirst = {(p): p(h-first)}
f-psecond = {(p): p(h-second)}

check "Pairs":
  f-pfirst(f-pair(1)(2)) is 1
  f-psecond(f-pair(1)(2)) is 2
end

# Natural Numbers
f-zero = f-pair(f-none)(f-true)

f-succ = {(num): f-pair(num)(f-false)}
f-pred = {(num): f-pfirst(num)}

f-is-zero = {(num): f-psecond(num)}

f-num-equal = f-r({(f-num-equal):
    {(num1): {(num2): f-or-lazy(
          # Are they both zero?
          {(_): f-and(f-is-zero(num1))(f-is-zero(num2))})(
          {(_): f-and-lazy(
              # Are they both non-zero?
              {(_): f-and(f-not(f-is-zero(num1)))(f-not(f-is-zero(num2)))})(
              # Recur on predecessor
              {(_): f-r(f-num-equal)(f-pred(num1))(f-pred(num2))})})}}})

f-add = f-r({(f-add): 
    {(num1): {(num2): 
        f-if-lazy(f-is-zero(num2))(
          # a + 0 = a
          {(_): num1})(
          # a + b = (a + 1) + (b - 1)
          {(_): f-r(f-add)(f-succ(num1))(f-pred(num2))})}}})

f-sub = f-r({(f-sub): 
    {(num1): {(num2): 
        f-if-lazy(f-is-zero(num2))(
          # a - 0 = a
          {(_): num1})(
          {(_): f-if-lazy(f-is-zero(num1))(
              # 0 - b = 0
              {(_): f-zero})(
              # a - b = (a + 1) + (b - 1)
              {(_): f-r(f-sub)(f-pred(num1))(f-pred(num2))})})}}})

f-lessthan = {(num1): {(num2): f-not(f-is-zero(f-sub(num2)(num1)))}}
f-greaterthan = {(num1): {(num2): f-not(f-is-zero(f-sub(num1)(num2)))}}

f-mul = f-r({(f-mul): 
    {(num1): {(num2): 
        f-if-lazy(f-is-zero(num2))(
          # a * 0 = 0
          {(_): f-zero})(
          # a * b = a + a * (b - 1)
          {(_): f-add(num1)(f-r(f-mul)(num1)(f-pred(num2)))})}}})

f-div = f-r({(f-div):
    {(num1): {(num2): 
        f-if-lazy(f-lessthan(num1)(num2))(
          # a / b = 0 if a < b
          {(_): f-zero})(
          # a / b = 1 + (a - b) / b otherwise
          {(_): f-succ(f-r(f-div)(f-sub(num1)(num2))(num2))})}}})

f-mod = f-r({(f-mod):
    {(num1): {(num2): 
        f-if-lazy(f-lessthan(num1)(num2))(
          # a mod b = a if a < b
          {(_): num1})(
          # a mod b = (a - b) mod b otherwise
          {(_): f-r(f-div)(f-sub(num1)(num2))(num2)})}}})

f-one = f-succ(f-zero)
f-two = f-succ(f-one)

fun m-print-num(num) -> Number:
  if m-print-bool(f-is-zero(num)):
    0
  else:
    1 + m-print-num(f-pred(num))
  end
end

fun m-make-num(num :: Number):
  if num == 0:
    f-zero
  else:
    f-succ(m-make-num(num - 1))
  end
end

check "Natural numbers":
  p = m-print-num
  m = m-make-num
  
  fun a(op, val1, val2): op(m(val1))(m(val2)) end
  
  p(a(f-div, 0, 5)) is 0
  p(a(f-div, 10, 1)) is 10
  p(a(f-div, 10, 5)) is 2
  p(a(f-div, 11, 5)) is 2
end

# List
f-empty = f-pair(f-none)(f-true)
f-link = {(f): {(r): f-pair(f-pair(f)({(_): r}))(f-false)}}
f-lzlink = {(f): {(r): f-pair(f-pair(f)(r))(f-false)}}

f-is-empty = {(lis): f-psecond(lis)}
f-is-link = {(lis): f-not(f-psecond(lis))}

f-lfirst = {(lis): f-pfirst(f-pfirst(lis))}
f-lrest = {(lis): f-psecond(f-pfirst(lis))(f-none)}

f-1list = {(item): f-link(item)(f-empty)}
f-2list = {(item1): {(item2): f-link(item1)(f-1list(item2))}}
f-3list = {(item1): {(item2): {(item3): f-link(item1)(f-2list(item2)(item3))}}}

fun m-print-list(lis) -> List:
  if m-print-bool(f-is-empty(lis)):
    empty
  else:
    link(f-lfirst(lis), m-print-list(f-lrest(lis)))
  end
end

fun m-make-list(lis :: List):
  cases (List) lis:
    | empty => f-empty
    | link(f, r) => f-link(f)(m-make-list(r))
  end
end

fun m-print-list-of-num(lis) -> List<Number>:
  if m-print-bool(f-is-empty(lis)):
    empty
  else:
    link(m-print-num(f-lfirst(lis)), m-print-list-of-num(f-lrest(lis)))
  end
end

fun m-make-list-of-num(lis :: List<Number>):
  cases (List<Number>) lis:
    | empty => f-empty
    | link(f, r) => f-link(m-make-num(f))(m-make-list-of-num(r))
  end
end