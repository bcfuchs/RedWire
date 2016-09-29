echo "STARTING websocket server on port " $WS_PORT
docker run -d  --name glass_ws -p $WS_PORT:8092 -v $PWD:/app  tmc/nodejs-ws  ws/ws_server.js
