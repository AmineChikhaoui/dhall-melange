λ(packageName : Text) →
  [ ./autoconf/configure.dhall
  , ./autoconf/make.dhall
  , ./autoconf/make-install.dhall packageName
  ]
