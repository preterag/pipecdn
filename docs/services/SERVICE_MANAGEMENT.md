# 🔄 Service Management

This document describes the service management scripts and configuration for the Pipe Network PoP Node.

## Service Scripts

### start_pipe_pop.sh

The `start_pipe_pop.sh` script starts the pipe-pop service.

**Features:**
- Initializes the environment
- Starts the pipe-pop node
- Handles logging and error reporting

**Usage:**
```bash
./start_pipe_pop.sh
```

### update_service.sh

The `update_service.sh` script updates the pipe-pop service configuration.

**Features:**
- Updates the systemd service file
- Reloads the systemd daemon
- Restarts the service if it was running

**Usage:**
```bash
sudo ./update_service.sh
```

## Service Configuration

The pipe-pop service is managed by systemd. The service file is located at `/etc/systemd/system/pipe-pop.service`.

### Service File Content

```ini
[Unit]
Description=Pipe Network PoP Node
After=network.target

[Service]
User=root
WorkingDirectory=/opt/pipe-pop
ExecStart=/opt/pipe-pop/start_pipe_pop.sh
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

### Managing the Service

To manage the pipe-pop service:

```bash
# Start the service
sudo systemctl start pipe-pop.service

# Stop the service
sudo systemctl stop pipe-pop.service

# Restart the service
sudo systemctl restart pipe-pop.service

# Check status
sudo systemctl status pipe-pop.service

# Enable at boot
sudo systemctl enable pipe-pop.service

# Disable at boot
sudo systemctl disable pipe-pop.service

# View logs
sudo journalctl -u pipe-pop.service -f
```

## Troubleshooting

If you encounter issues with the service:

1. **Service Won't Start**: Check the logs with `sudo journalctl -u pipe-pop.service -f`
2. **Permission Issues**: Make sure the service is running as the correct user
3. **Path Issues**: Verify that the WorkingDirectory and ExecStart paths are correct
4. **Dependency Issues**: Ensure all required dependencies are installed

## Updating the Service

If you need to update the service configuration:

1. Edit the service file:
   ```bash
   sudo nano /etc/systemd/system/pipe-pop.service
   ```

2. Reload the systemd daemon:
   ```bash
   sudo systemctl daemon-reload
   ```

3. Restart the service:
   ```bash
   sudo systemctl restart pipe-pop.service
   ```

Alternatively, you can use the `update_service.sh` script to automate this process. 