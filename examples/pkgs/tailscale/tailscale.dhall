let fetchUrl = ../../../Pipelines/fetch.dhall

let Melange = ../../../Melange/package.dhall

let Apko = ../../../Apko/package.dhall

let Package = Melange.Package

let ApkoConfig = Apko.Config

let MelangeConfig = Melange.Config

let package =
      Package::{
      , name = "tailscale"
      , version = "1.22.1"
      , epoch = 0
      , description = "The easiest, most secure way to use WireGuard and 2FA"
      , target-architecture = [ "all" ]
      , copyright =
          -- FIXME: figure out attestation ??
          [ { paths = [ "*" ], attestation = "", license = "BSD-3-Clause" } ]
      }

in  MelangeConfig::{
    , package
    , environment = ApkoConfig::{
      , contents =
        { keyring = ../../utils/default-keys.dhall
        , repositories =
          [ "https://dl-cdn.alpinelinux.org/alpine/edge/main"
          , "https://dl-cdn.alpinelinux.org/alpine/edge/community"
          ]
        , packages =
          [ "go"
          , "linux-headers"
          , "busybox"
          , "ca-certificates-bundle"
          , "ssl_client"
          ]
        }
      , archs = [ "all" ]
      }
    , pipeline =
      [ fetchUrl
          { uri =
              "https://github.com/tailscale/tailscale/archive/v${package.version}.tar.gz"
          , sha256 =
              "c62511df1d8777f2d3a3bbc8182f0371ad0c5f93da3f590a98fa6383e4d16501"
          , extract = True
          }
      , ../../../Pipelines/build-go-package.dhall
          { packageName = package.name
          , subPackages = [ "./cmd/tailscale", "./cmd/tailscaled" ]
          }
      , Melange.Pipeline::{
        , runs =
            let pkgDir = "/home/build/melange-out/tailscale"

            in  ''
                install -m755 -D tailscale \
                  ${pkgDir}/usr/bin/tailscale
                install -m755 -D tailscaled \
                  ${pkgDir}/usr/sbin/tailscaled

                install -m644 -D -t "${pkgDir}"/usr/share/doc/${package.name} README.md

                install -m755 -D ./tailscale.initd ${pkgDir}/etc/init.d/tailscale
                install -m644 -D ./tailscale.confd ${pkgDir}/etc/conf.d/tailscale
                install -m644 -D ./tailscale.logrotate ${pkgDir}/etc/logrotate.d/tailscale
                install -m644 -D ./tailscale.modules-load ${pkgDir}/usr/lib/modules-load.d/tailscale.conf
                ''
        }
      ]
    }
