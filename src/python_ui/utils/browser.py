#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Browser detection and launching utility for Pipe Network PoP Web UI
"""

import os
import sys
import subprocess
import logging
import socket
import time
from threading import Thread

logger = logging.getLogger(__name__)

def detect_browser():
    """
    Detect available browsers on the system
    Returns the command to launch a browser, or None if no browser is found
    """
    # Common browser commands by platform
    browsers = []
    
    if sys.platform.startswith('darwin'):  # macOS
        browsers = [
            ('open', ['-a', 'Safari']),
            ('open', ['-a', 'Google Chrome']),
            ('open', ['-a', 'Firefox']),
            ('open', ['-a', 'Microsoft Edge'])
        ]
    elif sys.platform.startswith('win'):  # Windows
        program_files = os.environ.get('PROGRAMFILES', 'C:\\Program Files')
        program_files_x86 = os.environ.get('PROGRAMFILES(X86)', 'C:\\Program Files (x86)')
        
        browsers = [
            (os.path.join(program_files_x86, 'Microsoft\\Edge\\Application\\msedge.exe'), []),
            (os.path.join(program_files, 'Google\\Chrome\\Application\\chrome.exe'), []),
            (os.path.join(program_files_x86, 'Google\\Chrome\\Application\\chrome.exe'), []),
            (os.path.join(program_files, 'Mozilla Firefox\\firefox.exe'), []),
            (os.path.join(program_files_x86, 'Mozilla Firefox\\firefox.exe'), []),
            ('start', [''])  # Windows fallback using 'start' command
        ]
    else:  # Linux and others
        browsers = [
            ('xdg-open', []),  # Linux standard
            ('gnome-open', []),  # GNOME
            ('kde-open', []),  # KDE
            ('firefox', []),
            ('google-chrome', []),
            ('chromium-browser', []),
            ('brave-browser', []),
            ('opera', [])
        ]
    
    # Add cross-platform options at the end
    browsers.extend([
        ('python', ['-m', 'webbrowser']),
        ('python3', ['-m', 'webbrowser'])
    ])
    
    for browser_cmd, args in browsers:
        try:
            # Check if the browser command exists
            if os.path.isfile(browser_cmd):
                return (browser_cmd, args)
            else:
                # Try to find the command in PATH
                which_cmd = 'where' if sys.platform.startswith('win') else 'which'
                result = subprocess.run(
                    [which_cmd, browser_cmd],
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE,
                    universal_newlines=True,
                    shell=(sys.platform.startswith('win'))
                )
                if result.returncode == 0:
                    return (browser_cmd, args)
        except:
            continue
    
    return None

def launch_browser(url):
    """
    Launch the default browser with the given URL
    Returns True if successful, False otherwise
    """
    try:
        browser = detect_browser()
        if not browser:
            logger.warning("No browser detected")
            return False
        
        browser_cmd, args = browser
        
        # Special handling for Python webbrowser module
        if browser_cmd in ('python', 'python3'):
            import webbrowser
            webbrowser.open(url)
            return True
        
        # Special handling for 'open', 'xdg-open', 'gnome-open', 'kde-open'
        if browser_cmd in ('open', 'xdg-open', 'gnome-open', 'kde-open'):
            args = [url]
        # Special handling for Windows 'start'
        elif browser_cmd == 'start':
            args = [url]
        else:
            args.append(url)
        
        logger.info(f"Launching browser: {browser_cmd} {' '.join(args)}")
        
        if sys.platform.startswith('win') and browser_cmd == 'start':
            # Windows 'start' command needs shell=True
            subprocess.Popen(f"{browser_cmd} {url}", shell=True)
        else:
            subprocess.Popen([browser_cmd] + args)
        
        return True
    except Exception as e:
        logger.error(f"Error launching browser: {e}")
        return False

def is_port_available(port, host='localhost'):
    """Check if a port is available on the given host"""
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(1)
        result = sock.connect_ex((host, port))
        sock.close()
        return result != 0
    except:
        return False

def wait_for_port(port, host='localhost', timeout=30, interval=0.5):
    """Wait until a port is open on the given host"""
    start_time = time.time()
    while time.time() - start_time < timeout:
        if not is_port_available(port, host):
            return True
        time.sleep(interval)
    return False

def launch_browser_when_ready(url, port, host='localhost', timeout=30):
    """Launch browser once the server is ready on the given port"""
    def _wait_and_launch():
        if wait_for_port(port, host, timeout):
            launch_browser(url)
    
    thread = Thread(target=_wait_and_launch)
    thread.daemon = True
    thread.start()
    return thread

if __name__ == '__main__':
    # Set up logging for standalone testing
    logging.basicConfig(level=logging.INFO)
    
    # Test browser detection
    browser = detect_browser()
    if browser:
        print(f"Detected browser: {browser[0]}")
        
        # If URL provided, launch browser
        if len(sys.argv) > 1:
            url = sys.argv[1]
            print(f"Launching {url}...")
            if launch_browser(url):
                print("Browser launched successfully")
            else:
                print("Failed to launch browser")
    else:
        print("No browser detected") 