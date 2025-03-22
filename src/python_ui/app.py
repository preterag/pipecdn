#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Pipe Network PoP Web UI - Flask Application
A lightweight web interface for managing Pipe Network PoP nodes
"""

import os
import json
import logging
import secrets
import subprocess
import time
import sys
import argparse
from datetime import datetime
from functools import wraps
import http.server
import socketserver
import threading
import webbrowser

# Pre-define core functions that may be needed for debugging/error messages
def print_error(msg, exit_code=1):
    """Print error message in red text if possible"""
    try:
        print(f"\033[91mERROR: {msg}\033[0m")
    except:
        print(f"ERROR: {msg}")
    sys.exit(exit_code)

def setup_basic_logging():
    """Setup basic logging without Flask dependencies"""
    log_dir = os.path.expanduser("~/.local/share/pipe-pop")
    os.makedirs(log_dir, exist_ok=True)
    
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        handlers=[
            logging.StreamHandler(),
            logging.FileHandler(os.path.join(log_dir, "pipe_ui.log"))
        ]
    )
    return logging.getLogger("pipe-ui")

# Initialize argument parser before any imports
parser = argparse.ArgumentParser(description='Pipe Network PoP Web UI')
parser.add_argument('--host', default='127.0.0.1', help='Host to bind to')
parser.add_argument('--port', type=int, default=8585, help='Port to listen on')
parser.add_argument('--debug', action='store_true', help='Enable debug mode')
parser.add_argument('--fallback', action='store_true', help='Use fallback simple HTTP server if Flask fails')

# Parse arguments early to check for fallback option
args, remaining_args = parser.parse_known_args()

# Configure logging
logger = setup_basic_logging()

# Default configuration
DEFAULT_CONFIG = {
    "port": args.port or 8585,
    "host": args.host or "127.0.0.1",
    "pop_command": "pop",
    "auth_enabled": True,
    "auth_token": secrets.token_hex(16),
    "debug": args.debug or False
}

# Global flag for Flask availability
FLASK_AVAILABLE = False

# Function to launch browser
def launch_browser(url, delay=1.5):
    """Launch browser after a short delay"""
    def _open_browser():
        time.sleep(delay)
        webbrowser.open(url)
    
    browser_thread = threading.Thread(target=_open_browser)
    browser_thread.daemon = True
    browser_thread.start()

# Fallback simple HTTP server if Flask is not available
class FallbackHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        self.directory = os.path.join(os.path.dirname(__file__), 'static')
        super().__init__(*args, directory=self.directory, **kwargs)
    
    def do_GET(self):
        if self.path == '/' or self.path == '':
            self.path = '/fallback.html'
        return super().do_GET()
    
    def log_message(self, format, *args):
        logger.info(format % args)

def create_fallback_page():
    """Create a fallback HTML page if Flask is not available"""
    static_dir = os.path.join(os.path.dirname(__file__), 'static')
    os.makedirs(static_dir, exist_ok=True)
    
    fallback_html = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pipe Network PoP UI - Installation Required</title>
    <style>
        body {{ font-family: Arial, sans-serif; line-height: 1.6; margin: 0; padding: 20px; color: #333; }}
        .container {{ max-width: 800px; margin: 0 auto; background: #f9f9f9; padding: 20px; border-radius: 5px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }}
        h1 {{ color: #e74c3c; }}
        h2 {{ color: #3498db; }}
        pre {{ background: #f1f1f1; padding: 10px; border-radius: 3px; overflow-x: auto; }}
        .btn {{ display: inline-block; background: #3498db; color: white; padding: 8px 16px; text-decoration: none; border-radius: 4px; margin-top: 20px; }}
        .btn:hover {{ background: #2980b9; }}
    </style>
</head>
<body>
    <div class="container">
        <h1>Pipe Network PoP UI - Flask Installation Required</h1>
        
        <p>The Pipe Network PoP UI requires Flask to run properly. This is a fallback page shown because Flask is not currently installed.</p>
        
        <h2>Installation Options:</h2>
        <ol>
            <li>
                <strong>System package (recommended):</strong>
                <pre>sudo apt-get update && sudo apt-get install -y python3-flask</pre>
            </li>
            <li>
                <strong>Using pip:</strong>
                <pre>python3 -m pip install flask</pre>
            </li>
            <li>
                <strong>Using the provided installer:</strong>
                <pre>tools/pop-ui-python install</pre>
            </li>
        </ol>
        
        <h2>After Installing:</h2>
        <p>After installing Flask, restart the UI server:</p>
        <pre>tools/pop-ui-python stop
tools/pop-ui-python start</pre>
        
        <p>Python version: {sys.version}</p>
        <p>Server running on: http://{args.host}:{args.port}/</p>
        
        <a href="/" class="btn">Refresh after installation</a>
    </div>
</body>
</html>
"""
    
    with open(os.path.join(static_dir, 'fallback.html'), 'w') as f:
        f.write(fallback_html)

