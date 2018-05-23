import { createServer } from 'http';
import * as express from 'express';
import * as socketIo from 'socket.io';
export class SHServer {
    constructor(port = 88) {
        this.port = port;
    }
    createApp() {
        this.app = express();
    }
    createServer() {
        this.server = createServer(this.app);
    }
    config() {
        this.port = process.env.PORT || this.port;
    }
    createIoServer() {
        this.io = socketIo(this.server);
    }
    listen() {
        this.server.listen(this.port, () => {
            console.log('SecretHitler-Server running on port %s', this.port);
        });
        this.io.on('connect', (socket) => {
            console.log('Client connected');
            socket.on('message', (msg) => {
                console.log('Client message: %s', msg);
                socket.broadcast.emit('message', msg);
            });
        });
    }
    getApp() {
        return this.app;
    }
}
//# sourceMappingURL=sh-server.js.map