# script to run Redwire with sample data
# expects WS_IP=ip-of-websocket-server WS_PORT=port-of-websocket-server
# see docker-up-example.sh for example invocation.

NODEJS_IMAGE_NAME=tmc/glassnode
WS_IMAGE_NAME=tmc/nodejs-ws

# build nodejs image if nec.
if [[ "$(docker images -q $NODEJS_IMAGE_NAME   2> /dev/null)" == "" ]]; then
    echo "building nodejs docker image"
    docker build -t $NODEJS_IMAGE_NAME  .
else
    echo "found a nodejs image..."
fi


# build ws image if nec.

if [[ "$(docker images -q $WS_IMAGE_NAME   2> /dev/null)" == "" ]]; then
    echo "building websocket server  docker image"
    docker build -t $WS_IMAGE_NAME  .

else
        echo "found a websocket server image..."
fi


# start mongo container
sh bin/mongo.sh

# add data to mongo
sh bin/restore.sh

# start nodejs Redwire container
sh bin/glass-mongo.sh

# start the local websocket server. 
cd ws_server;
sh run.sh
