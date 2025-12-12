from setuptools import setup

APP = ['vpn_indicator.py']

DATA_FILES = [
    ('', ['light.png', 'light_connected.png'])  # Include your icon files here
]


OPTIONS = {
    'argv_emulation': True,
    'packages': ['rumps'],
    'plist': {
        'LSUIElement': True  # hides dock icon
    }
}

setup(
    app=APP,
    data_files=DATA_FILES,
    options={'py2app': OPTIONS},
    setup_requires=['py2app']
)
