% Notes for [The Go Programming Language Specification](https://golang.org/ref/spec)
<!--
vim:et
GitHub width is 100
-->

# Lexical elements

## Semicolons

Semicolons ";" are **terminators**.

Go programs may omit most of these semicolons using the following two rules:

1. A semicolon is automatically inserted at the end of the line if the last
   token on that line is

    - an identifier; a numeric literal; a rune or string literal
    - a return-style keyword: `break`, `continue`, `fallthrough`, or `return`
    - one of the operators: ++, --
    - one of the delimiters: ), ], }

2. To allow complex statements to occupy a single line, a semicolon may be
   omitted before a closing ")" or "}".

**A ";" before ")"** could occur in constructions: `import`, `type`, `var`, `const`.

**A ";" before "}"** could occur in constructions: `struct`, `interface`, in
production `Block`.

**A ";" before "]"** could not occur in any production, according to grammar.

## Commas

Commas "," are usually **delimiters**.

An additional comma could also be used as a **terminator**, in such case the
comma is optional and could occur before another delimiter.

**A "," before ")"** could occur in the following productions:

  - declarations: `Parameters` (parameter list, result list)
  - expressions: `Arguments`, `Conversion`

**A "," before "}"** could occur in composite literals.

**A "," before "]"** could not occur in any production, according to grammar.

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

1. \\x followed by exactly two hexadecimal digits,
    - \\X is not allowed;
1. \\u followed by exactly four hexadecimal digits;
1. \\U followed by exactly eight hexadecimal digits,
1. a plain backslash \\ followed by exactly three octal digits.

Quote escapes are not always valid:

- \\'   U+0027 single quote  (valid escape only within rune literals)
- \\"   U+0022 double quote  (valid escape only within string literals)

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
    - `real` and `imag` applied to a complex constant and `complex` applied to
      numeric constants.

A default type is the type to which the constant is implicitly converted in
contexts where a typed value is required.

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
declared with receiver `*T` or `T` (that is, it also contains the method set of
`T`).

## Numeric types

All numeric types are distinct except

- `byte`, which is an alias for `uint8`, and
- `rune`, which is an alias for `int32`.

## String types

A string's bytes can be accessed by an integer index. It is illegal to take the
address of such an element; `&s[i]` is invalid.

## Array types

```ebnf
ArrayType = "[" NonNegativeConstantExpression "]" ElementType ;
```

## Slice types

```ebnf
SliceType = "[]" ElementType ;
```

## Struct types

```ebnf
StructType     = "struct" "{" { StructSpec ";" } "}" ;
StructSpec     = (FieldDecl | AnonymousField) [ "...tag..." ] ;
FieldDecl      = IdentifierList Type ;
AnonymousField = [ "*" ] TypeName ;
```

A field declared with no field name is an **anonymous field**, also called an
**embedded field** or an **embedding of the type in the struct**.

A field or method `f` of an anonymous field in a struct `x` is called promoted
if `x.f` is a legal selector that denotes that field or method `f`.

In other words, every field or method of an inner struct is promoted into the
field or method of the outer struct.

Promoted fields act like ordinary fields of a struct except that they cannot be
used as field names in composite literals of the struct.

- <https://stackoverflow.com/a/34083564/2958047>
- <https://medium.com/golangspec/promoted-fields-and-methods-in-go-4e8d7aefb3e3>

### Field Tags

A field declaration may be followed by a tag. The tags are made visible through
a reflection interface; e.g. a tag could define protobuf field number.

## Function types

```ebnf
                    (* Compare to MethodSpec and FunctionDecl *)
FunctionType      = "func" Signature ;
Signature         = Parameters [ Result ] ;
Result            = Parameters | Type ;
Parameters        = "(" [ ParameterList [ "," ] ] ")" ;
ParameterList     = ParameterDecl { "," ParameterDecl } ;
ParameterDecl     = [ IdentifierList ] Type ;
LastParameterDecl = [ identifier ] [ "..." ] Type ;
IdentifierList    = identifier { "," identifier } ;
identifier        = letter { letter | unicode_digit } ;
blank_identifier  = "_" ;
```

