import { createServer, Server } from 'http';
import * as express from 'express';
import * as socketIo from 'socket.io';
import { ADDRCONFIG } from 'dns';

export class SHServer {

  private app: express.Application;
  private server: Server;
  private io: SocketIO.Server;

  private port: string | number;

  constructor(port: number = 88) {
    this.port = port;
  }

  private createApp(): void {
    this.app = express();
  }

  private createServer(): void {
    this.server = createServer(this.app);
  }

  private config(): void {
    this.port = process.env.PORT || this.port;
  }

  private createIoServer(): void {
    this.io = socketIo(this.server);
  }

  private listen(): void {
      this.server.listen(this.port, () => {
        console.log('SecretHitler-Server running on port %s', this.port);
      });

      this.io.on('connect', (socket) => {
        console.log('Client connected');
        socket.on('message', (msg: string) => {
            console.log('Client message: %s', msg);
            socket.broadcast.emit('message', msg);
        });
      });
  }

  public getApp(): express.Application {
    return this.app;
  }
}
