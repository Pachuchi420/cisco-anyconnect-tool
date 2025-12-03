from setuptools import setup

APP = ['vpn-indicator.py']
OPTIONS = {
    'argv_emulation': False,
    'packages': ['rumps'],
    'plist': {
        'LSUIElement': True  # hides dock icon
    }
}

setup(
    app=APP,
    options={'py2app': OPTIONS},
    setup_requires=['py2app']
)
