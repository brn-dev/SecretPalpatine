import 'dart:async';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:sp_client/services/game_state_service.dart';

@Component(
  selector: 'app-vote-dialog',
  styleUrls: const ['vote_dialog.scss.css'],
  templateUrl: 'vote_dialog.html',
  directives: const [materialDirectives],
  providers: const [materialProviders],
)
class VoteDialogComponent implements OnInit {
  final _finishedVoting = new StreamController<bool>();
  GameStateService gameStateService;

  VoteDialogComponent(this.gameStateService);

  @Output()
  Stream<bool> get finishedVoting => _finishedVoting.stream;

  @Input()
  bool showDialog;

  @override
  ngOnInit() async {}

  void vote(bool vote) {
    _finishedVoting.add(vote);
    showDialog = false;
  }
}