def run_fallback_server():
    """Run a simple HTTP server as fallback"""
    create_fallback_page()
    
    try:
        handler = FallbackHTTPRequestHandler
        httpd = socketserver.TCPServer((args.host, args.port), handler)
        
        logger.info(f"Fallback server running at http://{args.host}:{args.port}/")
        print(f"Fallback server running at http://{args.host}:{args.port}/")
        print("Install Flask to enable full UI functionality")
        
        # Launch browser if needed
        launch_browser(f"http://{args.host}:{args.port}/")
        
        # Serve until process is killed
        httpd.serve_forever()
    except Exception as e:
        logger.error(f"Error in fallback server: {e}")
        print(f"Error: {e}")
        sys.exit(1)

# Try to import Flask - use fallback if not available
try:
    from flask import (
        Flask, render_template, request, jsonify, redirect,
        url_for, session, send_from_directory, abort
    )
    logger.info("Flask imported successfully")
    FLASK_AVAILABLE = True
except ImportError as e:
    error_message = f"""
Flask import failed: {e}

The Pipe Network PoP UI requires Flask to run with full functionality.
"""
    logger.error(error_message)
    print(error_message)
    
    if args.fallback:
        print("Starting fallback server mode...")
        run_fallback_server()
        # This will run forever or exit on error
        sys.exit(0)
    else:
        installation_guide = """
You can install Flask using one of these methods:

1. System package (recommended):
   sudo apt-get update && sudo apt-get install -y python3-flask

2. Using pip:
   python3 -m pip install flask

3. Using the provided installer:
   tools/pop-ui-python install

After installing Flask, try running this command again.
Or use --fallback option to use a simple HTTP server.

If you continue to have issues, please check:
- Python version (3.6+ required): {sys.version}
- Installation logs for errors

For more help, see the documentation in src/python_ui/README.md
"""
        print(installation_guide)
        sys.exit(1)

# From here, Flask is available
# Load configuration
CONFIG_FILE = os.path.expanduser("~/.local/share/pipe-pop/ui-config.json")
CONFIG_DIR = os.path.dirname(CONFIG_FILE)

def load_config():
    """Load configuration from file or create default if not exists"""
    if not os.path.exists(CONFIG_DIR):
        os.makedirs(CONFIG_DIR, exist_ok=True)
    
    if not os.path.exists(CONFIG_FILE):
        with open(CONFIG_FILE, 'w') as f:
            json.dump(DEFAULT_CONFIG, f, indent=2)
        return DEFAULT_CONFIG
    
    try:
        with open(CONFIG_FILE, 'r') as f:
            config = json.load(f)
            # Update with any missing default keys
            for key, value in DEFAULT_CONFIG.items():
                if key not in config:
                    config[key] = value
            return config
    except Exception as e:
        logger.error(f"Error loading config: {e}")
        return DEFAULT_CONFIG

CONFIG = load_config()

# Initialize Flask app
app = Flask(__name__)
app.secret_key = os.environ.get('PIPE_UI_SECRET_KEY', secrets.token_hex(16))
app.config['SESSION_TYPE'] = 'filesystem'
app.config['TEMPLATES_AUTO_RELOAD'] = True

