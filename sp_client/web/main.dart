import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'package:sp_client/app_component.dart';
import 'package:sp_client/services/game_state_service.dart';
import 'package:sp_client/services/socket_io_service.dart';

void main() {
  bootstrap(AppComponent, [
    ROUTER_PROVIDERS,
    GameStateService,
    SocketIoService
  ]);
}
