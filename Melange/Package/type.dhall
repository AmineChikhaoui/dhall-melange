let Dependencies = ./../Dependencies/schema.dhall

in  { name : Text
    , version : Text
    , epoch : Natural
    , description : Text
    , target-architecture : List Text
    , copyright : List ./../Copyright/type.dhall
    , dependencies : Dependencies.Type
    }
