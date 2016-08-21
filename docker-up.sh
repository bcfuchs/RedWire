docker rm glass-mongo
docker rm glass1
echo "wsip" $WS_IP

sh bin/mongo.sh
sh bin/restore.sh
sh bin/glass-mongo.sh
cd ws_server
sh run-it.sh
