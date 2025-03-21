# Security Guide

Keeping your Pipe Network node secure is essential.

## Quick Security Check

Run a basic security scan:

```bash
pop security check
```

## Essential Security Practices

1. **Secure Your Wallet**
   - Never share your private key
   - Use only your public address with the node

2. **Configure Firewall**
   - Only open required ports (80, 443, 8003)
   - Block unnecessary access

3. **Keep Software Updated**
   - Update regularly:
     ```bash
     pop update
     ```

4. **Secure Config Files**
   - Set proper permissions:
     ```bash
     sudo chmod 600 /opt/pipe-pop/config/config.json
     ```

5. **Regular Backups**
   - Create backups:
     ```bash
     pop backup
     ```

## Monitoring for Issues

Check logs for unauthorized access:

```bash
pop monitoring logs | grep ERROR
```

## Full Security Audit

Run a comprehensive security audit:

```bash
pop security audit
```

## Recovery

If you suspect your node has been compromised:

1. Stop the service:
   ```bash
   sudo systemctl stop pipe-pop
   ```

2. Run security audit:
   ```bash
   pop security audit
   ```

3. Reinstall if necessary:
   ```bash
   sudo ./INSTALL
   ``` 