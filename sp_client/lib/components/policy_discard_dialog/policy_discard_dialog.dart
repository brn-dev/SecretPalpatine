import 'dart:async';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';

class DiscardResult {
  bool discardedPolicy;
  bool veto;

  DiscardResult(this.discardedPolicy, this.veto);
}

@Component(
  selector: 'app-policy-discard-dialog',
  styleUrls: const ['policy_discard_dialog.scss.css'],
  templateUrl: 'policy_discard_dialog.html',
  directives: const [CORE_DIRECTIVES, materialDirectives],
  providers: const [materialProviders],
)
class PolicyDiscardDialogComponent implements OnInit {

  String loyalistPolicyImgUrl = './assets/images/policy/loyalistPolicy.gif';
  String separatistPolicyImgUrl = './assets/images/policy/separatistPolicy.gif';
  String hiddenPolicyImgUrl = './assets/images/policy/galacticPolicy.gif';

  String discardActionText =  'choose a policy to discard';
  String peekActionText = 'have a look at the top 3 policies';

  bool showPolicies = false;

  final _finished = new StreamController<DiscardResult>();
  bool _showDialog = false;
  bool veto = false;


  @Output()
  Stream<DiscardResult> get finished => _finished.stream;

  @Input()
  List<bool> policies;

  @Input()
  bool hideOnFinished = true;

  @Input()
  bool isPolicyPeek = false;

  @Input()
  bool vetoEnabled = false;

  @Input()
  set showDialog(bool value) {
    showPolicies = false;
    veto = false;
    _showDialog = value;
  }
  get showDialog => _showDialog;

  String get actionText => isPolicyPeek ? peekActionText : discardActionText;

  @override
  ngOnInit() async {}

  void discardPolicy(bool policy) {
    if (isPolicyPeek || !showPolicies) {
      return;
    }

    _finished.add(new DiscardResult(policy, veto));

    if (hideOnFinished) {
      showDialog = false;
    }
  }

  void onOk() {
    showDialog = false;
    _finished.add(null);
  }
}
