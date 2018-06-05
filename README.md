# SecretPalpatine
Digital version of the board game [Secret Hitler](secrethitler.com) with [Secret Palpatine](https://steamcommunity.com/sharedfiles/filedetails/?id=597522954) skin.

## Technologies
### Backend
Dart + [SocketIO-Dart](https://github.com/rikulo/socket.io-dart)
### Frontend
Angulardart + [SocketIO-Client-Dart](https://github.com/rikulo/socket.io-client-dart)

## Structure
* sp_client: The client app for the game
* sp_server: Manages the clients and the communication between the clients
* sp_shared: A package which provides some models and other data to the other two packages listed above.
