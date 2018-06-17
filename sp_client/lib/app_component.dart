import 'dart:async';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:sp_client/components/game/game.dart';
import 'package:sp_client/services/game_state_service.dart';
import 'package:sp_client/services/socket_io_service.dart';
import 'package:angular_router/angular_router.dart';
import 'package:sp_client/components/name_input_component/name_input_component.dart';
import 'package:sp_client/components/lobbies_page_component/lobbies_page_component.dart';

import 'package:sp_shared/sp_shared.dart';

// AngularDart info: https://webdev.dartlang.org/angular
// Components info: https://webdev.dartlang.org/components

@RouteConfig(const
  [
    const Route(path: '/lobbies', name: 'Lobbies', component: LobbiesPageComponent, data: const{'name': 'PlayerName'}),
    const Route(path: '/', name: 'Home', component: NameInputComponent)
  ]
)

@Component(
  selector: 'my-app',
  styleUrls: const ['app_component.scss.css'],
  templateUrl: 'app_component.html',
  directives: const [ROUTER_DIRECTIVES, NameInputComponent],
  providers: const [materialProviders, GameStateService, SocketIoService],
)
class AppComponent {
  SocketIoService service;
  GameStateService gameState;
  AppComponent(this.service, this.gameState) {}
}
