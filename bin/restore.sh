# import db
docker run \
       --rm  \
       --link glass-mongo:mongo \
       -v "$PWD"/data:/backup \
       mongo \
       bash -c 'mongorestore /backup --host $MONGO_PORT_27017_TCP_ADDR'
