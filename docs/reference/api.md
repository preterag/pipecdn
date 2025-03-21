# Pipe Network Web UI API Reference

This document provides a comprehensive reference for the Web UI API endpoints. These endpoints serve as the interface between the web frontend and the underlying Pipe Network node management system.

## API Overview

The Pipe Network Web UI API follows RESTful principles:

- Base URL: `http://localhost:8585/api`
- Authentication: Local token-based
- Response format: JSON
- Error handling: Standard error responses with codes and messages

## Authentication

The API uses a token-based authentication system for security:

```
Authorization: Bearer <token>
```

A token is automatically generated during installation and stored locally. For security reasons, by default, the API only accepts connections from localhost. If remote access is enabled, proper authentication is required.

## Core Endpoints

### System Status

#### Get System Status

```
GET /api/status
```

Returns the overall status of the system, including node state, version, and key metrics.

**Response:**

```json
{
  "status": "running",
  "version": "1.5.0",
  "uptime": "5d 12h 32m",
  "cpu_usage": 28.5,
  "memory_usage": 512,
  "disk_usage": 42.3,
  "network": {
    "incoming": 1250,
    "outgoing": 845
  }
}
```

### Node Management

#### Start Node

```
POST /api/node/start
```

Starts the Pipe Network node.

**Response:**

```json
{
  "success": true,
  "message": "Node started successfully",
  "pid": 12345
}
```

#### Stop Node

```
POST /api/node/stop
```

Stops the Pipe Network node.

**Response:**

```json
{
  "success": true,
  "message": "Node stopped successfully"
}
```

#### Restart Node

```
POST /api/node/restart
```

Restarts the Pipe Network node.

**Response:**

```json
{
  "success": true,
  "message": "Node restarted successfully",
  "pid": 12346
}
```

### Configuration

#### Get Configuration

```
GET /api/config
```

Retrieves the current node configuration.

**Response:**

```json
{
  "node": {
    "name": "primary-node",
    "auto_start": true,
    "log_level": "info"
  },
  "network": {
    "port": 8080,
    "max_connections": 50,
    "timeout": 30
  },
  "wallet": {
    "address": "0x1234567890abcdef",
    "rewards_enabled": true
  }
}
```

#### Update Configuration

```
POST /api/config
```

Updates the node configuration.

**Request Body:**

```json
{
  "node": {
    "name": "updated-node-name",
    "log_level": "debug"
  }
}
```

**Response:**

```json
{
  "success": true,
  "message": "Configuration updated successfully",
  "restart_required": false
}
```

### Logs

#### Get Logs

```
GET /api/logs
```

Retrieves system logs.

**Query Parameters:**

- `limit` (optional): Number of log entries to retrieve (default: 100)
- `level` (optional): Minimum log level (default: "info")
- `start` (optional): Start timestamp
- `end` (optional): End timestamp

**Response:**

```json
{
  "logs": [
    {
      "timestamp": "2025-03-22T12:34:56.789Z",
      "level": "info",
      "message": "Node started successfully"
    },
    {
      "timestamp": "2025-03-22T12:34:55.432Z",
      "level": "debug",
      "message": "Configuration loaded from file"
    }
  ],
  "total": 2
}
```

### Metrics

#### Get Current Metrics

```
GET /api/metrics
```

Retrieves current performance metrics.

**Response:**

```json
{
  "timestamp": "2025-03-22T12:34:56.789Z",
  "cpu": {
    "usage": 28.5,
    "cores": 4,
    "load": [0.52, 0.48, 0.45]
  },
  "memory": {
    "total": 8192,
    "used": 3254,
    "free": 4938,
    "usage": 39.7
  },
  "disk": {
    "total": 256000,
    "used": 98560,
    "free": 157440,
    "usage": 38.5
  },
  "network": {
    "incoming_bandwidth": 1250,
    "outgoing_bandwidth": 845,
    "active_connections": 12
  }
}
```

#### Get Historical Metrics

```
GET /api/metrics/history
```

