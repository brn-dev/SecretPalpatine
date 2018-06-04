import 'dart:async';

import 'dart:convert';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';

import 'todo_list_service.dart';

import 'package:socket_io_client/socket_io_client.dart';

import 'package:sh_shared/sh_shared.dart';

@Component(
  selector: 'todo-list',
  styleUrls: const ['todo_list_component.css'],
  templateUrl: 'todo_list_component.html',
  directives: const [
    CORE_DIRECTIVES,
    materialDirectives,
  ],
  providers: const [TodoListService],
)
class TodoListComponent implements OnInit {
  final TodoListService todoListService;

  List<String> items = [];
  String newTodo = '';

  TodoListComponent(this.todoListService);

  @override
  Future<Null> ngOnInit() async {
    items = await todoListService.getTodoList();

    Socket socket = io('http://localhost:88');
    print('connecting');
    socket.on('connect', (_) {
      socket.emit(SocketIoEvents.setName, 'Brn');
      socket.emit(SocketIoEvents.createLobby, 'Brn Lobby');
      socket.once(SocketIoEvents.lobbyCreated, (String lobbyJson) {});
      socket.emit(SocketIoEvents.getLobbies);
      socket.once(SocketIoEvents.lobbies, (lobbiesJson) {
        List<Lobby> lobbies = JSON
            .decode(lobbiesJson)
            .forEach((lobbyJson) => new Lobby.fromJson(lobbyJson));
        print(lobbies);
        print(lobbiesJson);
      });
    });
  }

  void add() {
    items.add(newTodo);
    newTodo = '';
  }

  String remove(int index) => items.removeAt(index);

  void onReorder(ReorderEvent e) =>
      items.insert(e.destIndex, items.removeAt(e.sourceIndex));
}
