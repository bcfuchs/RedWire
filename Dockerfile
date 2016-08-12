FROM node:4.4.7


RUN npm install -g grunt-cli deployd bower forever
RUN npm install -g coffee-script

RUN apt-get update
RUN apt-get install -y nginx 


RUN mkdir -p /usr/src/app
WORKDIR /root

#ONBUILD COPY package.json /usr/src/app/
#ONBUILD RUN npm install
#ONBUILD COPY . /usr/src/app

CMD [ "bash", "run2.sh" ]
EXPOSE 5001
EXPOSE 5000
