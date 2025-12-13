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
FILE_PATH = TOOLS / "log.txt"

def check_case(): 
    print(f"Looking for file at: {FILE_PATH}")
    with open(FILE_PATH, "r") as file:
        # Read all lines and filter out any empty or blank lines
        lines = [line.strip() for line in file.readlines() if line.strip()]
    
        if lines:
            last_line = lines[-1]
            return last_line
        file.close()

def read_log(): 
    with open(FILE_PATH, "r") as file: 
        content = file.read()
    file.close()
    return content


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
        super().__init__("VPN")
        self.icon="light.png"
        
        self.menu = [
            rumps.MenuItem("Connect VPN", callback=self.on_connect),
            rumps.MenuItem("Disconnect VPN", callback=self.on_disconnect)
        ]

        threading.Thread(target=self.update_loop, daemon=True).start()




    def show_error_window(self, title, message):
        # Escape double quotes in the message to prevent syntax errors
        escaped_message = message.replace('"', '\\"')

        # AppleScript for creating a single error window with a multiline text area
        script = f'''
        tell application "System Events"
            activate
            -- Create a single window to display the error message
            display dialog "There was an error connecting to the VPN, see detailed log below:" & return & "{escaped_message}" with title "{title}" buttons {{"OK"}} default button "OK"
        end tell
        '''
        
        subprocess.run(["osascript", "-e", script])


    def on_connect(self, _):
        vpn_connect()
        time.sleep(5)
        if check_case() != '>> state: Connected': 
            self.show_error_window("Error Connecting", read_log())
            

    def on_disconnect(self, _):
        vpn_disconnect()


    def update_loop(self):
        while True:
            if vpn_connected():
                self.icon = "light_connected.png"
            else:
                self.icon = "light.png"
            time.sleep(1)


if __name__ == "__main__":
    VPNStatusApp().run()