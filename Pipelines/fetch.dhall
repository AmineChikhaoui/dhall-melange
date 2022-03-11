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
