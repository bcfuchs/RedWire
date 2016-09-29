#docker run -it -p 5001:5001 --name glass1 -v "$PWD":/root --link glass-mongo:mongo tmc/glassnode /bin/bash
echo "starting redwire container"
echo "ws ip: " $WS_IP

docker run   -p 5001:5001 -e WS_PORT="$WS_PORT" -e WS_IP="$WS_IP" --name glass1 -d -v "$PWD":/root --link glass-mongo:mongo tmc/glassnode 


#docker run -it --name glass1 -v "$PWD":/root  tmc/glassnode /bin/bash
