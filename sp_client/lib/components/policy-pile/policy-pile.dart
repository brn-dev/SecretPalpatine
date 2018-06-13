import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';

@Component(
  selector: 'app-policy-pile',
  styleUrls: const ['policy-pile.css'],
  templateUrl: 'policy-pile.html',
  directives: const [
    materialDirectives
  ],
  providers: const [
    materialProviders
  ],
)
class PolicyPileComponent implements OnInit {
  @override
  ngOnInit() async {
  }
}
