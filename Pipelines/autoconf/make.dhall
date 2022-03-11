let Pipeline = ../../Melange/Pipeline/schema.dhall

in  Pipeline::{ runs = "make -j\$(nproc)" }
