#!/usr/bin/env python3
import rumps
import subprocess
import time
import threading
from pathlib import Path


TOOLS = Path.home() / "tools"
VPN_BIN = "/opt/cisco/secureclient/bin/vpn"
VPN_SERVER = "vpn-ac.urz.uni-heidelberg.de"

VPN_CONNECT_SCRIPT = TOOLS / "cisco.sh"
VPN_DISCONNECT_SCRIPT = TOOLS / "dis_cisco.sh"


def vpn_connected():
    try:
        out = subprocess.check_output([VPN_BIN, "state"]).decode()
        return "Connected" in out
    except Exception:
        return False


def vpn_connect():
    subprocess.Popen([
    "osascript",
    "-e",
    f'tell application "Terminal" to do script "{VPN_CONNECT_SCRIPT}" in front window',
    "-e", 'tell application "Terminal" to set visible of front window to false'
])


def vpn_disconnect():
    subprocess.Popen([VPN_DISCONNECT_SCRIPT])


class VPNStatusApp(rumps.App):
    def __init__(self):
        super().__init__("VPN", icon=None)

        self.menu = [
            rumps.MenuItem("Connect VPN", callback=self.on_connect),
            rumps.MenuItem("Disconnect VPN", callback=self.on_disconnect),
            rumps.MenuItem("Quit", callback=rumps.quit_application)
        ]

        threading.Thread(target=self.update_loop, daemon=True).start()

    def on_connect(self, _):
        vpn_connect()

    def on_disconnect(self, _):
        vpn_disconnect()

    def update_loop(self):
        while True:
            if vpn_connected():
                self.title = "VPN ✓"
            else:
                self.title = "VPN ✗"
            time.sleep(5)


if __name__ == "__main__":
    VPNStatusApp().run()