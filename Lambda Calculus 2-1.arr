import shared-gdrive("Lambda Calculus 2-0.arr", 
  "1aNj-uAZBqV04gUaC3iMKcx-Q-Fs_31y7") as T

#|
   0) None = (-> None)
   
   Chooser<A, B> = (A, B -> (A | B))
   
   1) Pair<A, B> = (A, B -> Chooser<A, B>)
   
   2) Boolean = Chooser<Any, Any>
   
   List<A> = Pair<(None | Pair<A, List<A>>), Boolean>
   
   3) Natural = List<Boolean>
   4) Integer = Pair<Natural, Pair<Boolean, (None | Boolean)>>
   5) Rational = Pair<Pair<Natural, Natural>, Boolean>
   6) Real = Pair<Boolean, Pair<Integer, List<Boolean>>>
   7) Complex = Pair<Real, Real>
|#

######## Types ########

fun t-make(typ, value):
  T.f-pair(typ, value)
end

fun t-type(pair):
  T.f-pair-first(pair)
end

fun t-value(pair):
  T.f-pair-second(pair)
end

t-none = T.f-zero
t-pair = T.f-successor(t-none)
t-boolean = T.f-successor(t-pair)
t-natural = T.f-successor(t-boolean)
t-integer = T.f-successor(t-natural)
t-rational = T.f-successor(t-integer)
t-real = T.f-successor(t-rational)
t-complex = T.f-successor(t-real)

fun t-equal(type1, type2):
  T.f-natural-equal(type1, type2)
end

fun t-is-pair(val):
  t-equal(t-pair, t-type(val))
end

fun t-is-boolean(val):
  t-equal(t-boolean, t-type(val))
end

fun t-is-natural(val):
  t-equal(t-natural, t-type(val))
end

fun t-is-integer(val):
  t-equal(t-integer, t-type(val))
end

fun t-is-rational(val):
  t-equal(t-rational, t-type(val))
end

fun t-is-real(val):
  t-equal(t-real, t-type(val))
end

fun t-is-complex(val):
  t-equal(t-complex, t-type(val))
end

fun m-type-tostring(t):
  ask:
    | t-equal(t, t-none)(true, false) then: "none"
    | t-equal(t, t-pair)(true, false) then: "pair"
    | t-equal(t, t-boolean)(true, false) then: "boolean"
    | t-equal(t, t-natural)(true, false) then: "natural"
    | t-equal(t, t-integer)(true, false) then: "integer"
    | t-equal(t, t-rational)(true, false) then: "rational"
    | t-equal(t, t-real)(true, false) then: "real"
    | t-equal(t, t-complex)(true, false) then: "complex"
    | otherwise: "Invalid type."
  end
end

######## None ########

fun f-none():
  t-make(t-none, 
    f-none)
end

######## Pair ########

fun f-first(first, second):
  first
end

fun f-second(first, second):
  second
end

fun f-pair(first, second):
  t-make(t-pair,
    lam(which):
      which(first, second)
    end)
end

fun f-pair-first(pair):
  t-value(pair)(f-first)
end

fun f-pair-second(pair):
  t-value(pair)(f-second)
end

######## Boolean ########

f-true = t-make(t-boolean, f-first)
f-false = t-make(t-boolean, f-second)

fun f-if(condition, if-true, if-false):
  t-value(condition)(if-true, if-false)
end

fun f-not(bool):
  f-if(bool, f-false, f-true)
end

fun f-or(bool1, bool2):
  f-if(bool1, f-true, bool2)
end

fun f-or-lazy(bool-exp1, bool-exp2):
  f-if(
    bool-exp1(),
    {(): f-true},
    bool-exp2)()
end

fun f-and(bool1, bool2):
  f-if(bool1, bool2, f-false)
end

fun f-and-lazy(bool-exp1, bool-exp2):
  f-if(
    bool-exp1(), 
    bool-exp2, 
    {(): f-false})()
end

fun f-xor(bool1, bool2):
  f-or(
    f-and(f-not(bool1), bool2),
    f-and(bool1, f-not(bool2)))
end

fun f-boolean-equal(bool1, bool2):
  f-or(
    f-and(bool1, bool2),
    f-not(f-or(bool1, bool2)))
end

fun m-boolean-tostring(bool):
  f-if(bool, "true", "false")
end

fun m-boolean-tobool(bool):
  f-if(bool, true, false)
end

######## List ########

f-list-empty = f-pair(f-none, f-true)

fun f-list-link(first, rest):
  f-pair(f-pair(first, rest), f-false)
end

fun f-list-is-empty(lis):
  f-pair-second(lis)
end

fun f-list-is-link(lis):
  f-not(f-pair-second(lis))
end

fun f-list-first(lis):
  f-pair-first(f-pair-first(lis))
end

fun f-list-rest(lis):
  f-pair-second(f-pair-first(lis))
end

######## Natural ########

