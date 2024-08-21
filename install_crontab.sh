#!/bin/bash
# Create the necessary directories for crontab 
mkdir -p /data/data/com.termux/files/home/.cache/crontab

# Install root-repo and cronie
pkg install -y root-repo
pkg upgrade -y
pkg install -y cronie

# Create the stop_ccminer.sh script
cat <<EOF > ~/stop_ccminer.sh
#!/bin/bash
# Stop ccminer
pkill ccminer
EOF

# Make stop_ccminer.sh executable
chmod +x ~/stop_ccminer.sh

# Set up crontab entries
(crontab -l 2>/dev/null; echo "0 7 * * * /data/data/com.termux/files/home/ccminer/start_cc.sh") | crontab -
(crontab -l 2>/dev/null; echo "0 18 * * * ~/stop_ccminer.sh") | crontab -

# Remove the existing start.sh and create a new one
rm -f /data/data/com.termux/files/home/ccminer/start.sh
cat <<EOF > /data/data/com.termux/files/home/ccminer/start.sh
#!/data/data/com.termux/files/usr/bin/bash
termux-wake-lock
crond
sshd
echo "Termux is ready."

# Display the current crontab configuration
echo "Current crontab configuration:"
crontab -l

# Get the current hour (24-hour format)
current_hour=\$(date +"%H")

# Run ccminer if the time is between 07:00 and 18:00
if [ "\$current_hour" -ge 7 ] && [ "\$current_hour" -lt 18 ]; then
  ~/ccminer/ccminer -c ~/ccminer/config.json
else
  echo "ccminer will not run outside 07:00 - 18:00."
fi
EOF

# Make start.sh executable
chmod +x /data/data/com.termux/files/home/ccminer/start.sh

# Create the /data/data/com.termux/files/home/ccminer/start_cc.sh script
cat <<EOF > /data/data/com.termux/files/home/ccminer/start_cc.sh
#!/bin/sh
# Run ccminer
~/ccminer/ccminer -c ~/ccminer/config.json
EOF

# Make start_cc.sh executable
chmod +x /data/data/com.termux/files/home/ccminer/start_cc.sh

echo "Installation and configuration complete."
