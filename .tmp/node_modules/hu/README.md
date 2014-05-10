# hu [![Build Status](https://secure.travis-ci.org/h2non/hu.png?branch=master)][travis] [![NPM version](https://badge.fury.io/js/hu.png)][npm]

<table>
<tr>
<td><b>Stage</b></td><td>beta</td>
</tr>
<tr>
<td><b>Funny</b></td><td>true</td>
</tr>
</table>

## About

**hu** is a functional-oriented utility helper library
inspired by haskell's prelude and lodash/underscore

Unlike other well-known libraries such as Lodash or Sugar.js, hu only provides a reduced but generic set of most common and useful functions.
It aims to be a lightweight and small library which can be easily embedded as a part of an application, library or framework without making noise

hu library works well in ES5 compliant engines.
Most of its functions are curried

## Features

- Complete type checking helpers
- Array and objects processors and transformers
- Functional-oriented helpers (curry, partial, compose, memoize...)
- String manipulation helpers
- Equality comparison functions
- Runs in node and browsers
- Well tested with 100% of coverage

## Installation

#### Node.js

```bash
$ npm install hu --save
```

#### Browser

Via Bower package manager
```bash
$ bower install hu
```

Or loading the script remotely (just for testing or development)
```html
<script src="//rawgithub.com/h2non/hu/master/hu.js"></script>
```

## Environments

It works properly in any ES5 compliant environment, however just for
a formalism, those environments are:

- Node.js
- Chrome >= 5
- Firefox >= 3
- Safari >= 5
- Opera >= 12
- IE >= 9

## Why hu?

### Motivation

Functional programming tendency has grown (again) in the latest years.
This paradigm, unlike others that may be more totalitarian and extended, forces a radical re-thinking in the way that programmers design and implement software

Functional programming thinking and conversion is not easy to apply,
but it's really a quite attractive and funny paradigm,
which helps to solve the same problems in a theoretically
and conceptually clean (and sometimes more efficiently) way

### Rationale

A good approach to learn and apply functional programming principles
is creating a functional-oriented library that assists by itself to
do functional programming

In fact, hu was created to define a real scenario to do funny experiments
with some pure functional programming principles

It's completely written in [Wisp][wisp], a homoiconic Clojure-like language, which compiles into plain JavaScript that supports s-expressions and macros, allowing to extend the compiler features with the user’s own code

### So... why JavaScript?

JavaScript is an ubiquitous, well-extended, multi-purpose and multi-paradigm cool language with which you can do a lot of funny things

Yes, I know, JavaScript is not a pure functional language, however
its natural extensibility and meta-programming features allow to apply different paradigms to it and today there are a lot of languages that transpile into JavaScript that help providing a powerful syntax sugar and more features,
like in this case using Wisp

### Challenges

hu is implemented keeping in mind the following “ambitious” functional focused goals:

