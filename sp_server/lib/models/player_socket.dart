import 'package:sp_shared/sp_shared.dart';
import 'package:socket_io/socket_io.dart';

class PlayerSocket {
  Player player;
  Socket socket;

  PlayerSocket(this.player, this.socket);
}