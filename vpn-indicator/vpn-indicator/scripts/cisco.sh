#!/bin/bash

VPN="/opt/cisco/secureclient/bin/vpn"
SERVER="$1"
USER="$2"
PASS="$3"
OTP="$4"

export PATH="/opt/homebrew/bin:$PATH"

#OTP=$(oathtool --totp -b "$SECRET")


# -s forces scripted input mode (required) > ~/tools/log.txt  2>&1
"$VPN" -s connect "$SERVER"  <<EOF
$USER
$PASS
$OTP
y
EOF

