
import 'package:socket_io/socket_io.dart';

class SHServer {
  final int port;
  Server io;

  SHServer([this.port = 88]) {
    createServer();
  }

  void createServer() {
    io = new Server();

    io.on('connection', (Socket client) {
      print('client connected');
      client.on('echo', (data) {
        print(data);
        client.emit('response', data);
        print('echoed data: ${data}');
      });
    });
  }

  void start() {
    io.listen(port);
    print("sh-server listening on port: ${port}");
  }
}