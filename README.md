# Lambda-Calculus-Pyret
A library of Lambda Calculus functions written in Pyret. Done with own designs (may be similar/same to online designs, but done without resources).

## Version Numbering
Version x.y depends on version x.{y - 1}; Version x.0 is a full restart.

 - Version 1.y was a first attempt without expectations for where I would go with it.
 - Version 2.y was created with the intention of trying out a typed lambda calculus with arbitrary precision float calculus.
 - Version 3.y will be focused on making a language with libraries (with no explicit recursion!) and more exploration of programming language principles, including laziness and saving computation.

## To Run
Import Lambda Calculus 3 in code.pyret.org:
 - Base library: include shared-gdrive("Lambda Calculus 3-0.arr", "19RJbhVGiMtDB87tYmGnP9nhB9rfwE2hc")
 - Lists library: include shared-gdrive("Lambda Calculus 3-1-lists.arr", "1D6QR70U-EzI74qIwi7PuourVcEuzRUa3")
or go to published version: 
[https://code.pyret.org/editor#share=1AgzgWOMf287CiPbG8Tkf26gsS_QuKBci&v=8934c12](https://code.pyret.org/editor#share=1AgzgWOMf287CiPbG8Tkf26gsS_QuKBci&v=8934c12 "Lambda Calculus 3 by Thomas Del Vecchio")

## Naming scheme
 - Purely functional functions:
   - `f-` means a main function
   - `h-` means a helper function (should not be called from outside library)
   - `r-` means a "parameter" that is used for recusion (see Strategies/Y-combinator)
 - Non-pure functions:
   - `m-` means a meta-function
     - Often used for transferring between Pyret data and Lambda Calculus functions

## Strategies
### Lambda Calculus Things
 - Y-combinator
   - In all honesty, I still have not figured out how this works in the notation found throughout the internet, but mine is `f-r`.
   - Use:
```pyret
my-func = 
  {(arg1): # Param: a value that persists throughout recursion; does not need to be passed back in.
    f-r({(r-my-func): 
      {(arg2): {(arg3): # Params: values which change throughout recursion; need to be re-passed in.
        do-stuff(f-r(r-my-func)(new-arg2)(new-arg3))}}})}
```
 - Name binding
   - I want to limit binding to names only to the functions themselves (if that makes any sense). In theory, these bindings in the full program (as long as none are recursive) can be written with the same technique as below.
   - For binding within functions, I use `f-bind`, which just let's me organize values. The idea of it is, for any value I want to bind to a name, I make a lambda with that name as a parameter, and call that lambda with the computed value.
   - Use:
```pyret
my-func =
  {(arg):
    f-bind(bind-value)({(bind-name): 
      do-stuff(bind-name)(bind-name)(bind-name)})}
```
 - Thunks and multi-argument functions
   - I am designing this iteration to only allow lambdas with exactly one argument.
   - Multi-argument functions are implemented with currying.
   - Thunks are implemented with a dummy argument, and by calling it with `f-none`.
     - `f-none` is a self-producing "thunk" that is used for thunks and also for places where having a value doesn't make sense (see Natural Number System).
     
### Natural Number System
 - Rather than using Church Numerals, I decided to use my own strategy loosely similar to ZF.
 - A number is a pairing of the previous number with a boolean telling whether it is zero or not.
   - To maintain consistency in shape, zero is then a pair of `f-none` and `f-true`.
 - This strategy makes `f-succ` and `f-pred` easy to write in constant time, and seems more intuitive in my opinion.
 - Basic arithmetic operations are added for natural numbers, but these are limited by nature of natural numbers, so a different set of operations will be written when more complicated number structures are created.

## To Do
 - Add more intricate math library
 - Fix up naming scheme

## Bugs
 - None, but needs more testing