Retrieves historical performance metrics.

**Query Parameters:**

- `period` (optional): Time period (default: "1h", options: "1h", "6h", "24h", "7d", "30d")
- `resolution` (optional): Data point resolution (default: "auto")

**Response:**

```json
{
  "period": "1h",
  "resolution": "1m",
  "data_points": 60,
  "metrics": {
    "cpu": [28.5, 30.2, 27.8, /* ... */],
    "memory": [39.7, 40.1, 38.9, /* ... */],
    "disk": [38.5, 38.5, 38.6, /* ... */],
    "network_in": [1250, 1280, 1240, /* ... */],
    "network_out": [845, 860, 830, /* ... */]
  },
  "timestamps": [
    "2025-03-22T11:35:00.000Z",
    "2025-03-22T11:36:00.000Z",
    /* ... */
  ]
}
```

### Fleet Management

#### List Nodes

```
GET /api/fleet/nodes
```

Lists all nodes in the fleet.

**Response:**

```json
{
  "total": 3,
  "nodes": [
    {
      "id": "node1",
      "name": "Primary Node",
      "ip": "192.168.1.100",
      "status": "running",
      "group": "production",
      "last_seen": "2025-03-22T12:30:00.000Z"
    },
    {
      "id": "node2",
      "name": "Backup Node",
      "ip": "192.168.1.101",
      "status": "running",
      "group": "production",
      "last_seen": "2025-03-22T12:29:00.000Z"
    },
    {
      "id": "node3",
      "name": "Test Node",
      "ip": "192.168.1.102",
      "status": "stopped",
      "group": "testing",
      "last_seen": "2025-03-22T10:15:00.000Z"
    }
  ]
}
```

#### Register Node

```
POST /api/fleet/register
```

Registers a new node in the fleet.

**Request Body:**

```json
{
  "name": "New Node",
  "ip": "192.168.1.103",
  "ssh_key": "path/to/ssh/key",
  "group": "production"
}
```

**Response:**

```json
{
  "success": true,
  "message": "Node registered successfully",
  "node_id": "node4"
}
```

#### Execute Command

```
POST /api/fleet/command
```

Executes a command on one or more fleet nodes.

**Request Body:**

```json
{
  "nodes": ["node1", "node2"],
  "command": "restart",
  "params": {}
}
```

**Response:**

```json
{
  "success": true,
  "results": {
    "node1": {
      "success": true,
      "message": "Command executed successfully"
    },
    "node2": {
      "success": true,
      "message": "Command executed successfully"
    }
  }
}
```

#### List Groups

```
GET /api/fleet/groups
```

Lists all node groups in the fleet.

**Response:**

```json
{
  "total": 2,
  "groups": [
    {
      "name": "production",
      "node_count": 2,
      "description": "Production nodes"
    },
    {
      "name": "testing",
      "node_count": 1,
      "description": "Test environment nodes"
    }
  ]
}
```

### Backup & Restore

#### Create Backup

```
POST /api/backup
```

Creates a backup of the node data.

**Request Body:**

```json
{
  "description": "Pre-update backup",
  "include_logs": true
}
```

**Response:**

```json
{
  "success": true,
  "message": "Backup created successfully",
  "backup_id": "backup_20250322_123456",
  "size": 15240,
  "location": "/var/lib/pipe-network/backups/backup_20250322_123456.tar.gz"
}
```

#### List Backups

```
GET /api/backups
```

Lists all available backups.

**Response:**

```json
{
  "total": 2,
  "backups": [
    {
      "id": "backup_20250322_123456",
      "description": "Pre-update backup",
      "created": "2025-03-22T12:34:56.000Z",
      "size": 15240,
      "location": "/var/lib/pipe-network/backups/backup_20250322_123456.tar.gz"
    },
    {
      "id": "backup_20250320_093045",
      "description": "Weekly backup",
      "created": "2025-03-20T09:30:45.000Z",
      "size": 14980,
      "location": "/var/lib/pipe-network/backups/backup_20250320_093045.tar.gz"
    }
  ]
}
```

