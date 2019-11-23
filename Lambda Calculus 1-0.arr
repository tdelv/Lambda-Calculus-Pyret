################################################
################### GLOSSARY ###################
################################################
### 1) Meta helper functions                 ###
###   a) mapply(f, val, n)                   ###
### 2) Pairs                                 ###
###   a) ffirst(a, b)                        ###
###   a) fsecond(a, b)                       ###
###   a) fmake-pair(a, b)                    ###
###   a) fpair-first(a, b)                   ###
###   a) fpair-second(a, b)                  ###
### 3) Booleans                              ###
###   a) ftrue                               ###
###   b) ffalse                              ###
###   c) fif(bool, true-val, false-val)      ###
###   d) fnot(a)                             ###
###   e) fand(a, b)                          ###
###   f) fand-lazy(a, b)                     ###
###   g) ffor(a, b)                          ###
###   h) ffor-lazy(a, b)                     ###
### 4) Natural Numbers                       ###
###   a) fzero                               ###
###   b) fis-zero(num)                       ###
###   c) fsuccessor(num)                     ###
###   d) fpredecessor(num)                   ###
###   e) fadd(num1, num2)                    ###
###   f) fmultiply(num1, num2)               ###
###   g) fnum-equals(num1, num2)             ###
###   h) fnum-less(num1, num2)               ###
###   i) fnum-lessequal(num1, num2)          ###
###   j) fnum-greater(num1, num2)            ###
###   k) fnum-greaterequal(num1, num2)       ###
###   l) mmake-num(n)                        ###
################################################
################################################
################################################

######## Meta helper functions ########

fun mapply(f, val, n):
  doc: ```Finds f^n(val).```
  if n == 0:
    val
  else:
    mapply(f, f(val), n - 1)
  end
end

######## Pairs ########

fun ffirst(a, b):
  doc: ```Returns the first of the two arguments.```
  a
end

fun fsecond(a, b):
  doc: ```Returns the second of the two arguments.```
  b
end

fun fmake-pair(a, b):
  doc: ```Makes a pair of the two arguments, which is a function that takes
       ffirst or fsecond to choose which of the pair to retrieve.```
  lam(which):
    which(a, b)
  end
end

fun fpair-first(pair):
  doc: ```Gets the first from a pair.```
  pair(ffirst)
end

fun fpair-second(pair):
  doc: ```Gets the second from a pair.```
  pair(fsecond)
end

check "Pairs Functions":
  fpair-first(fmake-pair(1, 2)) is 1
  fpair-second(fmake-pair(1, 2)) is 2
end

######## Booleans ########

ftrue = ffirst
ffalse = fsecond

fun fif(bool, true-val, false-val):
  doc: ```Bool will choose which val to return.```
  bool(true-val, false-val)
end

fun fnot(a):
  doc: ```Not```
  fif(a, ffalse, ftrue)
end

fun fand(a, b):
  doc: ```And```
  fif(a, b, ffalse)
end

fun fand-lazy(a, b):
  doc: ```Evaluates fand lazily. Given two thunks, runs the first, and only
       runs the second if the first results in ftrue.```
  fif(a(), b, {(): ffalse})()
end

fun ffor(a, b):
  doc: ```Or```
  fif(a, ftrue, b)
end
  
fun ffor-lazy(a, b):
  doc: ```Evaluates ffor lazily. Given two thunks, runs the first, and only
       runs the second if the first results in ffalse.```
  fif(a(), {(): ftrue}, b)()
end

check "Boolean Functions":
  checker = fif(_, true, false)

  ffor(ftrue, ftrue)
    satisfies checker
  ffor(ftrue, ffalse)
    satisfies checker
  ffor(ffalse, ftrue)
    satisfies checker
  fnot(ffor(ffalse, ffalse))
    satisfies checker


  fand(ftrue, ftrue)
    satisfies checker
  fnot(fand(ftrue, ffalse))
    satisfies checker
  fnot(fand(ffalse, ftrue))
    satisfies checker
  fnot(fand(ffalse, ffalse))
    satisfies checker
end

######## Natural Numbers ########

fzero = fmake-pair(ftrue, ftrue)

fun fis-zero(num):
  doc: ```The second item in the pair tells whether the number is fzero.```
  fpair-second(num)
end

fun fsuccessor(num):
  doc: ```The successor of a number is a pair of the previous number and
       ffalse (since the successor of a number is not 0).```
  fmake-pair({(): num}, ffalse)
end

fun fpredecessor(num):
  doc: ```The predecessor of a number is just the first of its pair.
       Precondition: num is not fzero.```
  fpair-first(num)()
end

# Natural Number Math

fun fadd(num1, num2):
  doc: ```Adds the two numbers by repeatedly incrementing num1 and 
       decrementing num2 until num2 is fzero.```
  fif(
    fis-zero(num2), 
    {(): num1}, 
    {(): fadd(fsuccessor(num1), fpredecessor(num2))})()
end

fun fmultiply(num1, num2):
  doc: ```Adds the two numbers by repeatedly adding num1 and
       decrementing num2 until num2 is fzero.```
  fif(
    fis-zero(num2), 
    {(): fzero}, 
    {(): fadd(num1, fmultiply(num1, fpredecessor(num2)))})()
