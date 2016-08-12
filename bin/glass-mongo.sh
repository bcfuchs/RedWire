#docker run -it -p 5001:5001 --name glass1 -v "$PWD":/root --link glass-mongo:mongo tmc/glassnode /bin/bash
docker run   -p 5001:5001 --name glass1 -d -v "$PWD":/root --link glass-mongo:mongo tmc/glassnode 


#docker run -it --name glass1 -v "$PWD":/root  tmc/glassnode /bin/bash
