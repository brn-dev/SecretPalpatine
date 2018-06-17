import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:sp_shared/sp_shared.dart';

@Component(
  selector: 'app-membership-dialog',
  styleUrls: const ['membership_dialog.scss.css'],
  templateUrl: 'membership_dialog.html',
  directives: const [
    CORE_DIRECTIVES,
    materialDirectives
  ],
  providers: const [
    materialProviders
  ],
)
class MembershipDialogComponent implements OnInit {

  String loyalistMembershipImgUrl = '/assets/images/membership/loyalistMembership.gif';
  String separatistMembershipImgUrl = '/assets/images/membership/seperatistMembership.gif';
  String hiddenMembershipImgUrl = '/assets/images/membership/partyMember.gif';

  bool showMembership = false;

  bool _showDialog = false;

  @Input()
  set showDialog(bool value) {
    showMembership = false;
    _showDialog = value;
  }
  bool get showDialog => _showDialog;

  @Input()
  bool membership;

  @Input()
  Player player;

  @override
  ngOnInit() async {
  }

  void onOk() {
    showDialog = false;
  }
}
