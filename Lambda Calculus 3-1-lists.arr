#|
   provide {
    f-lists-map : f-lists-map,
    f-lists-filter : f-lists-filter,
    f-lists-foldl : f-lists-foldl,
    f-lists-foldr : f-lists-foldr,
    f-lists-length : f-lists-length,
    f-lists-split-at : f-lists-split-at,
    f-lists-take : f-lists-take,
    f-lists-drop : f-lists-drop,
    f-lists-append : f-lists-append,
    f-lists-sort : f-lists-sort,
  } 
   end
|#
provide *

include my-gdrive("Lambda Calculus 3-0.arr")#, "15dBr61F16QLAUsVwkfkGhvZsF2kF_LM2")

#| 
  To add:
   - partition
   - all
   - any
   - reverse
   - get
   - set
   - range/range-by
   - repeat
   - find?
   - last?
   - same-length/longer-than/shorter-than?
   - push?
   - multi map, filter, etc.?
   - fold-while?
   - distinct?
   - take-while?
   - member no lol
   - remove no lol
|#

f-lists-map = 
  {(func): # Param: a function to map with
    f-r({(r-map):
        {(lis): # Param: a list to map onto
          f-if-lazy(f-is-empty(lis))(
            {(_): f-empty})(
            {(_): f-lzlink(func(f-lfirst(lis)))({(_): f-r(r-map)(f-lrest(lis))})})}})}

check "Map":
  fun do-map(func, lis):
    m-print-list(f-lists-map(func)(m-make-list(lis)))
  end
  
  do-map(_ + 3, [list: ])
    is [list: ]
  do-map(_ + 3, [list: 1, 2, 3, 4])
    is [list: 4, 5, 6, 7]
end

f-lists-filter = 
  {(func): # Param: a function to filter with
    f-r({(r-filter):
        {(lis): # Param: a list to filter
          f-if-lazy(f-is-empty(lis))(
            {(_): f-empty})(
            {(_): f-if-lazy(func(f-lfirst(lis)))(
                {(_): f-lzlink(f-lfirst(lis))({(_): f-r(r-filter)(f-lrest(lis))})})(
                {(_): f-r(r-filter)(f-lrest(lis))})})}})}

check "Filter":
  fun do-filter(func, lis):
    m-print-list(f-lists-filter({(val): m-make-bool(func(val))})(m-make-list(lis)))
  end
  
  do-filter(_ < 0, [list: ])
    is [list: ]
  do-filter(_ < 0,  [list: 1, 2, 3, 4])
    is [list: ]
  do-filter(_ < 0, [list: -2, -1, 0, 1, 2, 1, 0, -1, -2])
    is [list: -2, -1, -1, -2]
  do-filter(_ < 0, [list: -4, -3, -2, -1])
    is [list: -4, -3, -2, -1]
end

f-lists-foldl = 
  {(func): # Param: a function to fold with
    f-r({(r-foldl):
        {(base): {(lis): # Params: a base value and list to fold over
            f-if-lazy(f-is-empty(lis))(
              {(_): base})(
              {(_): f-r(r-foldl)(func(f-lfirst(lis))(base))(f-lrest(lis))})}}})}

check "Foldl":
  fun do-foldl(func, base, lis):
    f-lists-foldl(
      {(ele): {(acc): func(ele, acc)}})(
      base)(
      m-make-list(lis))
  end

  do-foldl(_ + _, [list: ], [list: ])
    is [list: ]
  do-foldl(_ + _, [list: ], [list: 
      [list: 1, 2, 3]])
    is [list: 1, 2, 3]
  do-foldl(_ + _, [list: ], [list: 
      [list: 1, 2, 3],
      [list: 4, 5, 6]])
    is [list: 4, 5, 6, 1, 2, 3]
  do-foldl(_ + _, [list: 0], [list: 
      [list: 1, 2, 3],
      [list: 4, 5, 6],
      [list: 7, 8, 9]])
    is [list: 7, 8, 9, 4, 5, 6, 1, 2, 3, 0]
end

f-lists-foldr = 
  {(func): # Param: a function to fold with
    f-r({(r-foldr):
        {(base): {(lis): # Params: a base value and list to fold over
            f-if-lazy(f-is-empty(lis))(
              {(_): base})(
              {(_): func(f-lfirst(lis))(f-r(r-foldr)(base)(f-lrest(lis)))})}}})}

