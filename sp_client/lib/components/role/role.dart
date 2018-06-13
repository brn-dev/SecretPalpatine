import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';

@Component(
  selector: 'app-role',
  styleUrls: const ['role.css'],
  templateUrl: 'role.html',
  directives: const [
    materialDirectives
  ],
  providers: const [
    materialProviders
  ],
)
class RoleComponent implements OnInit {
  @override
  ngOnInit() async {
  }
}
