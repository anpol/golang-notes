% Notes for [The Go Programming Language Specification](https://golang.org/ref/spec)

# Lexical elements

## Semicolons

Go programs may omit most of these semicolons using the following two rules:

1. A semicolon is automatically inserted at the end of the line if the last
   token on that line is

    - an identifier; a numeric literal; a rune or string literal
    - a return-style keyword: `break`, `continue`, `fallthrough`, or `return`
    - one of the operators: ++, --
    - one of the delimiters: ), ], }

2. To allow complex statements to occupy a single line, a semicolon may be
   omitted before a closing ")" or "}".

**NOTE:** A semicolon before ")" could occur in constructions like `var`, `const`, `type`, `import`.

## Imaginary literals

An imaginary literal is a decimal representation of the imaginary part of a
complex constant. It consists of a floating-point literal or decimal integer
followed by the lower-case letter i.

```go
0i
0.i
2.71828i
1.e+0i
6.67428e-11i
```

## Rune literals

There are four ways to represent the integer value as a numeric constant:

- \x followed by exactly two hexadecimal digits;
- \u followed by exactly four hexadecimal digits;
- \U followed by exactly eight hexadecimal digits,
- a plain backslash \ followed by exactly three octal digits.

Quote escapes are not always valid:

- \'   U+0027 single quote  (valid escape only within rune literals)
- \"   U+0022 double quote  (valid escape only within string literals)

## String literals