check "Foldr":
  fun do-foldr(func, base, lis):
    f-lists-foldr(
      {(ele): {(acc): func(ele, acc)}})(
      base)(
      m-make-list(lis))
  end

  do-foldr(_ + _, [list: ], [list: ])
    is [list: ]
  do-foldr(_ + _, [list: ], [list: 
      [list: 1, 2, 3]])
    is [list: 1, 2, 3]
  do-foldr(_ + _, [list: ], [list: 
      [list: 1, 2, 3],
      [list: 4, 5, 6]])
    is [list: 1, 2, 3, 4, 5, 6]
  do-foldr(_ + _, [list: 0], [list: 
      [list: 1, 2, 3],
      [list: 4, 5, 6],
      [list: 7, 8, 9]])
    is [list: 1, 2, 3, 4, 5, 6, 7, 8, 9, 0]
end

f-lists-length = 
  {(lis): # Param: a list to find the length of
    f-lists-foldl({(_): {(acc): f-succ(acc)}})(f-zero)(lis)}

#|
   Simpler but harder to understand version:
   f-lists-length = f-lists-foldl({(_): f-succ})(f-zero)
|#

check "Length":
  fun get-length(lis):
    m-print-num(f-lists-length(m-make-list(lis)))
  end
  
  get-length(range(0, 0)) is 0
  get-length(range(0, 1)) is 1
  get-length(range(0, 10)) is 10
end

f-lists-split-at = f-r({(r-split-at):
    {(n): {(lis): # Params: an index to take/drop and a list to split-at
        f-if-lazy(f-is-zero(n))(
          # part(0, lis) -> (empty, lis)
          {(_): f-pair(f-empty)(lis)})(
          # part(n, lis) -> recur part(n - 1, rest(lis)), and link first(lis) to the prefix
          {(_): {(part): f-pair(f-link(f-lfirst(lis))(f-pfirst(part)))(f-psecond(part))}(f-r(r-split-at)(f-pred(n))(f-lrest(lis)))})}}})

check "Partition":
  fun make-split-at(n, lis):
    part = f-lists-split-at(m-make-num(n))(m-make-list(lis))
    [list: m-print-list(f-pfirst(part)), m-print-list(f-psecond(part))]
  end
  
  make-split-at(0, range(0, 0)) is [list: range(0, 0), range(0, 0)]
  make-split-at(0, range(0, 5)) is [list: range(0, 0), range(0, 5)]
  make-split-at(2, range(0, 5)) is [list: range(0, 2), range(2, 5)]
  make-split-at(5, range(0, 5)) is [list: range(0, 5), range(5, 5)]
end

f-lists-take = 
  {(n): {(lis): # Params: a number of elements to take and a list to take from
      f-pfirst(f-lists-split-at(n)(lis))}}

f-lists-drop = 
  {(n): {(lis): # Params: a number of elements to take and a list to take from
      f-psecond(f-lists-split-at(n)(lis))}}

check "Take and Drop":
  fun do-take(n, lis):
    m-print-list(f-lists-take(m-make-num(n))(m-make-list(lis)))
  end
  
  fun do-drop(n, lis):
    m-print-list(f-lists-drop(m-make-num(n))(m-make-list(lis)))
  end
  
  do-take(0, range(0, 0)) is range(0, 0)
  do-take(0, range(0, 5)) is range(0, 0)
  do-take(2, range(0, 5)) is range(0, 2)
  do-take(5, range(0, 5)) is range(0, 5)
  
  do-drop(0, range(0, 0)) is range(0, 0)
  do-drop(0, range(0, 5)) is range(0, 5)
  do-drop(2, range(0, 5)) is range(2, 5)
  do-drop(5, range(0, 5)) is range(5, 5)
end

f-lists-append = f-r({(r-append):
    {(lis1): {(lis2): # Params: two lists to append
        f-if-lazy(f-is-empty(lis1))(
          {(_): lis2})(
          {(_): f-lzlink(f-lfirst(lis1))({(_): f-r(r-append)(f-lrest(lis1))(lis2)})})}}})

