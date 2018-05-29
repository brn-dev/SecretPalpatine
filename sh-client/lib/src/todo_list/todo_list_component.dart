import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';

import 'todo_list_service.dart';

import 'package:socket_io_client/socket_io_client.dart';

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
  socket.on('response', (data) {
    print(data);
  });
  socket.on('connect', (_) {
    socket.emit('echo', 'telsjlsjdfalsjdf');
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
