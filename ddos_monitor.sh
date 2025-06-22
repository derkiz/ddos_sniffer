# Config
INTERFACE="eth0"                 # Change to your network interface
THRESHOLD=100                   # SYN packet count threshold to trigger alert
LOG_FILE="/var/log/ddos_monitor.log"
DEBUG_LOG="/var/log/ddos_monitor_debug.log"

echo "[INIT] Starting DDoS monitor on interface $INTERFACE" | tee -a "$LOG_FILE"

# Check if interface exists
if ! ip link show "$INTERFACE" > /dev/null 2>&1; then
    echo "Error: Interface $INTERFACE does not exist" | tee -a "$LOG_FILE"
    exit 1
fi

monitor_packets() {
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$TIMESTAMP] Monitoring packets on $INTERFACE..." | tee -a "$DEBUG_LOG"

    CAPTURE_FILE=$(mktemp /tmp/ddos_capture.XXXXXX.pcap)
    echo "[$TIMESTAMP] Created capture file: $CAPTURE_FILE" >> "$DEBUG_LOG"

    # Capture packets for 10 seconds
    tshark -i "$INTERFACE" -a duration:10 -w "$CAPTURE_FILE" > /dev/null 2>&1
    echo "[$TIMESTAMP] Finished tshark capture" >> "$DEBUG_LOG"

    # Count SYN packets (TCP flag syn set, ack not set)
    SYN_COUNT=$(tshark -r "$CAPTURE_FILE" -Y "tcp.flags.syn == 1 && tcp.flags.ack == 0" 2>/dev/null | wc -l)
    echo "[$TIMESTAMP] SYN packet count: $SYN_COUNT" >> "$DEBUG_LOG"

    if [ "$SYN_COUNT" -gt "$THRESHOLD" ]; then
        ALERT="ALERT [$TIMESTAMP]: Possible DDoS detected! SYN count = $SYN_COUNT"
        echo "$ALERT" | tee -a "$LOG_FILE"
    else
        echo "[$TIMESTAMP]: No DDoS detected. SYN count = $SYN_COUNT" >> "$LOG_FILE"
    fi

    rm -f "$CAPTURE_FILE"
}

while true; do
    monitor_packets
    sleep 5  # Small delay before next check to reduce CPU load
done
