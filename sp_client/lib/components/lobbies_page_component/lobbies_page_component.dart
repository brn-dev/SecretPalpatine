import 'dart:async';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_router/angular_router.dart';
import 'package:sp_client/services/game_state_service.dart';
import 'package:sp_client/services/socket_io_service.dart';
import 'package:sp_shared/src/models/lobby.dart';
import 'package:angular_forms/angular_forms.dart';

@Component(
    selector: 'lobbies-page-component',
    templateUrl: 'lobbies_page_component.html',
    styleUrls: const ['lobbies_page_component.scss.css'],
    directives: const [CORE_DIRECTIVES, materialDirectives],
    providers: const [materialProviders])
class LobbiesPageComponent implements OnInit {
  RouteParams routeParams;
  GameStateService gameStateService;
  SocketIoService socketService;
  List<Lobby> lobbies = new List<Lobby>();
  bool showDialog = false;
  String lobbyName = "";
  Router router;
  Lobby hostLobby = null;
  bool isJoined = false;

  ngOnInit() async {
    this.socketService.setName(routeParams.get('name'));
    await socketService.whenPlayerCreated();
    this.lobbies = await this.socketService.getLobbies();
    this.socketService.whenGameStarted().then((role) {
      print("E");
      this.gameStateService.role = role;
      this.router.navigate(['Game']);
    });
    listenForCreatedLobbies();
    listenForJoinedPlayers();
  }

  Future<Null> listenForCreatedLobbies() async {
    await for (var lobby in socketService.whenLobbyCreated()) {
      lobbies.add(lobby);
    }
  }

  Future<Null> listenForJoinedPlayers() async {
    await for (var player in socketService.whenPlayerJoined()) {
      gameStateService.players.add(player);
    }
  }

  LobbiesPageComponent(
      this.routeParams, this.router, this.gameStateService, this.socketService);

  Future createLobby() async {
    print(this.lobbyName);
    this.socketService.createLobby(this.lobbyName);
    var createdLobby = await this.socketService.whenLobbyJoined();
    lobbies.add(createdLobby);
    showDialog = false;
    isJoined = true;
    hostLobby = createdLobby;
    listenForPlayerLeaving();
  }

  Future joinLobby(Lobby lobby) async {
    this.socketService.joinLobby(lobby.id);
    var joinedLobby = await this.socketService.whenLobbyJoined();
    for (var i = 0; i < lobbies.length; i++) {
      if (lobbies[i].id == joinedLobby.id) {
        lobbies[i] = joinedLobby;
        break;
      }
    }
    isJoined = true;
    listenForPlayerLeaving();
  }

  void listenForPlayerLeaving() {
    socketService
        .listenForPlayersLeaving()
        .listen((player) => gameStateService.killedPlayers.add(player));
  }

  void startGame() {
    this.socketService.startGame();
  }
}
