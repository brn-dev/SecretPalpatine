import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';

@Component(
  selector: 'game',
  styleUrls: const ['package:angular_components/app_layout/layout.scss.css','game.scss.css'],
  templateUrl: 'game.html',
  directives: const [materialDirectives],
  providers: const [materialProviders],
)
class GameComponent implements OnInit {
  bool customWidth = false;
  bool end = false;
  @override
  ngOnInit() async {}
}
