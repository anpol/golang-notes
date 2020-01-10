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
go list -m rsc.io/q... — 
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

TODO

## Part 3 — Publishing Go Modules

TODO

## Part 4 — Go Modules: v2 and Beyond

TODO

# Go & Versioning, by Russ Cox, Feb 2018 – Dec 2019

Link: https://research.swtch.com/vgo

TODO
