# dhall-melange [EXPERIMENTAL]

`dhall-melange` contains [dhall-lang](https://github.com/dhall-lang/dhall-lang)
bindings to [melange](https://github.com/chainguard-dev/melange) (the new tool
for creating [APK](https://git.alpinelinux.org/apk-tools/about/) packages), so
you can generate `melange` recipes from Dhall expressions.
This will let you easily typecheck, template and modularize your Melange recipes.

## Example

GNU hello package recipe which is the equivalent of `melange`'s
[example](https://github.com/chainguard-dev/melange/blob/main/examples/gnu-hello.yaml).

```dhall
-- ./examples/gnu-hello.dhall
let fetchUrl = ../Pipelines/fetch.dhall

let Package = ../Melange/Package/schema.dhall

let ApkoConfig = ../Apko/Config/schema.dhall

let MelangeConfig = ../Melange/Config/schema.dhall

let package =
      Package::{
      , name = "hello"
      , version = "2.12"
      , epoch = 0
      , description = "The GNU hello world program"
      , target-architecture = [ "all" ]
      , copyright =
        [ { paths = [ "*" ]
          , attestation =
              ''
              Copyright 1992, 1995, 1996, 1997, 1998, 1999, 2000, 2001, 2002, 2005,
              2006, 2007, 2008, 2010, 2011, 2013, 2014, 2022 Free Software Foundation,
              Inc.
              ''
          , license = "GPL-3.0-or-later"
          }
        ]
      }

in  MelangeConfig::{
    , package
    , environment = ApkoConfig::{
      , contents =
        { keyring = ./utils/default-keys.dhall
        , repositories = [ "https://dl-cdn.alpinelinux.org/alpine/edge/main" ]
        , packages =
          [ "alpine-baselayout-data"
          , "busybox"
          , "build-base"
          , "ssl_client"
          , "ca-certificates-bundle"
          ]
        }
      , archs = [ "all" ]
      }
    , pipeline =
          [ fetchUrl
              { uri =
                  "https://ftp.gnu.org/gnu/hello/hello-${package.version}.tar.gz"
              , sha256 =
                  "cf04af86dc085268c5f4470fbae49b18afbc221b78096aab842d934a76bad0ab"
              , extract = True
              }
          ]
        # ../Pipelines/default-build.dhall package.name
    }

```

The resulting yaml file generated through `dhall-to-yaml` is pretty much the
same thing as the example in the
[Melange](https://github.com/chainguard-dev/melange) repository. The only
difference is that we render the pipelines through `Dhall` in this case, so
instead of doing:

```yaml
- uses: fetch
    with:
      uri: https://ftp.gnu.org/gnu/hello/hello-${{package.version}}.tar.gz
      expected-sha256: cf04af86dc085268c5f4470fbae49b18afbc221b78096aab842d934a76bad0ab
      extract: true
```

which requires substitution of the variables during runtime, we simply use
`dhall` functions to render the `runs` command directly

```dhall
-- Pipelines/fetch.dhall
let Pipeline = ../Melange/Pipeline/schema.dhall

in  λ(input : { uri : Text, sha256 : Text, extract : Bool }) →
      Pipeline::{
      , runs =
          ''
          wget ${input.uri}
          bn=$(basename ${input.uri})
          printf "%s  %s\n" '${input.sha256}' $bn | sha256sum -c
          ${if    input.extract
            then  ''
                  bn=$(basename ${input.uri})
                  tar -zx --strip-components=1 -f $bn
                  ''
            else  ""}
          ''
      }

```

The end result is:

```yaml
# dhall-to-yaml --file examples/gnu-hello.dhall
environment:
  archs:
    - all
  contents:
    keyring:
      - "https://alpinelinux.org/keys/alpine-devel@lists.alpinelinux.org-4a6a0840.rsa.pub"
      - "https://alpinelinux.org/keys/alpine-devel@lists.alpinelinux.org-4d07755e.rsa.pub"
      - "https://alpinelinux.org/keys/alpine-devel@lists.alpinelinux.org-5243ef4b.rsa.pub"
      - "https://alpinelinux.org/keys/alpine-devel@lists.alpinelinux.org-524d27bb.rsa.pub"
      - "https://alpinelinux.org/keys/alpine-devel@lists.alpinelinux.org-5261cecb.rsa.pub"
      - "https://alpinelinux.org/keys/alpine-devel@lists.alpinelinux.org-58199dcc.rsa.pub"
      - "https://alpinelinux.org/keys/alpine-devel@lists.alpinelinux.org-58cbb476.rsa.pub"
      - "https://alpinelinux.org/keys/alpine-devel@lists.alpinelinux.org-58e4f17d.rsa.pub"
      - "https://alpinelinux.org/keys/alpine-devel@lists.alpinelinux.org-60ac2099.rsa.pub"
    packages:
      - alpine-baselayout-data
      - busybox
      - build-base
      - ssl_client
      - ca-certificates-bundle
    repositories:
      - https://dl-cdn.alpinelinux.org/alpine/edge/main
package:
  copyright:
    - attestation: |
        Copyright 1992, 1995, 1996, 1997, 1998, 1999, 2000, 2001, 2002, 2005,
        2006, 2007, 2008, 2010, 2011, 2013, 2014, 2022 Free Software Foundation,
        Inc.
      license: GPL-3.0-or-later
      paths:
        - "*"
  dependencies: {}
  description: The GNU hello world program
  epoch: 0
  name: hello
  target-architecture:
    - all
  version: '2.12'
pipeline:
  - runs: |
      wget https://ftp.gnu.org/gnu/hello/hello-2.12.tar.gz
      bn=$(basename https://ftp.gnu.org/gnu/hello/hello-2.12.tar.gz)
      printf "%s  %s\n" 'cf04af86dc085268c5f4470fbae49b18afbc221b78096aab842d934a76bad0ab' $bn | sha256sum -c
      bn=$(basename https://ftp.gnu.org/gnu/hello/hello-2.12.tar.gz)
      tar -zx --strip-components=1 -f $bn

  - runs: |
      ./configure \
        --prefix=/usr \
        --libdir=/lib \
        --mandir=/usr/share/man \
        --infodir=/usr/share/info \
        --localstatedir=/var
  - runs: "make -j$(nproc)"
  - runs: |
      make install DESTDIR="/home/build/melange-out/hello"
```
