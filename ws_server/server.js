var port = process.argv[2] || 10110
var WebSocketServer = require('ws').Server
, wss = new WebSocketServer({ port: port },function(e){console.log(e);console.log("listening on port " + port);});

wss.on('connection', function connection(ws) {
    ws.on('message', function incoming(message) {
	console.log('received: %s', message);
	ws.send("good");
    });

    ws.send('some');
});
