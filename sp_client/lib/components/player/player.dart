import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';

@Component(
  selector: 'app-player',
  styleUrls: const ['player.css'],
  templateUrl: 'player.html',
  directives: const [
    materialDirectives
  ],
  providers: const [
    materialProviders
  ],
)
class PlayerComponent implements OnInit {
  @override
  ngOnInit() async {
  }
}
