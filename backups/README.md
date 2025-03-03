# Pipe PoP Backups Directory

This directory contains backups of essential Pipe PoP node data.

## Contents

- Compressed backup archives (`.tar.gz` files) created by the backup script
- Each backup is named with a timestamp: `backup_YYYYMMDD_HHMMSS.tar.gz`

## Backup Contents

Each backup archive contains:

- `node_info.json`: Essential node information including the node ID
- `solana_id.json`: Backup of the Solana wallet (if available)
- Configuration files from the `config/` directory

## Creating Backups

Backups can be created manually using the backup script:

```bash
../backup.sh
```

Or automatically using the scheduled backup script:

```bash
sudo ../setup_backup_schedule.sh weekly
```

## Restoring from Backup

To restore from a backup:

1. Extract the backup archive:
   ```bash
   tar -xzf backup_YYYYMMDD_HHMMSS.tar.gz
   ```

2. Copy the files to their original locations:
   ```bash
   cp backup_YYYYMMDD_HHMMSS/node_info.json ../cache/
   cp backup_YYYYMMDD_HHMMSS/config/* ../config/
   ```

3. If needed, restore the Solana wallet:
   ```bash
   cp backup_YYYYMMDD_HHMMSS/solana_id.json ~/.config/solana/id.json
   ```

## Important Notes

- Regular backups are essential for node recovery
- Keep multiple backups in case one becomes corrupted
- Consider storing backups in multiple locations
- The most critical file is `node_info.json` as it contains your unique node ID 