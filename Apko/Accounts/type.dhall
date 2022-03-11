let User = { UserName : Text, UID : Text, GID : Text }

let Group = { GroupName : Text, GID : Text, Members : List Text }

in  { RunAs : Text, Users : List User, Groups : List Group }
