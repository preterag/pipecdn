# Router Port Forwarding Guide for Pipe Network

## Introduction

For your Pipe Network node to be accessible from the internet, you need to set up port forwarding on your router. This guide will walk you through the process for most common routers.

## Required Information

From your error message, we can see the following details:
- **Internal IP Address**: 192.168.1.149
- **Port to Forward**: 8003
- **Protocol**: TCP

## Step-by-Step Instructions

### 1. Access Your Router's Admin Panel

1. Open a web browser
2. Enter your router's IP address in the address bar
   - Common router addresses: `192.168.0.1`, `192.168.1.1`, or `10.0.0.1`
   - If you're unsure, you can find it by running `ip route | grep default` in your terminal
3. Login with your admin credentials
   - If you haven't changed them, check for default credentials on the router label

### 2. Find the Port Forwarding Section

Different routers have different names for this section:
- "Port Forwarding"
- "Virtual Server"
- "Port Mapping"
- "Applications & Gaming"
- "NAT/QoS" or "NAT Forwarding"

It's usually under "Advanced Settings" or "Advanced Setup".

### 3. Create New Port Forwarding Rule

Add a new rule with these settings:
- **Service Name/Description**: PipeNetwork
- **External/WAN Port**: 8003
- **Internal/LAN IP Address**: 192.168.1.149 (your node's IP)
- **Internal/LAN Port**: 8003
- **Protocol**: TCP (or TCP/UDP if you want to support both)
- **Enable/Status**: Enabled/On

### 4. Optional: Set Up Port 80 and 443 Forwarding

If you want to use standard web ports (for better connectivity):
- Create additional rules for ports 80 and 443
- Forward both to your internal IP (192.168.1.149) and port 8003

### 5. Save and Apply Changes

- Click "Save", "Apply", or "OK" to apply the settings
- Your router may need to restart to apply the changes

### 6. Verify Port Forwarding

To check if the port forwarding is working:
1. Visit [https://www.canyouseeme.org/](https://www.canyouseeme.org/)
2. Enter port 8003
3. Click "Check"
4. If successful, you should see "Success: I can see your service on X.X.X.X on port 8003"

## Common Router-Specific Instructions

### Linksys
- Go to "Applications & Gaming" > "Port Range Forward"
- Add your entry and click "Save Settings"

### Netgear
- Go to "Advanced" > "Advanced Setup" > "Port Forwarding / Port Triggering"
- Select "Port Forwarding"
- Add your service and click "Apply"

### TP-Link
- Go to "Forwarding" > "Virtual Servers"
- Add a new rule and click "Save"

### Asus
- Go to "WAN" > "Virtual Server / Port Forwarding"
- Add your service and click "Apply"

## Troubleshooting

If port forwarding isn't working:

1. **Check Your Local Firewall**
   ```
   sudo ufw status
   ```
   If active, allow the port:
   ```
   sudo ufw allow 8003/tcp
   ```

2. **Verify Your Internal IP**
   Your IP might have changed if your DHCP lease renewed. Consider setting a static IP.

3. **Router Reboot**
   Some routers require a complete reboot for port forwarding changes to take effect.

4. **ISP Blocking**
   Some ISPs block certain ports. Contact your ISP if you suspect this is the case.

## Next Steps

After setting up port forwarding, restart your Pipe Network node to ensure it establishes all necessary connections:

```
sudo systemctl restart pipe-pop.service
```

Check the status to ensure it's working correctly:

```
sudo systemctl status pipe-pop.service
``` 