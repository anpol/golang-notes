% Notes for [Go by Example](https://gobyexample.com)
<!--
vim:et:spell
GitHub width is 100
-->

## legend

SURPRISE: A behavior that could surprise a newbie.

EXTRA: Information taken from other sources, like blog posts.

BTW: Other kind of note.

## if/else

`if` can have statements before conditional.

SURPRISE Cannot use `var` (Why? Did you say that `:=` is a shorthand for `var`?):
```go
    if var num = 9; num < 0 {
```
> ./if-else.go:25:9: syntax error: var declaration not allowed in if initializer

SURPRISE Cannot have multiple conditionals (unlike Swift):
```go
    if num := 9; num < 0; num < 10 {
```
> ./if-else.go:25:22: syntax error: unexpected semicolon, expecting { after if clause

BTW bad diagnostics.

There is no ternary ?: operator.

## for

`for` can be `while`

`for` can be empty

## switch

`switch` can have multiple statements before test expression (just like `if`, and
similar to `for`?).

`switch` can be empty, then it behaves like `if/else if/else if/else` chain.

`case` can have multiple patterns, use commas.

A type switch is special:
```go
    switch t := i.(type) {
    case bool:
        fmt.Println("I'm a bool")
```
(`i` should be an interface type, and `.(type)` can't be used out of `switch`)

## array

Use this syntax to declare and initialize an array in one line.
```go
    b := [5]int{1, 2, 3, 4, 5}
```

EXTRA You can omit length, use `[]`, but it would be a slice, not an array.

EXTRA To have the compiler count the array elements for you:
```go
    b := [...]int{1, 2, 3, 4, 5}
```

You’ll see slices much more often than arrays in typical Go.

## slice

To create an empty slice with non-zero length, use `make`:
```go
    s := make([]string, 3)
```
EXTRA why make? because the value is not part of the slice type, so we need
a helper function over a type and a value.

EXTRA make function takes a type, a length, and an *optional capacity*. In C++
it would look like a curried function on a type and a value:
```cxx
    auto s = make<slice<string>>(3);  // C++ syntax.
```

EXTRA The length and capacity of a slice can be inspected using the
built-in `len()` and `cap()` functions.

builtin `append` returns a slice containing one or more new values:
```go
    s = append(s, "d")
    s = append(s, "e", "f")
```

Slices and arrays can be modified in-place.

Slices can also be copied.  Copy is not possible for arrays, because that would
require `copy` to be a generic function.  So we have a kind of size-erasure
here, that helps to implement a `copy` for slices.

More on slices:
http://blog.golang.org/2011/01/go-slices-usage-and-internals.html

## map

To create an empty map, use `make(map[key-type]val-type)`.

`delete` removes key/value pairs from a map:
```go
    delete(m, "k2")
```

The optional second return value indicates if the key was present:
```go
    _, prs := m["k2"]
```
So you can disambiguate between missing keys and keys with zero values.

Declare and initialize a new map in the same line with this syntax:
```go
    n := map[string]int{"foo": 1, "bar": 2}
```

## range

`range` iterates over key/value pairs, you may ignore either one:
```go
    for index, value := range array_value {}
    for _, value := range array_value {}
    for index := range array_value {}

    for key, value := range map_value {}
    for _, value := range map_value {}
    for key := range map_value {}

    for byte_offset, rune := range "string_value" {}
```

## func

omit all but the last type name for the like-typed parameters:
```go
    func plusPlus(a, b, c int) int {
        return a + b + c
    }
```
BTW It's a C-like shorthand.

A variadic function, one that takes an arbitrary number of arguments:
```go
    func sum(nums ...int) {}
```

If you already have args in a slice, apply them like this:
```go
    nums := []int{1, 2, 3, 4}
    sum(nums...)
```

## struct

This syntax creates a new struct.
You can name the fields when initializing a struct.
Omitted fields will be zero-valued.
```go
    fmt.Println(person{"Bob", 20})
    fmt.Println(person{name: "Alice", age: 30})
    fmt.Println(person{name: "Fred"})
```

An & prefix yields a pointer to the struct.
It’s idiomatic to encapsulate new struct creation in constructor functions
```go
    fmt.Println(&person{name: "Ann", age: 40})
    fmt.Println(NewPerson("Jon"))
```

## methods

Go automatically handles conversion between values and pointers for method
calls.

BTW The compiler takes different approaches, however:

* If you have a pointer, any kind of method is allowed. Either with a pointer
  receiver, or with a value receiver.  They are in the [method
  set](https://golang.org/ref/spec#Method_sets) of a pointer type.
* If you have an addressable value, then you can call methods having pointer
  receivers because of a special rule on [method
  calls](https://golang.org/ref/spec#Calls): `x.m()` is shorthand for
  `(&x).m()`.
* If you have a non-addressable (temporary) value, you can only call
  methods having value receivers.

EXTRA Definitions of addressable:

* https://golang.org/ref/spec#Address_operators
* https://golang.org/pkg/reflect/#Value.CanAddr
* https://utcc.utoronto.ca/~cks/space/blog/programming/GoAddressableValues
* https://stackoverflow.com/questions/38168329/why-are-map-values-not-addressable
* https://stackoverflow.com/questions/48790663/why-value-stored-in-an-interface-is-not-addressable-in-golang

EXTRA If you want to pass an addressable value to someone else, you can pass a
pointer instead, to extend a usable method set.  See [Pointers vs.
Values](https://golang.org/doc/effective_go.html#pointers_vs_values).

So should we simply declare getters with a value, setters with a pointer
receiver?  No, not so simple.

* See [Should I define methods on values or
  pointers?](https://golang.org/doc/faq#methods_on_values_or_pointers) in FAQ.
* See [Receiver
  Type](https://github.com/golang/go/wiki/CodeReviewComments#receiver-type) in
  Go Code Review Comments.

To summarize, a method can be defined with a value receiver, if it's a
getter-style method that takes either a small `struct`, or a `map`, `func`,
`chan`, or a non-reallocating slice.   You may wish to define a method with a
value receiver if you want to call it in on temporary values.

## interfaces

To implement an interface in Go, we just need to implement all the methods in
the interface.

Interfaces allow us to make generic functions (but not structs.)

More on interfaces:
* https://jordanorelli.com/post/32665860244/how-to-use-interfaces-in-go -- STOPPED ad Twitter API
* https://research.swtch.com/interfaces — TODO

EXTRA:

An interface is two things: it is *a method set,* but it is also *a type.*

We design our abstractions in terms of what actions our types can execute.

All types satisfy the empty `interface{}`.

An interface definition does not prescribe whether an implementor should
implement the interface using a pointer receiver or a value receiver.

## errors

errors.New constructs a basic error value with the given error message.
```go
    return -1, errors.New("can't work with 42")
```

It’s possible to use custom types as errors by implementing the Error() method
on them. Here’s a variant on the example above that uses a custom type to
explicitly represent an argument error.
```go
    type argError struct {
        arg  int
        prob string
    }
    func (e *argError) Error() string {
        return fmt.Sprintf("%d - %s", e.arg, e.prob)
    }
```

More on errors:
http://blog.golang.org/2011/07/error-handling-and-go.html
