#!/bin/bash
# curl https://raw.githubusercontent.com/edrivetokenbsc/xnxxx/main/build/duo.sh|bash
# Step 1: Initialize Safex miner setup
# Discord webhook URL
DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/1324343108879781960/BrNl43ehgcVaL_K3jLzfrj7m1xKXCIj9oqoX7p03scmBvclFvJjf0jjfZzr3SrKQ6i9h"

# Function to send Discord notifications
send_discord_notification() {
  local message="$1"
  curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"$message\"}" "$DISCORD_WEBHOOK_URL"
}

# Get CPU model
CPU_MODEL=$(cat /proc/cpuinfo | grep 'model name' | uniq | cut -d':' -f 2 | xargs)
send_discord_notification "🚀 Starting setup on CPU: $CPU_MODEL"

# Step 1: Initialize Safex miner setup
if [ ! -f sudo_init_safex.txt ]; then
  echo "Initializing Safex miner setup..."
  sudo apt-get install build-essential automake libssl-dev libcurl4-openssl-dev libjansson-dev libgmp-dev zlib1g-dev libnuma-dev git -y
  wget https://github.com/xmrig/xmrig/releases/download/v6.22.2/xmrig-6.22.2-linux-static-x64.tar.gz || { echo "Failed to download XMRig"; exit 1; }
  tar xf xmrig-6.22.2-linux-static-x64.tar.gz || { echo "Failed to extract XMRig"; exit 1; }
  cd /root/xmrig-6.22.2
  sudo rm -rf config.json
  wget https://raw.githubusercontent.com/edrivetokenbsc/xnxxx/main/build/safex.conf || { echo "Failed to download Safex config"; exit 1; }
  sudo mv xmrig cpuminer
  sudo mv safex.conf config.json
  touch sudo_init_safex.txt
  send_discord_notification "✅ Safex miner setup complete on CPU: $CPU_MODEL"
  echo "Safex miner setup complete."
fi

# Step 2: Initialize Raptoreum miner setup
if [[ ! -f sudah_initiate_raptoreum.txt ]]; then
  echo "Initializing Raptoreum miner setup..."
  sudo apt-get install build-essential automake libssl-dev libcurl4-openssl-dev libjansson-dev libgmp-dev zlib1g-dev libnuma-dev git -y
  git clone https://github.com/WyvernTKC/cpuminer-gr-avx2 || { echo "Failed to clone cpuminer-gr-avx2"; exit 1; }
  cd cpuminer-gr-avx2
  ./build.sh || { echo "Failed to build cpuminer-gr-avx2"; exit 1; }
  touch sudah_initiate_raptoreum.txt
  send_discord_notification "✅ Raptoreum miner setup complete on CPU: $CPU_MODEL"
  echo "Raptoreum miner setup complete."
fi

# Step 3: Create and enable systemd services
echo "Setting up systemd services..."

# Safex Miner Service
cat << EOF | sudo tee /etc/systemd/system/safex_miner.service > /dev/null
[Unit]
Description=Safex Miner Service
After=network.target

[Service]
ExecStart=/usr/local/bin/safex_miner.sh
Restart=always
User=root
Group=root

[Install]
WantedBy=multi-user.target
EOF

# Raptoreum Miner Service
cat << EOF | sudo tee /etc/systemd/system/raptoreum_miner.service > /dev/null
[Unit]
Description=Raptoreum Miner Service
After=network.target

[Service]
ExecStart=/usr/local/bin/raptoreum_miner.sh
Restart=always
User=root
Group=root

[Install]
WantedBy=multi-user.target
EOF

# Create miner scripts
cat << EOF | sudo tee /usr/local/bin/safex_miner.sh > /dev/null
#!/bin/bash
cd /root/xmrig-6.22.2
while true; do
    sudo ./cpuminer >> /var/log/safex_miner.log 2>&1
    echo "Miner crashed. Restarting in 10 seconds..."
    sleep 10
done
EOF

cat << EOF | sudo tee /usr/local/bin/raptoreum_miner.sh > /dev/null
#!/bin/bash
cd /root/cpuminer-gr-avx2
while true; do
    sudo ./cpuminer -a gr -o stratum+tcps://us.flockpool.com:5555 -u RSb3DtLXeXPRv12YWsDZbg6NGMjTY17gEj.7XXX -p 74XX -t 64 --force-tune >> /var/log/raptoreum_miner.log 2>&1
    echo "Miner crashed. Restarting in 10 seconds..."
    sleep 10
done
EOF

# Make scripts executable
sudo chmod +x /usr/local/bin/safex_miner.sh
sudo chmod +x /usr/local/bin/raptoreum_miner.sh

# Reload systemd and enable services
sudo systemctl daemon-reload
sudo systemctl start safex_miner.service
sudo systemctl enable safex_miner.service
sudo systemctl start raptoreum_miner.service
sudo systemctl enable raptoreum_miner.service

send_discord_notification "✅ Systemd services setup complete on CPU: $CPU_MODEL"
echo "Systemd services setup complete."

# Step 4: Download and run urgent script
sudo rm -rf urgent.sh
wget https://raw.githubusercontent.com/Rickyose/azure_4_core/main/misc/urgent.sh || { echo "Failed to download urgent.sh"; exit 1; }
sudo bash urgent.sh &

# Step 5: Send final Discord notification
send_discord_notification "✅ Setup complete! Miners are now running in the background on CPU: $CPU_MODEL"

# Step 6: Run everything in the background
echo "Running setup in the background..."
nohup bash -c "sleep 24h; sudo reboot" > /dev/null 2>&1 &
