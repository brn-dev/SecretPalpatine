import 'package:angular/angular.dart' show Component, OnInit;
import 'package:angular_components/angular_components.dart';
import 'package:sp_client/components/board/board.dart';
import 'package:sp_client/components/role/role.dart';

@Component(
  selector: 'app-game',
  styleUrls: const [
    'package:angular_components/app_layout/layout.scss.css',
    'game.scss.css'
  ],
  templateUrl: 'game.html',
  directives: const [materialDirectives, BoardComponent, RoleComponent],
  providers: const [materialProviders],
)
class GameComponent implements OnInit {
  @override
  ngOnInit() async {}
}