f-natural-zero = t-make(t-natural, f-list-empty)
f-natural-one = t-make(t-natural, f-list-link(f-true, f-list-empty))

fun f-natural-equal(num1, num2):
  fun helper(shadow num1, shadow num2):
    f-or-lazy(
      # Both are empty lists, or
      {(): f-and(f-list-is-empty(num1), f-list-is-empty(num2))},
      {(): f-and-lazy(
          # The first elements match and the rests are equal
          {(): f-and(f-list-is-link(num1), f-list-is-link(num2))},
          {(): f-and-lazy(
              {(): f-boolean-equal(f-list-first(num1), f-list-first(num2))},
              {(): helper(f-list-rest(num1), f-list-rest(num2))})})})
  end
  
  helper(t-value(num1), t-value(num2))
end

fun f-natural-add(num1, num2):
  fun helper(shadow num1, shadow num2, carry):
    f-if(f-list-is-link(num1),
      {(): f-if(f-list-is-link(num2),
          # If both nums are positive
          {(): f-list-link(
              # Find current bit
              f-xor(f-xor(f-list-first(num1), f-list-first(num2)), carry), 
              # Find carry and recur
              helper(f-list-rest(num1), f-list-rest(num2), f-or(f-or(
                    f-and(f-list-first(num1), f-list-first(num2)), 
                    f-and(f-list-first(num1), carry)), 
                  f-and(f-list-first(num2), carry))))},
          # If one is positive
          {(): f-if(carry,
              # If carry, add on and recur
              {(): helper(num1, f-list-link(f-true, f-list-empty), f-false)},
              # Otherwise, just return rest of number
              {(): num1})()})()},
      {(): f-if(f-list-is-link(num2),
          # Redirect to If one is positive
          {(): helper(num2, num1, carry)},
          # If both are 0, handle carry
          {(): f-if(carry,
              {(): f-list-link(f-true, f-list-empty)},
              {(): f-list-empty})()})()})()
  end
  
  t-make(t-natural, helper(t-value(num1), t-value(num2), f-false))
end

fun f-natural-subtract(num1, num2):
  ...
end

fun f-natural-multiply(num1, num2):
  fun helper(shadow num1, shadow num2):
    f-if(f-list-is-empty(num2),
      # Anything times 0 is 0
      {(): t-value(f-natural-zero)},
      {(): t-value(f-natural-add(
            # Multiply the rest of the number
            t-make(t-natural, 
              helper(f-list-link(f-false, num1), f-list-rest(num2))),
            # And add on this part
            t-make(t-natural, 
              f-if(f-list-first(num2),
                {(): num1},
                {(): f-list-empty})())))})()
  end
  
  t-make(t-natural, helper(t-value(num1), t-value(num2)))
end

fun f-natural-square(num):
  f-natural-multiply(num, num)
end

fun f-natural-expt(num1, num2):
  fun helper(current-exp):
    f-if(
      f-list-is-empty(current-exp),
      {(): f-natural-one},
      {(): f-natural-multiply(
          f-natural-square(helper(f-list-rest(current-exp))),
          f-if(f-list-first(current-exp), num1, f-natural-one))})()
  end

  helper(t-value(num2))
end

fun m-natural-tonumber(num):
  fun helper(left):
    f-if(
      f-list-is-empty(left),
      {(): 0},
      {(): (2 * helper(f-list-rest(left))) 
          + f-if(f-list-first(left), 1, 0)})()
  end
  
  helper(t-value(num))
where:
  f-two = f-natural-add(f-natural-one, f-natural-one)
  f-three = t-make(t-natural, f-list-link(f-true, f-list-link(f-true, f-list-empty)))
  f-four = f-natural-multiply(f-two, f-two)
  f-five = f-natural-add(f-three, f-two)
  f-six = t-make(t-natural,
    f-list-link(f-false, f-list-link(f-true, f-list-link(f-true, f-list-empty))))
  f-seven = f-natural-add(f-natural-multiply(f-two, f-three), f-natural-one)
  f-eight = f-natural-expt(f-two, f-three)
  f-nine = f-natural-square(f-three)
  f-ten = f-natural-multiply(f-two, f-five)

  m-natural-tonumber(f-natural-zero) is 0
  m-natural-tonumber(f-natural-one) is 1
  map(m-natural-tonumber, [list:
      f-two, f-three, f-four,
      f-five, f-six, f-seven,
      f-eight, f-nine, f-ten])
    is range(2, 11)
  m-natural-tonumber(f-natural-expt(f-two, f-natural-expt(f-ten, f-three))) 
    is num-expt(2, num-expt(10, 3))
end

######## Integer ########

f-integer-zero = f-pair(f-natural-zero, f-pair(f-true, f-none))
f-integer-pos-one = f-pair(f-natural-one, f-pair(f-false, f-true))
f-integer-neg-one = f-pair(f-natural-one, f-pair(f-false, f-false))