- Assume it's a first-class function only language
- Pure functions as a norm
- Immutability (when it's possible)
- Avoid assignment, remove side-effects (when it's possible)
- Tend to recursion instead of loops
- Tend to high-order functions
- Tend to functional composition
- Tend to continuation-passing style
- Exploit subroutines (like tail recursion call)
- Exploit memorization (currying, partial, caching...)
- Exploit combinators
- Macros are a great thing, use&love it

## API

- Type checking
  - [isBool](#isboolvalue)
  - [isNumber](#isnumbervalue)
  - [isFinite](#isfinitevalue)
  - [isNaN](#isnanvalue)
  - [isString](#isstringvalue)
  - [isSymbol](#issymbolvalue)
  - [isFunction](#isfunctionvalue)
  - [isDate](#isdatevalue)
  - [isRegExp](#isregexpvalue)
  - [isArray](#isarrayvalue)
  - [isObject](#isobjectvalue)
  - [isPlainObject](#isplainobjectvalue)
  - [isError](#iserrorvalue)
  - [isElement](#iselementvalue)
  - [isArgs](#isargsvalue)
  - [isUndef](#isundefvalue)
  - [isNull](#isnullvalue)
  - [isEmpty](#isemptyvalue)
  - [notEmpty](#notemptyvalue)
  - [isMutable](#ismutablevalue)
  - [isPrimitive](#isprimitivevalue)
  - [isIterable](#isiterablevalue)
- Strings
  - [subs](#subsstr-start-end)
  - [lines](#linesstr)
  - [unlines](#unlinesarr)
  - [words](#wordsstr)
  - [unwords](#unwordsarr)
  - [chars](#charsstr)
  - [unchars](#uncharsarr)
  - [char](#charnumber)
  - [reverse](#reversestr)
  - [repeat](#repeatnumber-str)
  - [escape](#escapestr)
- Numbers
  - [odd](#oddnumber)
  - [even](#evennumber)
  - [lower](#lowerx-y)
  - [higher](#higherx-y)
  - [max](#maxnumbers)
  - [min](#minnumbers)
  - [inc](#incnumber)
  - [dec](#decnumber)
  - [signum](#signumnumber)
  - [isNegative](#isnegativenumber)
  - [negate](#negatenumber)
  - [recip](#recipnumber)
  - [div](#divnumber)
  - [max](#maxnumbers-1)
  - [min](#minnumbers-1)
  - [abs](#absnumber)
  - [round](#roundnumber)
  - [random](#random)
  - [floor](#floornumber)
  - [sin](#sinnumber)
  - [tan](#tannumber)
  - [cos](#cosnumber)
  - [asin](#asinnumber)
  - [atan](#atannumber)
  - [atan2](#atan2number)
  - [ceil](#ceilnumber)
  - [exp](#expnumber)
  - [sqrt](#sqrtnumber)
  - [PI](#pi)
- Arrays
  - [inArray](#inarrayarr-element)
  - [head](#headarr)
  - [tail](#tailarr)
  - [last](#lastarr)
  - [initial](#initialarr)
- Objects
  - [has](#hasobj-property)
  - [keys](#keysobj)
  - [vals](#valsobj)
  - [keyValues](#keyvaluesobj)
  - [toObject](#toobjectobj)
  - [extend](#extendtarget-origins)
  - [mixin](#mixintarget-origins)
  - [map](#mapobj-function)
  - [filter](#filterobj-function)
  - [clone](#cloneobject)
  - [merge](#mergex-y)
- Collections
  - [each](#eachobj-function)
  - [size](#sizeobj)
  - [compact](#compactobj)
- Functions
  - [constant](#constantvalue)
  - [apply](#applyfn-args)
  - [bind](#bindfn-ctx)
  - [partial](#partialfn--partialargs-)
  - [curry](#curryfn--ctx-)
  - [compose](#composefn)
  - [memoize](#memoizefn-resolver)
  - [wrap](#wrapfn-wrapperfn--args-)
  - [once](#oncefn)
  - [times](#timesfn-number)
  - [defer](#deferfn-ms--args-)
  - [debounce](#debouncefn-ms--args-)
- Equality
  - [isEqual](#isequalx-y)
  - [isPatternEqual](#ispatternequalx-y)
  - [isDateEqual](#isdateequalx-y)
  - [isArrayEqual](#isarrayequalx-y)
  - [isObjectEqual](#isobjectequalx-y)
- Miscellaneous
  - [log](#logmsg)
  - [isBrowser](#isbrowser)
  - [noop](#noop)
  - [now](#now)
  - [_global](#_global)

### Overview example

JavaScript Harmony (ES6)
```js
var { log, filter, even, inc } = require('hu')

log(map(filter({a: 1, b: 2}, even), inc))
// → { b: 3 }
```

Or with the funny LiveScript
```livescript
(a: 1, b: 2)
  |> filter _, even
  |> map _, inc
  |> log
```

### Type checking

#### isBool(value)
Return: `boolean` | Alias: `isBoolean`

Checks if the given value is a boolean type

#### isNumber(value)
Return: `boolean`

Checks if the given value is a number type

#### isFinite(value)
Return: `boolean`

Checks if the given value is a finite number,
or it can be coerced into it

#### isNaN(value)
Return: `boolean`

Is it NaN (not a number)?
More accurate than the native isNaN function

#### isString(value)
Return: `boolean`

Checks if the given value is a string type

#### isSymbol(value)
Return: `boolean`

Checks if the given value is a symbol type

#### isFunction(value)
Return: `boolean` | Alias: `isFn`

Checks if the given value is a function type

#### isDate(value)
Return: `boolean`

Checks if the given value is a date type

#### isRegExp(value)
Return: `boolean` | Alias: `isPattern`

Checks if the given value is a regexp type

#### isArray(value)
Return: `boolean`

Checks if the given value is an array type

#### isObject(value)
Return: `boolean`

Checks if the given value is an object type

#### isPlainObject(value)
Return: `boolean`

Checks if the given value is a native object type (it was createdd by the Object native constructor)

#### isError(value)
Return: `boolean`

Checks if the given value is an error type

#### isElement(value)
Return: `boolean`

Checks if the given value is a DOM element object instance

#### isArgs(value)
Return: `boolean` | Alias: `isArguments`

Checks if the given value is an arguments object

#### isUndef(value)
Return: `boolean` | Alias: `isUndefined`

Checks if the given value is a undefined, void o null type

#### isNull(value)
Return: `boolean`

Checks if the given value is a null type

#### isEmpty(value)
Return: `boolean`

Checks if the given value is empty.
Arrays, strings, or arguments objects with a length of 0 and objects with no own enumerable properties are considered empty values

#### notEmpty(value)
Return: `boolean` | Alias: `isNotEmpty`

Checks if the given value is not empty

#### isMutable(value)
Return: `boolean`

Checks if the given value is a mutable data type.
Objects, arrays, date objects, arguments objects and functions are considered mutable data types

#### isPrimitive(value)
Return: `boolean`

Checks if the given value is a primitive value type.
Strings, numbers, booleans, symbols and null are considered primitives values

#### isIterable(value)
Return: `boolean` | Alias: `canIterate`

Checks if the given value can be iterated.
Objects, arrays, and arguments objects are considered iterables data types

### Strings

#### subs(str, start, end)
Return: `string`

Extract characters from the given string

#### lines(str)
Return: `array`

Split the given string by end of line tokens

#### unlines(arr)
Return: `string`

Join the given array into a string separated by
end line token

#### words(str)
Return: `array`

Returns an array of words (spaces separated)

#### unwords(arr)
Return: `string`

Join words of the given array into a string spaces separated

#### chars(str)
Return: `array`

Return an array of characters of the given string

#### unchars(arr)
Return: `string`

Join the strings of the given array

#### char(number)
Return: `string`

Return the given unicode number into his
equivalent character

#### reverse(str)
Return: `string`

Reverse characters of the given string

#### repeat(number, str)
Return: `string`

Repeat the given string

#### escape(str)
Return: `string`

Converts the characters &, <, >, ", and ' in the given string
to their corresponding HTML entities

### Numbers

#### odd(number)
Return: `boolean` | Alias: `isOdd`

Returns `true` if the given number is odd

#### even(number)
Return: `boolean` | Alias: `isEven`

Returns `true` if the given number is even

#### lower(x, y)
Return: `boolean` | Alias: `isLower` | Curried: `true`

Returns `true` if x it's lower than y

#### higher(x, y)
Return: `boolean` | Alias: `isHigher` | Curried: `true`

Returns `true` if x it's lower than y

#### max(...numbers)
Return: `number`

Returns the number with the highest value

#### min(...numbers)
Return: `number`

Returns the number with the lower value

#### inc(number)
Return: `number`

Increment the given value

#### dec(number)
Return: `number`

Decrement the given value

#### signum(number)
Return: `number`

Takes a number and returns either -1, 0,
or 1 depending on the sign of the number

#### isNegative(number)
Return: `boolean`

Returns `true` if the given number is negative

#### negate(number)
Return: `number`

The negation of the given number

#### recip(number)
Return: `number`

One over the number: ie 1 / x

#### div(number)
Return: `number`

Division truncated down toward negative infinity

#### max(...numbers)
Return: `number`

Returns the largest of zero or more numbers

#### min(...numbers)
Return: `number`

Returns the smallest of zero or more numbers

#### abs(number)
Return: `number`

Returns the absolute value of a number

#### round(number)
Return: `number`

Returns the value of a number rounded to the nearest integer

#### random()
Return: `number`

Returns a pseudo-random number between 0 and 1

#### floor(number)
Return: `number`

Returns the largest integer less than or equal to a number

#### sin(number)
Return: `number`

Returns the sine of a number

#### tan(number)
Return: `number`

Returns the tangent of a number

#### cos(number)
Return: `number`

Returns the cosine of a number

#### asin(number)
Return: `number`

Returns the arcsine of a number

#### atan(number)
Return: `number`

Returns the arctangent of a number

#### atan2(number)
Return: `number`

Returns the cosine of a number

#### ceil(number)
Return: `number`

Returns the smallest integer greater than or equal to a number

#### exp(number)
Return: `number`

Returns Ex, where x is the argument, and E is Euler's
constant (2.718...), the base of the natural logarithm

#### sqrt(number)
Return: `number`

Returns the positive square root of a number

#### PI
Type: `number`

Ratio of the circumference of a circle to
its diameter, approximately 3.14159

### Arrays

#### inArray(arr, element)
Return: `boolean` | Curried: `true`

Checks if an element exists in the given array

#### head(arr)
Return: `mixed` | Alias: `first`

First item of the given array

```js
hu.head([1, 2, 3]) // → 1
```

#### tail(arr)
Return: `array` | Alias: `rest`

Everything but the first item of the list

```js
hu.tail([1, 2, 3]) // → [2, 3]
```

#### last(arr)
Return: `mixed` | Alias: `end`

The last item of the list

```js
hu.last([1, 2, 3]) // → 3
```

#### initial(arr)
Return: `array`

Everything but the last item of the list

```js
hu.initial([1, 2, 3]) // → [1, 2]
```

### Objects

#### has(obj, property)
Return: `boolean`

Checks if the specified property name exists as a
own property of the given object

```js
hu.has({a: true}, 'a') // → true
```

#### keys(obj)
Return: `array`

Returns a sequence of the map's keys

```js
hu.keys({a: true}) // → ['a']
```

#### vals(obj)
Return: `array`

Returns a sequence of the map's values

```js
hu.vals({a: true}) // → [true]
```

#### keyValues(obj)
Return: `array` | Alias: `pairs`

Returns a two dimensional array of an object’s key-value pairs

```js
hu.keyValues({a: true}) // → [['a', true]]
```

#### toObject(obj)
Return: `array`

Creates an object of given arguments.
Odd indexed arguments are used for keys and evens for values

```js
hu.toObject('a', true) // → {a: true}
```

#### extend(target, ...origins)
Return: `object` | Alias: `assign`

Assigns own enumerable properties of source object(s) to the destination object

```js
hu.extend({x: true}, {y: false}) // → {x: true, y: false}
```

#### mixin(target, ...origins)
Return: `object`

Adds function properties of a source object to the destination object

```js
var methods = {
  something: function () {
    // cool stuff
  }
}
hu.mixin({x: true}, methods)
// → {x: true, something: function () {}}
```

#### map(obj, function)
Return: `object` | Alias: `mapValues` | Curried: `true`

Maps object values by applying with the value return
of each callback call on each one

```js
function mapper(val) {
  return val * 2
}
hu.map({x: 2}, mapper) // → {x: 4}
```

#### filter(obj, function)
Return: `object` | Alias: `filterValues` | Curried: `true`

Iterates over properties of an object,
returning an filtered new object of all
elements where the callback returns true

```js
function filter(val) {
  return val > 1
}
hu.map({x: 1, y: 2}, filter) // → {y: 2}
```

#### clone(object)
Return: `object`

Creates a clone of the given object

```js
var obj = {x: 1}
var newObj = hu.clone(obj)
newObj === obj // → false
```

#### merge(x, y)
Return: `object`

Similar to `extend`, it returns an object that consists
of the rest of the maps conj-ed onto the first

If a key occurs in more than one map, the mapping from
the latter (left-to-right) will be the mapping in the result

```js
var obj1 = {x: {y: {z: 2}}}
var obj2 = {x: {y: {a: 1}}}
var newObj = hu.merge(obj1, obj2)
// → {x: {y: {z: 2, a: 1}}}
```

### Collections

#### each(obj, function)
Return: `object` | Alias:  `forEach`

Iterates over elements of an iterable object,
executing the callback for each element.
It will return the same given object

```js
hu.each([1, 2], function (n) {
  console.log('Value:', n)
})
```

#### size(obj)
Return: `number`

Gets the size of the given collection

```js
hu.size({x: 1, y: 2}) // → 2
```

#### compact(obj)
Return: `object|array` | Alias: `clean`

Returns a new collection which
contains only the not empty values

```js
hu.compact([1, null, undefined, "", 5])
// → [1, 5]
```

### Functions

#### constant(value)
Return: `function` | Alias: `identity`

Returns a function that returns the given value

```js
var getter = hu.constant('john')
getter() === 'john' // → true
```

#### apply(fn, args)
Return: `mixed`

Invokes a function binding itself function object context
with the given arguments as array

```js
function myFn(x, y) { return x * y }
hu.apply(myFn, [2, 2]) // → 4
```

#### bind(fn, ctx)
Return: `function`

Creates a function that, when called, invokes the function
with the this binding of thisArg and prepends any additional
bind arguments to those provided to the bound function

```js
function func(greeting) {
  return greeting + ' ' + this.name
}
func = hu.bind(func, { 'name': 'john' }, 'hi')
func() // → 'hi john'
```

#### partial(fn, [ ...partialArgs ])
Return: `function`

Creates a function that, when called, invokes
func with any additional partial arguments
prepended to those provided to the new function

```js
function greet(greeting, name) {
  return greeting + ' ' + name;
}
var hi = hu.partial(greet, 'hi');
hi('john') // → 'hi john'
```

#### curry(fn, [ ctx ])
Return: `function`

Creates a function which accepts one or more
arguments of the given function that when invoked either
executes the function returning its result

```js
var curried = hu.curry(function(a, b, c) {
  console.log(a + b + c)
})
curried(1)(2)(3) // → 6
curried(1, 2)(3) // → 6
curried(1, 2, 3) // → 6
```

#### compose(...fn)
Return: `function`

Creates a function that is the composition of the provided functions, where each function consumes the return value of the function that follows

```js
function name(name) {
  return name.toLowerCase() + '!'
}
function greet(name) {
  return 'Hi ' + name
}
var welcome = hu.compose(name, greet);
welcome('John') // → 'Hi john!'
```

#### memoize(fn, resolver)
Return: `function`

Creates a function that memoizes the result
of the the given function. If resolver is provided
it will be used to determine the cache key for
storing the result based on the arguments provided
to the memoized function.
The resolver function just uses the first argument
to the memoized function as the key

```js
var multiply = hu.memoize(function (n) {
  return n * 2
})
multiply(2) // → 4 (computed value)
multiply(2) // → 4 (memoized value)
```

With custom resolver function to define memoized values
```js
var multiply = hu.memoize(function (n) {
  return n * 2
}, function (n) {
  return n === 2 ? n + 1 : n
})
multiply(1) // → 2 (computed value)
multiply(2) // → 4 (computed value)
multiply(3) // → 4 (memoized value, from 2 value)
```

#### wrap(fn, wrapperFn, [ ...args ])
Return: `function`

Creates a function that provides value to the wrapper
function as its first argument. Additional arguments
provided to the function are appended to those provided
to the wrapper function

```js
function hello(name) {
  return "hi " + name;
}
hello = hu.wrap(hello, function (fn, text, type) {
  return "before, " + fn("moe") + ", " + text + ": " + type + ", after"
}, "type")
hello("salutation") // → 'before, hi moe, type: salutation, after'
```

#### once(fn)
Return: `function`

Creates a function that is restricted to execute function
once time. Subsuquents calls to the function will return
the memoized value of the initial call

```js
var times = 0
var init = hu.once(function () {
  return times += 1
})
init() // → 1
init() // → 1
```

#### times(fn, number)
Return: `function`

Creates a function that is restricted to be executed
a finite number of times. Subsuquents calls to the
function will return the memoized value of the latest call

```js
var times = 0
var init = hu.times(function () {
  return times += 1
}, 2)
init(); // → 1
init(); // → 2
init(); // → 2
```

#### defer(fn, ms, [ ...args ])
Return: `void`

Executes the given function after wait milliseconds. You can provide arguments that will be passed to the function when it's invoked

```js
function delayed(text) {
  console.log(text)
}
hu.defer(delayed, 1000, 'later')
// → logs 'later' after one second
```

#### debounce(fn, ms, [ ...args ])
Return: `function`

Return a function that executes the given function after wait
milliseconds when it's called. You can provide arguments
that will be passed to the function when it will be invoked

```js
function delayed(text, name) {
  console.log(text, name)
}
var lazy = hu.debounce(delayed, 1000, 'later')
lazy('call') // → logs 'later call' after one second
```

### Equality

#### isEqual(x, y)
Return: `boolean` | Alias: `equal`, `deepEqual`, 'isDeepEqual'

Compares primitives types and data objects in a type-independent manner.
Clojure's immutable data structures define -equiv (and thus =)
as a value, not an identity, comparison.

#### isPatternEqual(x, y)
Return: `boolean` | Alias: `isRegExpEqual`, `patternEqual` | Curried: `true`

Check if the given dates are equal

#### isDateEqual(x, y)
Return: `boolean` | Alias: `dateEqual` | Curried: `true`

Check if the given dates are equal

#### isArrayEqual(x, y)
Return: `boolean` | Alias: `arrayEqual` | Curried: `true`

Check if the given arrays has the same elements

#### isObjectEqual(x, y)
Return: `boolean` | Alias: `objectEqual` | Curried: `true`

Checks if the given objects values and keys are equals

### Miscellaneous

#### log(...msg)
Return: `undefined`

Write the given arguments in the console

#### isBrowser
Type: `boolean`

Checks if the current runtime JavaScript environment is in a browser context

#### noop()
Return: `void`

The no-operation function, that returns `void`

#### now()
Return: `number`

Returns an integer timestamp for the current time

#### _global()
Return: `object`

Environment specific global object

## Contributing

Wanna help? Cool! It will be really apreciated :)

You must add new test cases for any new feature or refactor you do,
always following the same design/code patterns that already exist

Tests specs are completely written in Wisp language.
Take a look to the language [documentation][wisp] if you are new with it.
You should follow the Wisp language coding conventions

### Development

Only [node.js](http://nodejs.org) is required for development

Clone/fork this repository
```
$ git clone https://github.com/h2non/hu.git && cd hu
```

Install package dependencies
```
$ npm install
```

Compile code
```
$ make compile
```

Run tests
```
$ make test
```

Browser sources bundle generation
```
$ make browser
```

Release a new version
```
$ make release
```

## License

Copyright (c) Tomas Aparicio

Released under the MIT license

[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/h2non/hu.js/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

[wisp]: https://github.com/Gozala/wisp
[travis]: http://travis-ci.org/h2non/hu
[npm]: http://npmjs.org/package/hu
