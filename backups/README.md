# Backups Directory

This directory stores automated backups of your Pipe Network node configuration and essential data.

**Note**: Actual backup files are excluded from Git and should not be committed to the repository.

## Backup Contents

Automatic backups typically include:

- Node identity information (`node_info.json`)
- Configuration files
- Critical operational data

Backups do not include:
- Large cache files
- Log files (unless specifically configured)
- Temporary operational data

## Backup Schedule

By default, backups run daily and are kept for 7 days. You can configure the backup schedule in your configuration file:

```json
{
  "backup": {
    "enabled": true,
    "schedule": "daily",
    "retention_days": 7,
    "include_logs": true
  }
}
```

## Restoring From Backup

To restore from a backup:

```bash
pop backup restore <backup-file-name>
```

Or manually:

1. Stop the node service: `sudo systemctl stop pipe-pop`
2. Extract the backup: `tar -xzf backup_file.tar.gz -C /tmp/restore`
3. Copy files to appropriate locations
4. Restart the service: `sudo systemctl start pipe-pop`

## Manual Backups

You can trigger a manual backup with:

```bash
pop backup create
```
