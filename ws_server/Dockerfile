# FROM mhart/alpine-node:base-0.10
FROM mhart/alpine-node

# RUN apk add --no-cache make gcc g++ python
#RUN apk add npm
# If you need npm, don't use a base tag

RUN npm install -g ws websocket

# set the path to node modules
ENV NODE_PATH /usr/lib/node_modules

RUN mkdir /app
WORKDIR /app

EXPOSE 8092

ENTRYPOINT ["node"]