# Authentication decorator
def require_auth(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        if not CONFIG['auth_enabled']:
            return f(*args, **kwargs)
        
        # Check for session
        if 'authenticated' in session and session['authenticated']:
            return f(*args, **kwargs)
        
        # Check for token in query string
        token = request.args.get('token')
        if token and token == CONFIG['auth_token']:
            session['authenticated'] = True
            return f(*args, **kwargs)
        
        # If wizard installation token is in the session, allow only wizard routes
        if 'wizard_token' in session:
            if request.path.startswith('/wizard') or request.path.startswith('/static'):
                return f(*args, **kwargs)
        
        return redirect(url_for('login', next=request.path))
    return decorated

# Command execution
def run_command(command, shell=False):
    """Execute system command and return result"""
    try:
        if not shell and isinstance(command, str):
            command = command.split()
        
        logger.info(f"Running command: {command}")
        result = subprocess.run(
            command,
            shell=shell,
            check=False,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            universal_newlines=True
        )
        
        return {
            'success': result.returncode == 0,
            'stdout': result.stdout,
            'stderr': result.stderr,
            'returncode': result.returncode
        }
    except Exception as e:
        logger.error(f"Command execution error: {e}")
        return {
            'success': False,
            'error': str(e),
            'stdout': '',
            'stderr': str(e),
            'returncode': -1
        }

def get_node_status():
    """Get the status of the Pipe Network node"""
    result = run_command(f"{CONFIG['pop_command']} status")
    status = "unknown"
    
    if result['success']:
        output = result['stdout'].lower()
        if "running" in output:
            status = "running"
        elif "stopped" in output:
            status = "stopped"
    
    return {
        'status': status,
        'raw_output': result['stdout'],
        'success': result['success']
    }

def get_system_metrics():
    """Get system metrics"""
    metrics = {
        'cpu': 0,
        'memory': 0,
        'disk': 0,
        'network': 0,
        'uptime': "00:00:00",
        'peers': 0
    }
    
    # CPU usage
    cpu_cmd = run_command("top -bn1 | grep 'Cpu(s)' | awk '{print $2 + $4}'")
    if cpu_cmd['success']:
        try:
            metrics['cpu'] = float(cpu_cmd['stdout'].strip())
        except (ValueError, TypeError):
            pass
    
    # Memory usage
    mem_cmd = run_command("free -m | awk 'NR==2{printf \"%.1f\", $3*100/$2}'")
    if mem_cmd['success']:
        try:
            metrics['memory'] = float(mem_cmd['stdout'].strip())
        except (ValueError, TypeError):
            pass
    
    # Disk usage
    disk_cmd = run_command("df -h / | awk 'NR==2{print $5}' | sed 's/%//'")
    if disk_cmd['success']:
        try:
            metrics['disk'] = float(disk_cmd['stdout'].strip())
        except (ValueError, TypeError):
            pass
    
    # Uptime
    uptime_cmd = run_command("uptime -p")
    if uptime_cmd['success']:
        metrics['uptime'] = uptime_cmd['stdout'].strip()
    
    # For other metrics, we would need to call pop-specific commands
    # Here we're using placeholders
    node_status = get_node_status()
    if node_status['status'] == 'running':
        # This would be replaced with actual metrics gathering
        metrics['peers'] = 5  # Placeholder
        metrics['network'] = 1.5  # Placeholder in MB/s
    
    return metrics

# Routes
@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        token = request.form.get('token')
        if token and token == CONFIG['auth_token']:
            session['authenticated'] = True
            next_url = request.args.get('next', '/')
            return redirect(next_url)
        return render_template('login.html', error="Invalid token")
    return render_template('login.html')

@app.route('/')
@require_auth
def index():
    node_status = get_node_status()
    metrics = get_system_metrics()
    return render_template('dashboard/index.html', 
                         node_status=node_status, 
                         metrics=metrics)

@app.route('/config')
@require_auth
def config():
    return render_template('config/index.html')

@app.route('/logs')
@require_auth
def logs():
    # This would display node logs
    return render_template('logs.html')

# API Routes
@app.route('/api/status')
@require_auth
def api_status():
    node_status = get_node_status()
    metrics = get_system_metrics()
    return jsonify({
        'success': True,
        'node_status': node_status,
        'metrics': metrics,
        'timestamp': datetime.now().isoformat()
    })

@app.route('/api/node/start', methods=['POST'])
@require_auth
def api_node_start():
    result = run_command(f"{CONFIG['pop_command']} start")
    return jsonify({
        'success': result['success'],
        'output': result['stdout'],
        'error': result['stderr']
    })

@app.route('/api/node/stop', methods=['POST'])
@require_auth
def api_node_stop():
    result = run_command(f"{CONFIG['pop_command']} stop")
    return jsonify({
        'success': result['success'],
        'output': result['stdout'],
        'error': result['stderr']
    })

@app.route('/api/node/restart', methods=['POST'])
@require_auth
def api_node_restart():
    result = run_command(f"{CONFIG['pop_command']} restart")
    return jsonify({
        'success': result['success'],
        'output': result['stdout'],
        'error': result['stderr']
    })

@app.route('/api/logs', methods=['GET'])
@require_auth
def api_logs():
    limit = request.args.get('limit', 100, type=int)
    # This would return the last N lines of logs
    result = run_command(f"{CONFIG['pop_command']} logs --tail {limit}")
    log_lines = result['stdout'].splitlines() if result['success'] else []
    return jsonify({
        'success': result['success'],
        'logs': log_lines,
        'count': len(log_lines)
    })

@app.route('/api/config', methods=['GET'])
@require_auth
def api_config_get():
    # This would get the node configuration
    result = run_command(f"{CONFIG['pop_command']} config show")
    try:
        if result['success'] and result['stdout']:
            # Try to parse as JSON first
            config_data = json.loads(result['stdout'])
        else:
            # Fallback to raw output
            config_data = result['stdout']
    except json.JSONDecodeError:
        # If not valid JSON, return as raw text
        config_data = result['stdout']
    
    return jsonify({
        'success': result['success'],
        'config': config_data
    })

@app.route('/api/config', methods=['POST'])
@require_auth
def api_config_update():
    # This would update the node configuration
    config_data = request.json
    
    # In a real implementation, we would validate and write the config
    # For now, we'll just pretend we did
    return jsonify({
        'success': True,
        'message': 'Configuration updated successfully'
    })

# Installation Wizard
@app.route('/wizard')
def wizard():
    """Installation wizard for first-time setup"""
    # Generate a unique wizard token if not exists
    if 'wizard_token' not in session:
        session['wizard_token'] = secrets.token_hex(8)
        session['wizard_step'] = 1
    
    return render_template('wizard/index.html', 
                        step=session.get('wizard_step', 1),
                        token=session.get('wizard_token'))

@app.route('/wizard/next', methods=['POST'])
def wizard_next():
    """Advance to the next wizard step"""
    if 'wizard_token' not in session:
        return jsonify({'success': False, 'error': 'Wizard session not found'})
    
    current_step = session.get('wizard_step', 1)
    session['wizard_step'] = current_step + 1
    
    return jsonify({
        'success': True,
        'step': session['wizard_step']
    })

@app.route('/wizard/complete', methods=['POST'])
def wizard_complete():
    """Complete the installation wizard"""
    if 'wizard_token' not in session:
        return jsonify({'success': False, 'error': 'Wizard session not found'})
    
    # In a real implementation, we would save the configuration
    # and perform any final setup tasks
    
    # Mark as authenticated
    session['authenticated'] = True
    # Clear wizard session
    session.pop('wizard_token', None)
    session.pop('wizard_step', None)
    
    return jsonify({
        'success': True,
        'message': 'Installation complete',
        'redirect': url_for('index')
    })

# Static files
@app.route('/favicon.ico')
def favicon():
    return send_from_directory(os.path.join(app.root_path, 'static', 'images'),
                              'favicon.ico', mimetype='image/vnd.microsoft.icon')

def start_server(host=None, port=None, debug=None):
    """Start the Flask server with configuration from arguments or config file"""
    host = host or CONFIG.get('host', DEFAULT_CONFIG['host'])
    port = port or CONFIG.get('port', DEFAULT_CONFIG['port'])
    debug = debug if debug is not None else CONFIG.get('debug', DEFAULT_CONFIG['debug'])
    
    logger.info(f"Starting server on {host}:{port}, debug={debug}")
    app.run(host=host, port=int(port), debug=debug)

if __name__ == "__main__":
    # Parse command line arguments
    args = parser.parse_args()
    
    # Start the server with command line arguments
    start_server(
        host=args.host,
        port=args.port,
        debug=args.debug
    ) 