import 'dart:async';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:sp_client/components/game/game.dart';
import 'package:sp_client/services/game_state_service.dart';
import 'package:sp_client/services/socket_io_service.dart';
import 'package:sp_shared/sp_shared.dart';

// AngularDart info: https://webdev.dartlang.org/angular
// Components info: https://webdev.dartlang.org/components

@Component(
  selector: 'secret-palpatine',
  styleUrls: const ['app_component.scss.css'],
  templateUrl: 'app_component.html',
  directives: const [materialDirectives, GameComponent],
  providers: const [materialProviders, GameStateService, SocketIoService],
)
class AppComponent implements OnInit {

  SocketIoService service;
  SocketIoService gameState;

  AppComponent(this.service, this.gameState) {
  }

  Future ngOnInit() async {
    service.setName('Test');
    service.createLobby('lob');
    Lobby l = await service.whenLobbyJoined();
    print(l);
  }
}
