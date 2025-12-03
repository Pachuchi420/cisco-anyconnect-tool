#!/usr/bin/env python3
import os
import subprocess
import getpass
import shutil
from pathlib import Path
import sys

HOME = Path.home()
TOOLS = HOME / "tools"
APP_NAME = "vpn-indicator.app"
APP_DEST = Path("/Applications") / APP_NAME


def ensure(cmd):
    """Run a shell command, exit if failure."""
    print(f"→ {cmd}")
    result = subprocess.call(cmd, shell=True)
    if result != 0:
        print(f"ERROR running: {cmd}")
        sys.exit(1)


def brew_install(pkg):
    print(f"Installing {pkg} via Homebrew…")
    ensure(f"brew install {pkg}")


def ensure_dependencies():
    # Python 3.11 must exist
    if subprocess.call("python3.11 --version", shell=True) != 0:
        brew_install("python@3.11")

    # oathtool
    brew_install("oath-toolkit")

    # py2app & rumps (installed inside Python 3.11 environment)
    ensure("python3.11 -m pip install --upgrade pip setuptools wheel")
    ensure("python3.11 -m pip install py2app rumps")


def ask_credentials():
    print("=== Configure Cisco VPN Credentials ===")
    user = input("Username: ")
    pw = getpass.getpass("Password: ")
    secret = input("OTP Secret (Base32): ")
    return user, pw, secret


def install_scripts(username, password, secret):
    TOOLS.mkdir(exist_ok=True)
    template = Path("scripts/cisco.sh.template").read_text()

    filled = (
        template.replace("{{USERNAME}}", username)
                .replace("{{PASSWORD}}", password)
                .replace("{{SECRET}}", secret)
    )

    (TOOLS / "cisco.sh").write_text(filled)
    os.chmod(TOOLS / "cisco.sh", 0o700)

    shutil.copy("scripts/dis_cisco.sh", TOOLS / "dis_cisco.sh")
    os.chmod(TOOLS / "dis_cisco.sh", 0o700)


def build_app():
    print("Building VPN indicator app…")
    ensure("python3.11 build.py py2app")


def move_app():
    dist_app = Path("dist") / APP_NAME
    if not dist_app.exists():
        print("Build failed: app bundle not found.")
        sys.exit(1)

    if APP_DEST.exists():
        shutil.rmtree(APP_DEST)

    shutil.copytree(dist_app, APP_DEST)
    print(f"Installed app to {APP_DEST}")


def add_login_item():
    answer = input("Add to Login Items? (y/n): ").lower()
    if answer.startswith("y"):
        script = (
            'tell application "System Events" to make login item at end '
            f'with properties {{path:"{APP_DEST}", hidden:true}}'
        )
        subprocess.call(["osascript", "-e", script])
        print("Added to Login Items.")


def launch_app():
    subprocess.call(["open", str(APP_DEST)])


def main():
    print("=== VPN Indicator Installer ===")

    ensure_dependencies()
    u, p, s = ask_credentials()
    install_scripts(u, p, s)
    build_app()
    move_app()
    add_login_item()
    launch_app()

    print("Done. Your VPN indicator is now running.")


if __name__ == "__main__":
    main()
