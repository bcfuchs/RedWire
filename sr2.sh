#!/bin/bash
ip=$1
port=$2
echo "var mobiler_qr_port=$port ;" > client/vendor/mobiler/port.js
echo "var mobiler_qr_ip=\"$ip\" ;" > client/vendor/mobiler/ip.js
echo "ip: " $ip " port: " $port 


cd ~/client
echo "building RedWire"
grunt build &> /dev/null

echo "DONE building REDWIRE"

cd ~/server
echo "STARTING dpd"
PORT=2403 coffee  runProduction.coffee &> /dev/null &
echo "STARTED dpd"

#cd ~/client
#echo "STARTING grunt watch"
#grunt watch &> /dev/null &

nginx -c ~/server/nginx.conf -g 'daemon off;'
echo "STARTING nginx"
