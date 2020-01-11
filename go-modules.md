# Go Modules in Go Blog, Mar 2019 – Nov 2019

It's better to work-through the series executing the commands.

## Part 1 — Using Go Modules

Link: https://blog.golang.org/using-go-modules

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

Link: https://blog.golang.org/migrating-to-go-modules

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

Link: https://blog.golang.org/publishing-go-modules

You can specify pre-release versions by appending a hyphen and dot separated
identifiers (for example, v1.0.1-alpha or v2.2.2-beta.2). Normal releases are
preferred by the go command over pre-release versions, so users must ask for
pre-release versions explicitly, if your module has any normal releases.

The versions are [sorted as follows](https://semver.org/#spec-item-11):

* 0.1.0
* 0.1.1
* 1.0.0-alpha
* 1.0.0-alpha.1
* 1.0.0-alpha.beta
* 1.0.0-beta
* 1.0.0-beta.2
* 1.0.0-beta.11
* 1.0.0-rc.1
* 1.0.0
* 2.0.0
* 2.1.0
* 2.1.1

Dot-separated identifiers consisting of only digits are compared numerically
and identifiers with letters or hyphens are compared lexically in ASCII sort
order.  A larger set of pre-release fields has a higher precedence than a
smaller set.

`v0` major versions and pre-release versions do not guarantee backwards
compatibility.

`v1` major versions and beyond require backwards compatibility within that major
version.

The [module mirror and checksum
database](https://blog.golang.org/module-mirror-launch) store modules, their
versions, and signed cryptographic hashes to ensure that the build of a given
version remains reproducible over time.

Before each tagging, run

```sh
$ go mod tidy
$ go test ./...
```

Upon pushing a tag, explicitly request that version via `go get
module@version`. After one minute for caches to expire, the go command will see
that tagged version. If this doesn't work for you, please file an issue.

Run `go list -m example.com/hello@v0.1.0` to confirm the latest version is
available.

## Part 4 — Go Modules: v2 and Beyond

Link: https://blog.golang.org/v2-go-modules

A new major version of a module must have a different module path than the
previous major version. Starting with v2, the major version must appear at
the end of the module path

* preceded with slash, like `/v1`
* preceded with dot, like `.v1` - for [gopkg.in](https://labix.org/gopkg.in)
  packages only.

Although a version suffix is part of the import path, code importing it must
still refer to the Go package using its actual name, without a suffix.

Suffixes are needed to solve the *diamond dependency problem*.

It's recommended to develop multiple major versions in the master branch
because it is compatible with a wider variety of existing tools. So it's not
mandatory unless you wish to support those tools (such as `dep`).

# Modules in Go Wiki

Link: https://github.com/golang/go/wiki/Modules @
[b49ecf0e4c71819312481dc3a991394499328609](https://github.com/golang/go/wiki/Modules/b49ecf0e4c71819312481dc3a991394499328609)

If you have private code, you most likely should configure the GOPRIVATE
setting (such as go env -w
GOPRIVATE=bitbucket.org/secret/repo,github.com/secret/repo)

`go list -m all` — View final versions used in build

`go list -u -m all` — Similar, also view versions upgrades

`go get -u`  — Upgrade the deps of your current package, but not the entire module.

`go get -u ./...` — Upgrade deps to latest minor versions, for the entire module, excluding test dependencies.

`go get -u -t ./...` – Similar, but also upgrades test dependencies.

`go get -u=patch ./...` — Similar, upgrade deps to latest patch versions, excluding test dependencies.

When upgrading foo, start from doing `go get` without `-u`:
```sh
$ go get foo

# and after things are working, consider one of:
$ go get -u=patch foo
$ go get -u=patch
$ go get -u foo
$ go get -u
```

To upgrade or downgrade to a more specific version, `go get` allows version
selection to be overridden by adding an `@version` suffix or ["module
query"](https://golang.org/cmd/go/#hdr-Module_queries) to the package argument,
such as:
```sh
$ go get foo@v1.6.2
$ go get foo@e3702bed2
$ go get foo@'<v1.6.2'
```

When writing install instructions for module `foo`, don't mention `go get foo`.
For your consumer, simply adding an import statement `import "foo"` is
sufficient. (Subsequent commands like `go build` or `go test` will
automatically download `foo` and update `go.mod` as needed).

TODO: https://github.com/golang/go/wiki/Modules#avoid-breaking-existing-import-paths

# Go & Versioning, by Russ Cox, Feb 2018 – Dec 2019

Link: https://youtu.be/F8nrpe0XWRg

Link: https://go.googlesource.com/proposal/+/master/design/24301-versioned-go.md

Link: https://research.swtch.com/vgo

TODO
