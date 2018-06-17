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
class LobbiesPageComponent {
  RouteParams routeParams;
  GameStateService gameStateService;
  SocketIoService socketService;
  List<Lobby> lobbies;
  bool showDialog = false;
  String lobbyName = "";
  Router router;

  ngOnInit() async {
    this.lobbies = await this.socketService.getLobbies();
    this.gameStateService.lobby = this.socketService.whenLobbyJoined();
    this.socketService.whenGameStarted().then((role) {
      print("E");
      this.gameStateService.role = role;
      this.router.navigate(['Game']);
    });
    while (true) {
      var stream = await this.socketService.whenLobbyCreated();
      this.lobbies.add(await stream.first);
    }
  }

  LobbiesPageComponent(this.routeParams, this.gameStateService, this.router) {
    this.socketService = new SocketIoService(gameStateService);
    this.socketService.setName(routeParams.get('name'));
    ngOnInit();
  }
  void createLobby() {
    print(this.lobbyName);
    this.socketService.createLobby(this.lobbyName);
    showDialog = false;
  }

  Future joinLobby(Lobby lobby) async {
    this.socketService.joinLobby(lobby.id);
    this.lobbies = await this.socketService.getLobbies();
  }

  void startGame() {
    this.socketService.startGame();
  }
}
