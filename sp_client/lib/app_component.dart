import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:sp_client/components/name_input_component/name_input_component.dart';
import 'package:sp_client/services/game_state_service.dart';
import 'package:sp_client/services/socket_io_service.dart';

// AngularDart info: https://webdev.dartlang.org/angular
// Components info: https://webdev.dartlang.org/components

@Component(
  selector: 'my-app',
  styleUrls: const ['app_component.css'],
  templateUrl: 'app_component.html',
  directives: const [materialDirectives, NameInputComponent],
  providers: const [materialProviders, GameStateService, SocketIoService],
)
class AppComponent {
  SocketIoService service;
  GameStateService gameState;
  AppComponent(this.service, this.gameState) {}
}
