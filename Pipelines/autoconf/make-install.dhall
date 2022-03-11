λ(name : Text) →
  let baseDir = "/home/build/melange-out/"

  let Pipeline = ../../Melange/Pipeline/schema.dhall

  in  Pipeline::{
      , runs =
          ''
          make install DESTDIR="${baseDir}${name}"
          ''
      }
