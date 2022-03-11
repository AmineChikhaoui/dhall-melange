{- Convenience helper for building go binaries
-}
let concatMapSep =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/v21.1.0/Prelude/Text/concatMapSep.dhall
        sha256:c272aca80a607bc5963d1fcb38819e7e0d3e72ac4d02b1183b1afb6a91340840

in  let Pipeline = ../Melange/Pipeline/schema.dhall

    in  λ(args : { packageName : Text, subPackages : List Text }) →
          let pkgDir = "/home/build/melange-out/tailscale"

          in  Pipeline::{
              , runs =
                  let buildSubPkg = λ(path : Text) → "go build ${path}"

                  in      ''
                          echo "Prepare GOPATH and GOBIN..."
                          export GOPATH=$(go env GOPATH)
                          export GOBIN="$GOPATH/bin"
                          ''
                      ++  concatMapSep "\n" Text buildSubPkg args.subPackages
              }
