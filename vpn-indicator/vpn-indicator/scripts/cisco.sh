#!/bin/bash

VPN="/opt/cisco/secureclient/bin/vpn"
SERVER="$1"
USER="$2"
PASS="$3"
SECRET="$4"

export PATH="/opt/homebrew/bin:$PATH"

OTP=$(oathtool --totp -b "$SECRET")

# -s forces scripted input mode (required)
"$VPN" -s connect "$SERVER" > ~/tools/log.txt  2>&1 <<EOF
$USER
$PASS
$OTP
y
EOF

