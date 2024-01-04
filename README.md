# Realtime Player Updater
Allows player to update their model, skin, bodygroups, weapon color and player color in real time!

## Where is Lua code?
Written in [Yuescript](https://github.com/pigpigyyy/Yuescript), compiled Lua code can be found in [releases](https://github.com/Pika-Software/realtime-player-updater/releases), or you can compile it yourself using compiled [Yuescript Compiler](https://github.com/pigpigyyy/Yuescript/releases/latest).

## Developer API
All functions and hooks are **shared**, which means they exist on both the server and the client.

#### rpu.Receivers
A table with all server-side callbacks, it **does not exist** on the client!

#### rpu.Register( `string` conVarName, `function` callback )
Adds callback to convar, must be added on both client and server side to work, client side callback is optional.

#### GM:RPULoaded( `function` registrationFunction )
Called after the RPU is fully loaded, the first argument is [rui.Register](#rpuregister-string-convarname-function-callback-) function.

#### GM:RPUChange( `Player` ply, `string` conVarName, `string` value )
Called before the callback is executed and allows you to block it by returning false here.

#### GM:RPUChanged( `Player` ply, `string` conVarName, `string` value )
Called after `RPUChange`, additional network data can be written here on the client side, which can be obtained in `RPUChange` and `RPUChanged` on the server side using the [net](https://wiki.facepunch.com/gmod/net) library.
