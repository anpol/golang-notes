# Go Modules in Go Blog, Mar 2019 – Nov 2019

Link: https://blog.golang.org/using-go-modules

It's better to work-through the series executing the commands.

## Part 1 — Using Go Modules

Create a new module, initializing the go.mod file that describes it.
```sh
go mod init
```

The `go` command also maintains a file named
[go.sum](https://golang.org/cmd/go/#hdr-Module_authentication_using_go_sum)
containing the hashes, each beginning with prefix "h1:", which means SHA-256.

Lists the current module and all its dependencies:

```sh
go list -m all
```

List the available tagged versions of a module:
```sh
go list -m -versions rsc.io/sampler
```

Get a module of the specified version
```sh
go get rsc.io/sampler@v1.3.1
```

The default version is `@latest`, which resolves to the latest version as follows:

* latest tagged stable (non-[prerelease](https://semver.org/#spec-item-9))
  version, or else
* the latest tagged prerelease version, or else
* the latest untagged version (recorded using a
  [pseudo-version](https://golang.org/cmd/go/#hdr-Pseudo_versions) form).

Get a list of modules whose names are started with the specified prefix:

```sh
go list -m rsc.io/q...
```

The `go` command allows a build to include at most one version of any
particular module path.  So to be able to import different major versions,
those versions should have different module paths.  This convention is called
[semantic import versioning](https://research.swtch.com/vgo-import):

* rsc.io/quote for v1.*
* rsc.io/quote/v2 for v2.*
* rsc.io/quote/v3 for v3.*
* ... and so on.

Having different paths for different major versions of a module gives module
consumers the ability to upgrade to a new major version incrementally.

Read the documentation on the specified module:

```sh
go doc rsc.io/quote/v3
```

Clean up unused dependencies:

```sh
go mod tidy
```

## Part 2 — Migrating To Go Modules

`go mod init` automatically imports dependencies from a number of formats used
by a non-modules dependency manager tools.

`go mod tidy` finds all the packages transitively imported by your packages.

Run `go list -m all` and compare the resulting versions with your old
dependency management file.  If you find a version that wasn't what you wanted,
you can find out why using `go mod why -m` and/or `go mod graph`, and upgrade
or downgrade to the correct version using `go get`:

```sh
$ go mod why -m rsc.io/binaryregexp
[...]
$ go mod graph | grep rsc.io/binaryregexp
[...]
$ go get rsc.io/binaryregexp@v0.2.0
$
```

Using `go mod init` we can set the [custom import
path](https://golang.org/cmd/go/#hdr-Remote_import_paths). Users may import
packages with this path, and we must be careful not to change it.

The `module` directive in `go.mod` declares the module path.

When `go mod tidy` adds a requirement, it adds the latest version of the
module.  You may wish to downgrade some modules with `go get`.

`go test all` runs tests within the module cache, which is read-only.
It may fail for a test that write files in the package directory.  The
test should copy files it needs to write to a temporary directory instead.

Similarly, for test inputs: you may need to copy the test inputs into your
module, or convert the test inputs from raw files to data embedded in `.go`
source files.

You should tag and publish a release version for your new module.  Otherwise
downstream users will depend on specific commits using pseudo-versions, which
may be more difficult to support.

```sh
$ git tag v1.2.0
$ git push origin v1.2.0
```

When using modules, the import path must match the canonical module path, if
specified by [// import
comments](https://golang.org/cmd/go/#hdr-Import_path_checking).

A Go module with a major version above 1 must include a major-version suffix in
its module path: for example, version `v2.0.0` must have the suffix `/v2`.

## Part 3 — Publishing Go Modules

TODO https://blog.golang.org/publishing-go-modules

## Part 4 — Go Modules: v2 and Beyond

TODO https://blog.golang.org/v2-go-modules

# Go & Versioning, by Russ Cox, Feb 2018 – Dec 2019

Link: https://research.swtch.com/vgo

TODO