All non-blank names in the signature must be unique.

- Parameter list is always parenthesized.
- Complex result list is always parenthesized.
- Exactly one unnamed result may be written as an unparenthesized type.

```go
func f(_ int, ) ()      // Possible declaration,
                        //   - "," before ")" is optional
                        //   - identifier could be "_" (blank identifier)
func f(int)             // Same as the previous one,
                        //   - IdentifierList is optional
                        //   - result list is optional

func g(_, _ int, ) (x int, ) { x = 1; return }    // Possible definition
func g(_, _ int) int { return 1 }                 // Same as the previous one

func(prefix string, values ...int)                // Variadic function
                       // "..." is only possible for the last parameter
func(n int) func(p *T)                            // Curried function
```

## Interface types

```ebnf
InterfaceTypeDecl  = "type" identifier InterfaceType ;     (* Name follows "type" *)
InterfaceType      = "interface" "{" { InterSpec ";" } "}" ;  (* Possibly unnamed *)
InterSpec          = MethodSpec | InterfaceTypeName ;
InterfaceTypeName  = TypeName ;                 (* Embedded interface;
                                                   its methods are added *)
                     (* Compare to FunctionType and FunctionDecl *)
MethodSpec         = MethodName Signature ;
MethodName         = identifier ;
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
MapType     = "map" "[" KeyType "]" ElementType ;
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
ChannelType = ( "chan" | "chan<-" | "<-chan" ) ElementType ;
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
var x V = //...
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

```ebnf
ConstDecl   = "const" ( ConstSpec | ConstSpecs ) ;
ConstSpecs  = "(" { ConstSpec ";" } ")" ) ;
              (* Compare to VarSpec *)
ConstSpec   = IdentifierList [ [ Type ] "=" ExpressionList ] ;
```

If the type is present, **all constants take the type specified,** and the
expressions must be assignable to that type.

If the type is omitted, the constants take **the individual types of the
corresponding expressions**.

If the expression values are untyped constants, **the declared constants remain
untyped**.

Within a parenthesized-const-declaration-list the expression-list may be
omitted from any but the first declaration.  Omitting the list of expressions
is equivalent to repeating the previous list.

## Iota

The predeclared identifier `iota` represents successive untyped integer
constants.

It is reset to 0 whenever the reserved word `const` appears in the source and
increments after each ConstSpec.  Within an ExpressionList, the value of each
`iota` is the same.

## Type declarations

The new type is different from the existing type; see Type Identity.

The declared type does not inherit any methods bound to the existing type, but
the method set of an interface type remains unchanged.

A type declaration may be used to define a different boolean, numeric, or
string type and attach methods to it.

## Variable declarations

```ebnf
VarDecl     = "var" ( VarSpec | VarSpecs ) ;
VarSpecs    = "(" { VarSpec ";" } ")" ) ;
              (* Compare to ConstSpec *)
VarSpec     = IdentifierList Type [ "=" ExpressionList ] |
              IdentifierList        "=" ExpressionList ;

VarSpec     = IdentifierList ( Type [ "=" ExpressionList ] | "=" ExpressionList ) ;
```

Compare ConstSpec to VarSpec:

|                         | ConstSpec | VarSpec | Notes                                         |
|-------------------------|-----------|---------|-----------------------------------------------|
| `Type`                  | -         | OK      | Constants must have values, if they have type |
| `Type = ExpressionList` | OK        | OK      |                                               |
| `= ExpressionList`      | OK        | OK      | Type is inferred                              |
| *nothing at all*        | OK        | -       | ConstSpec: previous `ExpressionList` is used  |
|                         |           |         | VarSpec: should specify `Type` at least       |

Unlike constants, variables cannot be untyped.  If no explicit type is
specified and the value is an untyped constant, the value is first converted to
its default type.

The predeclared value `nil` cannot be used to initialize a variable with no
explicit type.

## Short variable declarations

Unlike regular variable declarations, a short variable declaration may
*redeclare* variables if at least one of the non-blank variables is new. As a
consequence, redeclaration can only appear in a multi-variable short
declaration. Redeclaration does not introduce a new variable; it just assigns a
new value to the original.

## Function declarations

```ebnf
                    (* Compare to MethodSpec and FunctionType *)
