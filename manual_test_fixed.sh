#!/bin/bash
# Script to manually test the Pipe Network binary with ports 80 and 443

echo "Stopping the pipe-pop service first..."
sudo systemctl stop pipe-pop.service

echo "Setting capabilities on the binary..."
sudo setcap 'cap_net_bind_service=+ep' /opt/pipe-pop/bin/pipe-pop

# Copy node_info.json to the correct locations
echo "Copying node_info.json to necessary locations..."
sudo cp /home/karo/node_info.json /opt/pipe-pop/node_info.json
sudo cp /home/karo/node_info.json /opt/pipe-pop/bin/node_info.json
sudo chmod 644 /opt/pipe-pop/node_info.json /opt/pipe-pop/bin/node_info.json

echo "Testing manual execution with regular permissions (should work for port 8003)..."
cd /opt/pipe-pop
echo "Running with standard port 8003..."
./bin/pipe-pop --ram 8 --max-disk 500 --cache-dir /data --pubKey H6sA2GwmppUTWHW7NAhw66NBDi9Bh7LvmGTJ6CUQU5e8 &
PID1=$!
sleep 10
echo "Testing port 8003..."
curl -I http://localhost:8003 || echo "Port 8003 not responding"
kill $PID1
sleep 2

echo "Running with --enable-80-443 flag..."
./bin/pipe-pop --ram 8 --max-disk 500 --cache-dir /data --pubKey H6sA2GwmppUTWHW7NAhw66NBDi9Bh7LvmGTJ6CUQU5e8 --enable-80-443 &
PID2=$!
sleep 10
echo "Testing port 80..."
curl -I http://localhost:80 || echo "Port 80 not responding"
echo "Testing port 443..."
curl -I http://localhost:443 || echo "Port 443 not responding"
kill $PID2
sleep 2

echo "Testing with sudo (should work for all ports)..."
sudo ./bin/pipe-pop --ram 8 --max-disk 500 --cache-dir /data --pubKey H6sA2GwmppUTWHW7NAhw66NBDi9Bh7LvmGTJ6CUQU5e8 --enable-80-443 &
PID3=$!
sleep 10
echo "Testing port 80 with sudo execution..."
curl -I http://localhost:80 || echo "Port 80 not responding with sudo"
echo "Testing port 443 with sudo execution..."
curl -I http://localhost:443 || echo "Port 443 not responding with sudo"
kill $PID3
sleep 2

echo "Restarting the service..."
sudo systemctl start pipe-pop.service

echo "Tests completed." 