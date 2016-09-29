#!/usr/bin/env coffee

# Based on http://docs.deployd.com/docs/server/run-script.md
# Meant to be launched with forever.js to avoid failure

deployd = require('deployd')

# Use port 5000 and a separate MongoDB instance
config = 
  port: process.env.PORT || 2403
  env: 'dev'
  db: 
    host: process.env.MONGO_PORT_27017_TCP_ADDR || 'localhost'
    port: 27017
    name: 'redwire'
console.log(config)
server = deployd(config)
server.listen()

server.on('listening', -> console.log("Server is listening on port #{config.port}"))

server.on 'error', (err) ->
  console.error(err)
  process.nextTick -> # Give the server a chance to return an error
    process.exit()
