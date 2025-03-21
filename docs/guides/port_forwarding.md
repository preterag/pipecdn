# Port Forwarding Guide for Pipe Network Nodes

For your Pipe Network node to achieve maximum performance and earn the highest rewards, it needs to have ports properly forwarded through your router.

## Required Ports

Your Pipe Network node requires these ports to be forwarded:

- **Port 80** (HTTP): Essential for web traffic
- **Port 443** (HTTPS): Essential for secure web traffic
- **Port 8003**: Used for node communication

## Step-by-Step Port Forwarding Setup

1. **Access your router's admin panel**
   - Open a web browser and enter your router's IP address (typically `192.168.1.1` or `192.168.0.1`)
   - Log in with your router credentials

2. **Find the port forwarding section**
   - Look for "Port Forwarding", "Virtual Server", or "NAT" in your router settings
   - Each router manufacturer uses different terminology

3. **Add port forwarding rules**
   - For each required port (80, 443, 8003):
     - Set the external port to match the internal port
     - Set the protocol to TCP (or TCP/UDP if that's the only option)
     - Point to your Pipe Network node's internal IP address

4. **Save settings and restart your router**
   - Apply the changes
   - Consider restarting your router to ensure settings take effect

## Verifying Your Port Forwarding

Run the provided port check script:

```bash
./port_check.sh
```

This will verify if your ports are correctly forwarded.

## Troubleshooting

### ISP Restrictions
Some Internet Service Providers (ISPs) block ports 80 and 443 on residential connections. If you can't get these ports working after proper configuration, contact your ISP to verify if they're blocked.

### Dynamic IP
If you have a dynamic public IP address, consider setting up a DDNS (Dynamic DNS) service to maintain consistent access to your node.

### Router Firewall
Ensure your router's firewall isn't blocking these ports. Some routers have separate firewall settings from port forwarding.

## Using the Provided Scripts

We provide several helper scripts to assist with port configuration:

- `port_check.sh`: Checks if ports are properly configured
- `enable_ports.sh`: Attempts to automatically configure port capabilities

If you need additional assistance, refer to your router's manual or check the [troubleshooting guide](../reference/troubleshooting.md). 