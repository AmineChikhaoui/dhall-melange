let User = { username : Text, uid : Text, gid : Text }

let Group = { groupname : Text, gid : Text, members : List Text }

in  { run-as : Text, users : List User, groups : List Group }