end

# Natural Number Comparison

fun fnum-equals(num1, num2):
  doc: ```Checks if num1 == num2 by decrementing each until
       one (or both) reaches fzero, at which point checks both are fzero.```
  fif(
    ffor(fis-zero(num1), fis-zero(num2)), 
    {(): fand(fis-zero(num1), fis-zero(num2))}, 
    {(): fnum-equals(fpredecessor(num1), fpredecessor(num2))})()
end

fun fnum-less(num1, num2):
  doc: ```Cheecks if num1 < num2 by decrementing each until
       one reaches fzero, at which point checks num2 is not fzero.```
  fif(fis-zero(num1),
    {(): fnot(fis-zero(num2))},
    {(): fif(fis-zero(num2),
        {(): ffalse},
        {(): fnum-less(fpredecessor(num1), fpredecessor(num2))})()})()
end

fun fnum-lessequal(num1, num2):
  doc: ```Checks if num1 <= num2 by checking num1 == num2 or num1 < num2.```
  ffor(
    fnum-equals(num1, num2),
    fnum-less(num1, num2))
end

fun fnum-greater(num1, num2):
  doc: ```Cheecks if num1 > num2 by decrementing each until
       one reaches fzero, at which point checks num1 is not fzero.```
  fif(fis-zero(num2),
    {(): fnot(fis-zero(num1))},
    {(): fif(fis-zero(num1),
        {(): ffalse},
        {(): fnum-greater(fpredecessor(num2), fpredecessor(num1))})()})()
end

fun fnum-greaterequal(num1, num2):
  doc: ```Checks if num1 >= num2 by checking num1 == num2 or num1 > num2.```
  ffor(
    fnum-equals(num1, num2),
    fnum-greater(num1, num2))
end

# Natural Number Meta Functions

fun mmake-num(n):
  doc: ```Makes the number n using fsuccessor on fzero.```
  mapply(fsuccessor, fzero, n)
end

check "Natural Number Functions":
  checker = fif(_, true, false)

  fis-zero(fzero) 
    satisfies checker
  fnot(fis-zero(mmake-num(1))) 
    satisfies checker
  fnum-equals(fpredecessor(fsuccessor(mmake-num(8))), mmake-num(8)) 
    satisfies checker
  fnum-equals(mmake-num(10), fadd(mmake-num(4), mmake-num(6))) 
    satisfies checker
  fnum-equals(mmake-num(24), fmultiply(mmake-num(4), mmake-num(6))) 
    satisfies checker
end

######## Lists ########

fempty-list = fmake-pair(ftrue, ftrue)

fun fis-empty-list(l):
  doc: ```The second item in the pair tells if the list is empty.```
  fpair-second(l)
end

fun fis-link(l):
  doc: ```The second item in the pair tells if the list is empty.```
  fnot(fpair-second(l))
end

fun flink(ele, l):
  doc: ```The first value of a link is a pair of the first and the rest of
       the list; the second value of a link is ffalse as it is not empty.```
  fmake-pair(fmake-pair(ele, l), ffalse)
end

fun flist-first(l):
  doc: ```Retrieves the first value in a list.```
  fpair-first(fpair-first(l))
end

fun flist-rest(l):
  doc: ```Retrieves the rest of the list.
       Precondition: l is not empty.```
  fpair-second(fpair-first(l))
end

fun flist-equals(l1, l2):
  doc: ```Checks if two lists OF NUMBERS are equal. Makes sure that if one is
       empty, both are empty, and otherwise compare and recur.```
  fif(ffor(fis-empty-list(l1), fis-empty-list(l2)),
    {(): fand(fis-empty-list(l1), fis-empty-list(l2))},
    {(): fand(fnum-equals(flist-first(l1), flist-first(l2)),
        flist-equals(flist-rest(l1), flist-rest(l2)))})()
end

check "List Functions":
  checker = fif(_, true, false)

  fis-empty-list(fempty-list)
    satisfies checker
  fnot(fis-link(fempty-list))
    satisfies checker

  fnot(fis-empty-list(flink(fzero, fempty-list)))
    satisfies checker
  fis-link(flink(fzero, fempty-list))
    satisfies checker

  flist-equals(
    flink(mmake-num(0), flink(mmake-num(1), flink(mmake-num(2), fempty-list))),
    flink(mmake-num(0), flink(mmake-num(1), flink(mmake-num(2), fempty-list))))
    satisfies checker

  fnot(flist-equals(
      flink(mmake-num(0), flink(mmake-num(1), fempty-list)),
      flink(mmake-num(0), flink(mmake-num(2), fempty-list))))
    satisfies checker

  fnot(flist-equals(
      flink(mmake-num(0), flink(mmake-num(2), fempty-list)),
      flink(mmake-num(0), fempty-list)))
    satisfies checker
end

# My version of meta helper functions

fun fapply(f, val, n):
  doc: ```mapply written only with pure functions.```
  fif(fis-zero(n),
    {(): val},
    {(): fapply(f, f(val), fpredecessor(n))})()
end