check "Append":
  fun do-append(lis1, lis2):
    m-print-list(f-lists-append(m-make-list(lis1))(m-make-list(lis2)))
  end
  
  do-append([list: ], [list: ]) is [list: ]
  do-append([list: ], [list: 1, 2, 3]) is [list: 1, 2, 3]
  do-append([list: 1, 2, 3], [list: ]) is [list: 1, 2, 3]
  do-append([list: 1, 2, 3], [list: 4, 5, 6]) is [list: 1, 2, 3, 4, 5, 6]
  end

h-sort-merge = 
  {(lt): # Param: a less-than operator
    f-r({(merge): 
        {(lis1): {(lis2): # Params: two sorted lists to merge together
            f-if-lazy(f-is-empty(lis1))(
              # If lis1 is empty, return lis2
              {(_): lis2})(
              {(_): f-if-lazy(f-is-empty(lis2))(
                  # If lis2 is empty, return lis1
                  {(_): lis1})(
                  {(_): f-if-lazy(lt(f-lfirst(lis2))(f-lfirst(lis1)))(
                      # If f(lis2) < f(lis1), grab f(lis2)
                      {(_): f-link(f-lfirst(lis2))(f-r(merge)(lis1)(f-lrest(lis2)))})(
                      # Otherwise, grab f(lis1)
                      {(_): f-link(f-lfirst(lis1))(f-r(merge)(f-lrest(lis1))(lis2))})})})}}})}

check "Merge":
  fun do-merge(lt, lis1, lis2):
    m-print-list(h-sort-merge(
        {(a): {(b): m-make-bool(lt(a, b))}})(
        m-make-list(lis1))(
        m-make-list(lis2)))
  end
  
  do-merge(_ < _, [list: ], [list: ])
    is [list: ]
  do-merge(_ < _, [list: 1, 3, 5], [list: ])
    is [list: 1, 3, 5]
  do-merge(_ < _, [list: ], [list: 2, 4, 6])
    is [list: 2, 4, 6]
  do-merge(_ < _, [list: 1, 3, 5], [list: 2, 4, 6])
    is [list: 1, 2, 3, 4, 5, 6]
  do-merge(_ < _, [list: 1, 3, 5], [list: 1, 3, 5])
    is [list: 1, 1, 3, 3, 5, 5]
end

f-lists-sort = 
  {(lt): # Param: a less-than operator
    f-r({(r-sort): 
        {(lis): # Param: a list to sort
          f-if-lazy(f-lessthan(f-lists-length(lis))(f-two))(
            # If we have a list of size 0 or 1, just return to avoid infinite recursion
            {(_): lis})(
            # Otherwise, split-at it in half, sort each half, and merge
            {(_): f-bind(f-lists-split-at(f-div(f-lists-length(lis))(f-two))(lis))({(part): 
                  h-sort-merge(lt)(
                    f-r(r-sort)(f-pfirst(part)))(
                    f-r(r-sort)(f-psecond(part)))})})}})}

check "Sort":
  fun do-sort(lt, lis):
    m-print-list(f-lists-sort(
        {(a): {(b): m-make-bool(lt(a, b))}})(
        m-make-list(lis)))
  end
  
  do-sort(_ < _, [list: ])
    is [list: ]
  do-sort(_ < _, [list: 1])
    is [list: 1]
  do-sort(_ < _, [list: 1, 2])
    is [list: 1, 2]
  do-sort(_ < _, [list: 2, 1])
    is [list: 1, 2]
  do-sort(_ < _, [list: 1, 2, 3, 4, 5])
    is [list: 1, 2, 3, 4, 5]
  do-sort(_ < _, [list: 5, 4, 3, 2, 1])
    is [list: 1, 2, 3, 4, 5]
  do-sort(_ < _, [list: 5, 3, 1, 2, 4])
    is [list: 1, 2, 3, 4, 5]
  do-sort(_ < _, [list: 1, 3, 5, 1, 3, 5])
    is [list: 1, 1, 3, 3, 5, 5]
end
#m = m-make-list-of-num
#a = m([list: 1, 5, 2, 4, 3])
#b = f-lists-sort(a)
#c = m-print-list-of-num(b)