# Pipe PoP Node Systemd Service

This document provides instructions for managing the Pipe PoP node as a systemd service.

## Prerequisites

- The Pipe PoP node must be installed and configured
- You must have sudo privileges to manage systemd services

## Installation

You can install the service using the provided `install_service.sh` script:

```bash
sudo ./install_service.sh all
```

This will:
1. Install the service
2. Enable it to start on boot
3. Start the service
4. Show the service status

## Manual Installation

If you prefer to install the service manually, follow these steps:

1. Copy the service file to the systemd directory:
   ```bash
   sudo cp pipe-pop.service /etc/systemd/system/
   ```

2. Reload the systemd daemon:
   ```bash
   sudo systemctl daemon-reload
   ```

3. Enable the service to start on boot:
   ```bash
   sudo systemctl enable pipe-pop.service
   ```

4. Start the service:
   ```bash
   sudo systemctl start pipe-pop.service
   ```

5. Check the service status:
   ```bash
   sudo systemctl status pipe-pop.service
   ```

## Service Management

### Using the Management Script

The `install_service.sh` script provides several commands for managing the service:

- **Install the service**:
  ```bash
  sudo ./install_service.sh install
  ```

- **Enable the service**:
  ```bash
  sudo ./install_service.sh enable
  ```

- **Start the service**:
  ```bash
  sudo ./install_service.sh start
  ```

- **Check the service status**:
  ```bash
  sudo ./install_service.sh status
  ```

- **Stop the service**:
  ```bash
  sudo ./install_service.sh stop
  ```

- **Disable the service**:
  ```bash
  sudo ./install_service.sh disable
  ```

- **Uninstall the service**:
  ```bash
  sudo ./install_service.sh uninstall
  ```

### Using systemctl Directly

You can also manage the service using systemctl directly:

- **Start the service**:
  ```bash
  sudo systemctl start pipe-pop.service
  ```

- **Stop the service**:
  ```bash
  sudo systemctl stop pipe-pop.service
  ```

- **Restart the service**:
  ```bash
  sudo systemctl restart pipe-pop.service
  ```

- **Check the service status**:
  ```bash
  sudo systemctl status pipe-pop.service
  ```

- **Enable the service to start on boot**:
  ```bash
  sudo systemctl enable pipe-pop.service
  ```

- **Disable the service from starting on boot**:
  ```bash
  sudo systemctl disable pipe-pop.service
  ```

## Viewing Logs

You can view the service logs using journalctl:

```bash
sudo journalctl -u pipe-pop.service
```

To follow the logs in real-time:

```bash
sudo journalctl -u pipe-pop.service -f
```

## Troubleshooting

If the service fails to start, check the following:

1. Verify that the Pipe PoP binary exists and is executable:
   ```bash
   ls -l /home/karo/Workspace/PipeNetwork/bin/pipe-pop
   ```

2. Check the service logs for errors:
   ```bash
   sudo journalctl -u pipe-pop.service -n 50
   ```

3. Verify that the cache directory exists and is writable:
   ```bash
   ls -ld /home/karo/Workspace/PipeNetwork/cache
   ```

4. Check if the required ports (80, 443, 8003) are available:
   ```bash
   sudo netstat -tulpn | grep -E ':(80|443|8003)'
   ```

5. Verify that the Solana wallet is properly set up:
   ```bash
   ls -l $HOME/.config/solana/id.json
   ``` 