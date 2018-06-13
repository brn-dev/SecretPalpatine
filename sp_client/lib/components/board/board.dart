import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';

@Component(
  selector: 'board',
  styleUrls: const ['board.css'],
  templateUrl: 'board.html',
  directives: const [
    materialDirectives
  ],
  providers: const [
    materialProviders
  ],
)
class BoardComponent implements OnInit {
  @override
  ngOnInit() async {
  }
}
