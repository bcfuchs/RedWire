# script to run Redwire with sample data
# see docker-up-example.sh for params. 

IMAGE_NAME=tmc/glassnode
# build image if nec.
if [[ "$(docker images -q $IMAGE_NAME   2> /dev/null)" == "" ]]; then
     docker build -t tmc/glassnode .
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
