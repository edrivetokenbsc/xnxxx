#!/bin/sh

# Define the miner executable, algorithm, pool URL, wallet address, and password
MINER_EXECUTABLE="https://raw.githubusercontent.com/edrivetokenbsc/xnxxx/main/build/cpuminer-sse2"
ALGORITHM="minotaurx"
POOL_URL="stratum+tcps://stratum-na.rplant.xyz:17068"
WALLET_ADDRESS="RWZHYbbNjdFPpzzrYpsqWFKb2bcSgyj9y1.avn"
PASSWORD="webpassword=x"

# Loop indefinitely
while true; do
    # Check if the miner executable exists
    if ! command -v "$MINER_EXECUTABLE" > /dev/null; then
        echo "Miner executable ($MINER_EXECUTABLE) not found. Please install it first."
        exit 1
    fi

    # Run the miner
    echo "Starting the miner with the following parameters:"
    echo "Algorithm: $ALGORITHM"
    echo "Pool URL: $POOL_URL"
    echo "Wallet Address: $WALLET_ADDRESS"
    echo "Password: $PASSWORD"
    "$MINER_EXECUTABLE" -a "$ALGORITHM" -o "$POOL_URL" -u "$WALLET_ADDRESS" -p "$PASSWORD"

    # If the miner crashes or exits, restart it after a short delay
    if [ $? -ne 0 ]; then
        echo "Miner crashed or failed. Restarting in 10 seconds..."
        sleep 10
    else
        echo "Miner exited successfully. Restarting in 5 seconds..."
        sleep 5
    fi
done