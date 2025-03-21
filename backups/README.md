# Backups Directory

This directory contains backup files of your Pipe Network node configuration.

## Creating Backups

To create a backup:

```bash
pop backup
```

## Restoring Backups

Backups are stored as timestamped tar archives. To restore:

```bash
sudo tar -xzf backup-TIMESTAMP.tar.gz -C /opt/pipe-pop
```
