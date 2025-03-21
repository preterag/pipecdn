# Port Forwarding Troubleshooting Checklist

After testing, you've confirmed the service is running and accessible locally, but external access isn't working. Let's go through common issues:

## 1. Double NAT

This is one of the most common issues that prevents port forwarding from working properly.

- **Check if you have two routers in your setup**. This is common when:
  - Your ISP provides a router/modem, AND you have your own router
  - You're using multiple network devices (router behind another router)

- **Solution**: 
  - Set one router to bridge mode
  - Configure port forwarding on all routers in the chain
  - If possible, connect your device directly to the main router

## 2. Dynamic IP Address

- Your ISP might have changed your public IP address since you set up port forwarding
- **Solution**: 
  - Verify your current public IP address matches what's in your port forwarding rules
  - Consider setting up Dynamic DNS (DDNS) to handle IP changes automatically

## 3. ISP Blocking

- Many residential ISP plans block incoming connections on certain ports
- **Solution**: 
  - Contact your ISP and ask if they block incoming connections on port 8003
  - Ask if they use CGNAT (Carrier-Grade NAT), which prevents port forwarding
  - Consider upgrading to a business plan which typically allows incoming connections

## 4. Incorrect Port Forward Configuration

- **Double-check your router's port forwarding settings**:
  - External port: 8003
  - Internal IP: 192.168.1.149
  - Internal port: 8003
  - Protocol: TCP or TCP/UDP

- Ensure you're editing the correct router (the one directly connected to the internet)

## 5. Router Restart Required

- Some routers need a full restart for port forwarding settings to take effect
- **Solution**: Power cycle your router (unplug for 30 seconds, then plug back in)

## 6. Firewall Issues

- **Check local firewall**:
  ```
  sudo ufw status
  ```
  If active, allow the port:
  ```
  sudo ufw allow 8003/tcp
  ```

- **Check router firewall**: Some routers have separate firewall settings from port forwarding

## 7. Symmetric NAT / CGNAT

- Some ISPs use Carrier-Grade NAT (CGNAT) or symmetric NAT which makes port forwarding impossible
- **Solution**: 
  - Contact your ISP to verify if you're behind CGNAT
  - Ask to be assigned a public IP address (may require a business plan)
  - As a workaround, consider using a VPN service that supports port forwarding

## 8. Verify Actual External Access

The most reliable way to test if your port is accessible from the internet:

1. Use a computer outside your network (like a mobile data connection)
2. Try to connect to your public IP on port 8003:
   ```
   curl http://YOUR_PUBLIC_IP:8003
   ```
   
3. Or use an online tool while connected to a different network:
   - https://www.yougetsignal.com/tools/open-ports/
   - https://portchecker.co/
   - https://canyouseeme.org/

## Next Steps

If you've tried everything and still can't get port forwarding to work:

1. Try using a different port (like 9000 instead of 8003)
2. Contact your ISP support and specifically ask about port forwarding capabilities
3. Consider a VPN service with port forwarding as a workaround 