let Pipeline = ../../Melange/Pipeline/schema.dhall

in  Pipeline::{
    , runs =
        ''
        ./configure \
          --prefix=/usr \
          --libdir=/lib \
          --mandir=/usr/share/man \
          --infodir=/usr/share/info \
          --localstatedir=/var
        ''
    }
