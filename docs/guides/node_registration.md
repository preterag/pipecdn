# Node Registration Guide

Proper registration is essential for your Pipe Network node to earn rewards and participate in the network.

## Understanding Node Registration

When you set up your Pipe Network node, it generates a unique node ID and registers with the Pipe Network servers. This registration:

1. Associates your node with your wallet
2. Enables your node to participate in network activities
3. Allows you to earn rewards

## Checking Registration Status

To check if your node is properly registered:

```bash
pop status
```

Look for the `Registration Status` field. It should show `Registered`.

## Registration Issues

If your node shows as `Not Registered`, you can use the provided registration script:

```bash
./register_node.sh
```

This script will:
1. Stop the running node service
2. Back up your existing node information
3. Delete the existing node ID
4. Generate a new node ID
5. Register the node with the Pipe Network
6. Restart the service

## Multiple Instances Issue

Sometimes you might encounter an issue where you have multiple `node_info.json` files in different locations. This can cause confusion as only one can be properly registered.

To fix this, use:

```bash
./fix_node_registration.sh
```

This script ensures that all instances of `node_info.json` are identical and properly registered.

## Manual Registration

If you prefer to manually register your node:

1. Stop the service:
   ```bash
   sudo systemctl stop pipe-pop
   ```

2. Remove existing node information:
   ```bash
   rm -f /opt/pipe-pop/node_info.json
   rm -f ~/node_info.json
   ```

3. Start the service in registration mode:
   ```bash
   cd /opt/pipe-pop
   sudo ./bin/pipe-pop --register
   ```

4. Follow the on-screen prompts

## Troubleshooting

### Node Shows 0 Score After Registration

It may take 24-48 hours for your node to fully integrate with the network and start showing a non-zero score. Be patient!

### Registration Fails

If registration fails, check your internet connection and ensure your system time is accurate.

For more detailed troubleshooting, see the [troubleshooting guide](../reference/troubleshooting.md). 