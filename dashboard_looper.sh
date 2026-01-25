#!/bin/bash

echo "Starting High-Speed Dashboard Updater..."
echo "Press [Ctrl+C] to stop."

while true; do
    # Run the analyzer script
    ./analyzer.sh
    
    # Wait 1 second before doing it again
    sleep 1
done
