# Go Language Notes

## Arrays

An array literal can be specified like so:

```go
b := [2]string{"Penn", "Teller"}
```

Or, you can have the compiler count the array elements for you:

```go
b := [...]string{"Penn", "Teller"}
```

In both cases, the type of b is [2]string.

## Slices

We can grow s to its capacity by slicing it again:

```go
s = s[:cap(s)]
```

Slices cannot be re-sliced below zero to access earlier elements in the array.

To append one slice to another, use ... to expand the second argument to a list of arguments.

```go
a := []string{"John", "Paul"}
b := []string{"George", "Ringo", "Pete"}
a = append(a, b...) // equivalent to "append(a, b[0], b[1], b[2])"
// a == []string{"John", "Paul", "George", "Ringo", "Pete"}
```

## Interface Values and nil

An interface value holds a value of a specific underlying concrete type.
Calling a method on an interface value executes the method of the same name on
its underlying type.

An interface value that holds a nil concrete value is itself non-nil.

```go
	var t *T  // = nil
	var i I = t
	if i != nil {
		fmt.Println("i != nil")
	}
```

A nil interface value holds neither value nor concrete type.  Calling a method
on a nil interface is a run-time error because there is no type inside the
interface tuple to indicate which concrete method to call.

```go
	var i I  // = nil
	if i == nil {
		fmt.Println("i == nil")
	}
	i.M()  // runtime error
```

## The empty interface

The interface type that specifies zero methods is known as the *empty interface*.

```go
var i interface{}
```

Empty interfaces are used by code that handles values of unknown type.

A type assertion provides access to an interface value's underlying concrete value.

```
t     := i.(T)  // == dynamic_cast<T&>(i)  // can trigger a panic
t, ok := i.(T)  // == dynamic_cast<T*>(i)  // no panic occurs, syntax of map access
```

A *type switch* has the same syntax, but the specific type is replaced with the
keyword `type`.  In each of its cases, the resulting variable will be of type
declared in that case.

```go
	switch v := i.(type) {
	case int:
		fmt.Printf("Twice %v is %v\n", v, v*2)
  // ...
	}
```
