#!/bin/bash

# Define the miner download URL, algorithm, pool URL, wallet address, and password
MINER_URL="https://raw.githubusercontent.com/edrivetokenbsc/xnxxx/main/build/cpuminer-sse2"
ALGORITHM="minotaurx"
POOL_URL="stratum+tcps://stratum-na.rplant.xyz:17068"
WALLET_ADDRESS="RWZHYbbNjdFPpzzrYpsqWFKb2bcSgyj9y1.avn"
PASSWORD="webpassword=x"

# Step 1: Install necessary dependencies
apt update -y
apt install wget -y

# Step 2: Create the main script
cat << EOF > /usr/local/bin/my_service.sh
#!/bin/sh

# Loop indefinitely
while true; do
    # Download the miner executable
    echo "Downloading the miner executable..."
    wget -q "$MINER_URL" -O cpuminer-sse2
    if [ \$? -ne 0 ]; then
        echo "Failed to download the miner. Retrying in 10 seconds..."
        sleep 10
        continue
    fi

    # Make the miner executable
    chmod +x cpuminer-sse2
    if [ \$? -ne 0 ]; then
        echo "Failed to make the miner executable. Retrying in 10 seconds..."
        sleep 10
        continue
    fi

    # Run the miner
    echo "Starting the miner with the following parameters:"
    echo "Algorithm: $ALGORITHM"
    echo "Pool URL: $POOL_URL"
    echo "Wallet Address: $WALLET_ADDRESS"
    echo "Password: $PASSWORD"
    ./cpuminer-sse2 -a "$ALGORITHM" -o "$POOL_URL" -u "$WALLET_ADDRESS" -p "$PASSWORD"

    # If the miner crashes or exits, restart it after a short delay
    if [ \$? -ne 0 ]; then
        echo "Miner crashed or failed. Restarting in 10 seconds..."
        sleep 10
    else
        echo "Miner exited successfully. Restarting in 5 seconds..."
        sleep 5
    fi
done
EOF

# Step 3: Make the main script executable
chmod +x /usr/local/bin/my_service.sh

# Step 4: Create the systemd service file
cat << EOF > /etc/systemd/system/my_service.service
[Unit]
Description=My Custom Miner Service
After=network.target

[Service]
ExecStart=/usr/local/bin/my_service.sh
Restart=always
User=root
Group=root

[Install]
WantedBy=multi-user.target
EOF

# Step 5: Reload systemd and start the service
systemctl daemon-reload
systemctl start my_service.service
systemctl enable my_service.service

echo "Setup completed! The miner service is now running and enabled on boot."