FunctionDecl      = "func" FunctionName Signature [ FunctionBody ] ;
FunctionName      = identifier ;
FunctionBody      = Block ;
```

A function declaration may omit the body, if the function is implemented
externally.

## Method declarations

```ebnf
MethodDecl        = "func" Receiver MethodName Signature [ FunctionBody ] ;
Receiver          = Parameters ;  (* Single parameter with type restrictions *)
```

The receiver section must declare a single non-variadic parameter.  Its type
must be of the form `T` or `*T`, possibly using parentheses.

The type of a method is the type of a function with the receiver as first
argument. However, a function declared this way is not a method.

```go
func (p *Point) Scale(factor float64)   // MethodSpec
func(p *Point, factor float64)          // FunctionType of that method
```

# Expressions

## Operands

```ebnf
Operand =
  Literal |
  identifier |                  (* A constant, variable, or function *)
  PackageName "." identifier |  (* A qualified identifier *)
  MethodExpr |                  (* A function, whose first arg is a reciever *)
  "(" Expression ")" ;          (* A parenthesized expression *)

Literal  = BasicLit | CompositeLit | FunctionLit ;
BasicLit = int_lit | float_lit | imaginary_lit | rune_lit | string_lit ;
```

Operands denote the elementary values in an expression.

## Composite literals

- TBD: Reorder LiteralType components
- TBD: Grammar, split ElementList => Keyed/PlainElementList
- TBD: Grammar, split into struct, map, array/slice

### Map literals
### Struct literals
### Array and slice literals
### Element type elision
### Parsing ambiguity in conditional statements

## Function literals

```ebnf
FunctionLit = "func" Signature FunctionBody ;
```

A function literal represents an anonymous function, they are closures.

A function literal could be bound to a named variable, but [nested function
declarations](https://stackoverflow.com/questions/21961615/why-doesnt-go-allow-nested-function-declarations-functions-inside-functions)
are not allowed.

## Primary expressions

```ebnf
PrimaryExpr =
  Operand |                                               (* Described earlier *)
  Conversion |                                            (* Described later *)
  PrimaryExpr "." identifier |                            (* Selector *)
  PrimaryExpr "[" Expression "]" |                        (* Index *)
  PrimaryExpr "[" [ Low ] ":" [ High ] "]" |              (* Simple Slice *)
  PrimaryExpr "[" [ Low ] ":"   High ":" Max "]" |        (* Full Slice *)
  PrimaryExpr "." "(" Type ")" |                          (* Type Assertion *)
  PrimaryExpr "(" Type [ "," ExpressionList ] [ "," ] ")" (* new and make *)
  PrimaryExpr "(" [ ExpressionList [ "," ] ] ")"          (* Simple Call *)
  PrimaryExpr "(" ExpressionList [ "..." ] [ "," ] ")" ;  (* Variadic Call *)
```

Primary expressions are the operands for [unary and binary expressions](#operators).

### Selectors

- TBD

### Method expressions
### Method values
### Index expressions
### Simple slice expressions
### Full slice expressions
### Type assertions
### Calls
### Passing arguments to ... parameters

## Operators

```ebnf
Expression = UnaryExpr | Expression binary_op Expression .
UnaryExpr  = PrimaryExpr | unary_op UnaryExpr .
```

Operators combine [operands](#operands) and [primary
expressions](#primary-expressions) into expressions.

### Arithmetic operators
### Comparison operators
### Logical operators
### Address operators
### Receive operator

## Conversions
## Constant expressions
## Order of evaluation
