# SecretPalpatine
Digital version of the board game [Secret Hitler](secrethitler.com)

#### Why is this called 'SecretPalpatine' then?
Simply because many people don't know Secret Hitler and I don't want people to wonder why I have a repository with the name of the nazi's leader in the repository's name

## Technologies
### Backend
Dart + [SocketIO-Dart](https://github.com/rikulo/socket.io-dart)
### Frontend
Angulardart + [SocketIO-Client-Dart](https://github.com/rikulo/socket.io-client-dart)

## Structure
* sh-client: The client app for the game
* sh-server: Manages the clients and the communication between the clients
* sh-shared: A package which provides some models and other data two the other two packages listed above.
