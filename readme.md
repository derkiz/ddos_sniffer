# Raspberry Pi DDoS Monitor Setup

This project is a simple Bash-based DDoS monitor designed to detect potential SYN flood attacks on a Raspberry Pi running Raspberry Pi OS Lite. It’s a hands-on learning exercise to practice Linux scripting, network traffic analysis with `tshark`, and basic security monitoring. Perfect for anyone wanting to explore system monitoring and network defense fundamentals in a lightweight, practical way.

A lightweight Bash script that monitors potential SYN flood (DDoS) attacks using `tshark`, designed to run on **Raspberry Pi OS Lite** (headless setup, no desktop).

## ✅ Requirements

- Raspberry Pi running **Raspberry Pi OS Lite**
- Internet connection
- `tshark` installed:
  ```bash
  sudo apt update
  sudo apt install tshark
  ```

## 🚀 Installation

1. **Create the monitoring script:**

   ```bash
   nano ~/ddos_monitor.sh
   ```

   > **Note:** The script file can be placed anywhere on your Raspberry Pi,  
   > but it’s recommended to keep it in your user home directory (e.g., `/home/pi/`)  
   > for easier access and management.

2. **Paste the script** ([see `ddos_monitor.sh`](./ddos_monitor.sh)) and save.

3. **Make it executable:**

   ```bash
   chmod +x ~/ddos_monitor.sh
   ```

4. **Run on boot via `crontab`:**

   ```bash
   crontab -e
   ```

   Add this line to the bottom:

   ```bash
   @reboot /home/pi/ddos_monitor.sh
   ```

5. **Reboot to test:**

   ```bash
   sudo reboot
   ```

6. **Check if it’s running:**

   ```bash
   ps aux | grep ddos_monitor
   tail -f /tmp/ddos_monitor.log
   ```

7. **To run manually (after SSH login):**

   ```bash
   sudo ./ddos_monitor.sh
   ```

## 🧪 How It Works

- Captures traffic on the defined network interface (`eth0` or `wlan0`)
- Analyzes for SYN packets every 10 seconds
- Logs alerts if packet counts exceed a defined threshold

## 📁 Logs

- Alerts: `/tmp/ddos_monitor.log`
- Debug info: `/tmp/ddos_monitor_debug.log`

## 🛡️ Tips

- Adjust the `THRESHOLD` in the script based on your network traffic
- Update the network interface (`INTERFACE=eth0`) if needed
- Test the monitor from another machine on the network using:

  ```bash
  sudo hping3 --flood --syn -p 80 YOUR_PI_IP
  ```