Raw string literals are character sequences between back quotes, as in \`foo\`.
Within the quotes, any character may appear except back quote.  Backslashes
have no special meaning and the string may contain newlines. Carriage return
characters ('\r') inside raw string literals are discarded from the value.

```go
`abc`                // same as "abc"
`\n
\n`                  // same as "\\n\n\\n"
```

## Constants

A constant value is represented by

- a numeric literal; a rune or string literal
- an identifier denoting a constant,
- a constant expression,
- a conversion with a result that is a constant, or
- the result value of some built-in functions such as
    - `unsafe.Sizeof` applied to any value,
    - `cap` or `len` applied to some expressions,
    - `real` and `imag` applied to a complex constant and `complex` applied to numeric constants.

A default type is the type to which the constant is implicitly converted in contexts where a typed value is required.

The default type of an untyped constant could be

- bool,
- int, float64, complex128,
- rune or string.

# Types

**An underlying type** of a named type T is such a type to which T refers in
its type declaration.

```go
var foo string      // string
type T1 string      // string
type T2 T1          // string
var bar []T1        // []T1
type T3 []T1        // []T1
type T4 T3          // []T1
```

## Method sets

The method set of the corresponding pointer type `*T` is the set of all methods
declared with receiver `*T` or `T` (that is, it also contains the method set of `T`).

## Numeric types

All numeric types are distinct except

- `byte`, which is an alias for `uint8`, and
- `rune`, which is an alias for `int32`. 

## String types

A string's bytes can be accessed by integer. It is illegal to take the address
of such an element; `&s[i]` is invalid.

## Struct types

```ebnf
StructType     = "struct" "{" { StructSpec ";" } "}" ;
StructSpec     = (FieldDecl | AnonymousField) [ "...Tag..." ] ;
FieldDecl      = IdentifierList Type .
AnonymousField = [ "*" ] TypeName .
```

A field declared with no field name is an **anonymous field**, also called an
**embedded field** or an **embedding of the type in the struct**.

A field or method `f` of an anonymous field in a struct `x` is called promoted
if `x.f` is a legal selector that denotes that field or method `f`.

Promoted fields act like ordinary fields of a struct except that they cannot be
used as field names in composite literals of the struct.

- <https://stackoverflow.com/a/34083564/2958047>
- <https://medium.com/golangspec/promoted-fields-and-methods-in-go-4e8d7aefb3e3>

A field declaration may be followed by a tag. The tags are made visible through
a reflection interface; e.g. a tag could define protobuf field number.

## Function types

```ebnf
FunctionType      = "func" Signature ;                    (* MethodSpec is similar *)
Signature         = Parameters [ Result ] ;
Result            = Parameters | Type ;
Parameters        = "(" [ ParameterList [ "," ] ] ")" ;   (* "," is optional before ")", gofmt removes it *)
ParameterList     = ParameterDecl { "," ParameterDecl } .
ParameterDecl     = [ IdentifierList ] Type .             // IdentifierList is optional, while Type is not
LastParameterDecl = [ identifier ] [ "..." ] Type .       // "..." is only possible for the last parameter
IdentifierList    = identifier { "," identifier } .
identifier        = letter { letter | unicode_digit }     // Could be blank_identifier
blank_identifier  = "_" .
```

All non-blank names in the signature must be unique.

- Parameter list is always parenthesized.
- Result list is parenthesized except that if there is exactly one unnamed
  result it may be written as an unparenthesized type.

```go
func f(_ int, ) () {}                           // Possible declaration (1)
func f(int) {}                                  // Same as (1) above
func f(_, _ int, ) (x int, ) { x = 1; return }  // Also possible (2)
func f(_, _ int) int { return 1 }               // Same as (2) above
func(prefix string, values ...int)              // Variadic function
func(n int) func(p *T)                          // Curried function
```

## Interface types

```ebnf
InterfaceTypeDecl  = "type" identifier InterfaceType .            // Naming requires "type" keyword
InterfaceType      = "interface" "{" { InterfaceSpec ";" } "}" .  // Possibly unnamed interface
InterfaceSpec      = MethodSpec | InterfaceTypeName .
InterfaceTypeName  = TypeName .               // Embedded interface; its methods are added
MethodSpec         = MethodName Signature .   // FunctionType uses is similar
MethodName         = identifier .             // But FunctionType uses "func" instead of identifier
```

All types implement the empty interface:

```go
interface{}
```

An interface `T` may use a (possibly qualified) interface type name `E` in
place of a method specification. This is called **embedding interface** `E` in
`T`; it adds all (exported and non-exported) methods of `E` to the interface
`T`.

An interface type `T` may not embed itself or any interface type that embeds
`T`, recursively.

## Map types

```ebnf
MapType     = "map" "[" KeyType "]" ElementType .
```

The comparison operators == and != must be fully defined for operands of the key type; thus the key type must not be a function, map, or slice.

```go
map[string]int
```

If the key type is an interface type, these comparison operators must be defined for the dynamic key values; failure will cause a run-time panic.

```go
map[string]interface{}
```

For a map `m`, 

- `len(m)` is the number of map elements
- elements may be added during execution using assignments
- elements may be retrieved with index expressions
- elements may be removed with the `delete` built-in function.

A new, empty map value is made using the built-in function `make`:

```go
make(map[string]int)
make(map[string]int, 100)
```

A nil map is equivalent to an empty map except that no elements may be added.
(TODO: try it!)

## Channel types

```ebnf
ChannelType = ( "chan" | "chan<-" | "<-chan" ) ElementType .
```

The `<-` operator associates with the leftmost chan possible:

```go
chan<- chan int    // same as chan<- (chan int)
chan<- <-chan int  // same as chan<- (<-chan int)
<-chan <-chan int  // same as <-chan (<-chan int)
```

A nil channel is never ready for communication.
(TODO: try it!)

A channel may be closed with the built-in function `close`. The multi-valued
assignment form of the receive operator reports whether a received value was
sent before the channel was closed.

```go
x, ok := <-ch
```

# Properties of types and values

## Type identity

A named and an unnamed type are always different.

Two unnamed types are identical if they have the same literal structure and
corresponding components have identical types. 

## Assignability

```go
var x V = ...
var y T = x	// assignable?
```

A value `x` of type `V` is assignable to a variable `y` of type `T` in any of
these cases:

- V is identical to T.
- V and T have identical underlying types, and they are not both named types;
  at least one of them is not a named type.
- T is an interface and V implements T.
- V is a bidirectional channel, T is any kind of channel, both have identical
  element types.
- x is nil, and T is any of: pointer, func, slice, map, channel, interface.
- x is an untyped constant representable by T. 

(TODO: try these rules)

# Declarations and scope

The *blank identifier* does not introduce a binding and thus is not declared.

In the package block, the *init function* does not introduce a new binding.

Go is lexically scoped using blocks:

1. The scope of a predeclared identifier is the universe block.
1. The scope of an declaration outside any function is the package block.
1. The scope of an imported package name is the file block.
1. The scope of a function parameter is the function body.
1. The scope of a variable or a type declared inside a function ends at the end
   of the innermost containing block.
1. The scope of a label is the body of the function in which it is declared and
   excludes the body of any nested function.  In contrast to other identifiers,
   labels are not block scoped and do not conflict with identifiers that are
   not labels.

The package clause is not a declaration.

## Exported identifiers

An identifier is exported if both:

- the first character of the identifier's name is an upper case letter
- the identifier is declared in the package block; or it is a field name or
  method name (TODO: check that lowercase methods are naturally exported).

## Constant declarations

The number of identifiers must be equal to the number of constant expressions.

```go
```

## Iota
## Type declarations
## Variable declarations

TODO: compare grammer of const/var using a comparison table.

## Short variable declarations
## Function declarations
## Method declarations

# Expressions
## Operands
## Qualified identifiers
## Composite literals

TBD: Reorder LiteralType components
TBD: Grammar, split ElementList => Keyed/PlainElementList
TBD: Grammar, split into struct, map, array/slice

