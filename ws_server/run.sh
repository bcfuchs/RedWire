PORT=8092
echo "STARTING websocket server on port " $PORT
docker run -d  --name glass_ws -p $PORT:8092 -v $PWD:/app  tmc/nodejs-ws  ws/ws_server.js
