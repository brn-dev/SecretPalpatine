import 'package:angular_components/angular_components.dart';
import 'package:sp_client/services/game_state_service.dart';
import 'package:sp_client/services/socket_io_service.dart';
import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';

@Component(
    selector: 'name-input-component',
    templateUrl: 'name_input_component.html',
    directives: const [materialDirectives],
    styleUrls: const ['name_input_component.scss.css'],
    providers: const [materialProviders])
class NameInputComponent {
  String name;
  Router router;

  NameInputComponent(this.router);

  setName() {
    print('setting name ${name}');
    this.router.navigate([
      'Lobbies',
      {'name': name}
    ]);
  }
}
