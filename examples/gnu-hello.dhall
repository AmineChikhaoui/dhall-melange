let fetchUrl = ../Pipelines/fetch.dhall

let Melange = ./../Melange/package.dhall

let Apko = ./../Apko/package.dhall

let Package = Melange.Package

let ApkoConfig = Apko.Config

let MelangeConfig = Melange.Config

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