#### Restore Backup

```
POST /api/restore
```

Restores from a backup.

**Request Body:**

```json
{
  "backup_id": "backup_20250322_123456"
}
```

**Response:**

```json
{
  "success": true,
  "message": "Backup restored successfully",
  "restart_required": true
}
```

### Community

#### Get Leaderboard

```
GET /api/community/leaderboard
```

Retrieves the network leaderboard.

**Query Parameters:**

- `period` (optional): Time period (default: "weekly", options: "daily", "weekly", "monthly", "all")
- `limit` (optional): Number of entries (default: 10, max: 100)

**Response:**

```json
{
  "period": "weekly",
  "user_rank": 15,
  "total_participants": 250,
  "leaderboard": [
    {
      "rank": 1,
      "name": "top-node-operator",
      "score": 98750,
      "uptime": 99.98,
      "nodes": 5
    },
    {
      "rank": 2,
      "name": "super-node-1",
      "score": 95420,
      "uptime": 99.95,
      "nodes": 3
    },
    /* ... */
  ]
}
```

#### Get Referrals

```
GET /api/community/referrals
```

Retrieves referral information.

**Response:**

```json
{
  "referral_code": "ABC123XYZ",
  "total_referrals": 5,
  "active_referrals": 3,
  "referral_rewards": 500,
  "referrals": [
    {
      "node_id": "referred-node-1",
      "joined": "2025-02-15T10:20:30.000Z",
      "status": "active",
      "rewards_generated": 200
    },
    /* ... */
  ]
}
```

### UI Server

#### Get UI Server Status

```
GET /api/ui/status
```

Retrieves the status of the UI server.

**Response:**

```json
{
  "status": "running",
  "version": "1.0.0",
  "uptime": "2d 5h 12m",
  "port": 8585,
  "remote_access": false,
  "connections": 1
}
```

#### Configure UI Server

```
POST /api/ui/config
```

Updates the UI server configuration.

**Request Body:**

```json
{
  "port": 8080,
  "remote_access": true,
  "auto_start": true
}
```

**Response:**

```json
{
  "success": true,
  "message": "UI configuration updated successfully",
  "restart_required": true
}
```

## Error Handling

All API endpoints return standard error responses in case of failure:

```json
{
  "success": false,
  "error": {
    "code": "CONFIG_VALIDATION_ERROR",
    "message": "Invalid configuration: port must be between 1024 and 65535",
    "details": {
      "field": "network.port",
      "constraint": "1024-65535",
      "value": 80
    }
  }
}
```

Common error codes:

- `UNAUTHORIZED`: Authentication required or invalid
- `FORBIDDEN`: Action not permitted
- `NOT_FOUND`: Resource not found
- `VALIDATION_ERROR`: Invalid input
- `NODE_ERROR`: Error in node operation
- `INTERNAL_ERROR`: Server-side error

## Websocket API

For real-time updates, connect to the WebSocket endpoint:

```
ws://localhost:8585/ws
```

### Available Channels

After connecting, subscribe to specific channels:

```json
{
  "action": "subscribe",
  "channels": ["metrics", "logs", "status"]
}
```

### Message Format

Messages received on the WebSocket follow this format:

```json
{
  "channel": "metrics",
  "timestamp": "2025-03-22T12:34:56.789Z",
  "data": {
    // Channel-specific data structure
  }
}
```

## Rate Limiting

To prevent abuse, the API implements rate limiting:

- 60 requests per minute for most endpoints
- 10 requests per minute for resource-intensive operations
- 5 requests per minute for fleet operations

When a rate limit is exceeded, the API returns:

```json
{
  "success": false,
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Rate limit exceeded. Try again in 30 seconds.",
    "retry_after": 30
  }
}
```

## Development and Testing

For development and testing purposes, you can use the sandbox environment:

```
GET /api/sandbox/...
```

The sandbox provides test data and doesn't affect the actual node operation. 