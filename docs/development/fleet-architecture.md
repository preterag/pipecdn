# Pipe Network Fleet Management Architecture

> **IMPORTANT**: This is a community-created enhancement for Pipe Network.
> It is not part of the official Pipe Network project.

This document provides a detailed architecture overview of the Pipe Network Fleet Management System, explaining its components, design decisions, and implementation details.

## Architecture Overview

The Fleet Management System uses an SSH-based polling architecture to securely manage and monitor multiple Pipe Network nodes from a central location. This design prioritizes security, low overhead, and compatibility with existing Pipe Network node deployments.

### System Components

```
                         ┌─────────────────────┐
                         │                     │
                         │  Central Management │
                         │       Server        │
                         │                     │
                         └─────────────────────┘
                                   │
                                   │ SSH
                                   ▼
      ┌──────────────┐      ┌──────────────┐      ┌──────────────┐
      │              │      │              │      │              │
      │   Node 1     │      │   Node 2     │      │   Node 3     │
      │              │      │              │      │              │
      └──────────────┘      └──────────────┘      └──────────────┘
```

## Core Components

### 1. Secure Connection Layer

The connection layer manages SSH connections to nodes, using restricted SSH keys to ensure secure communications with minimal privileges.

**Key Features:**
- SSH key generation with command restrictions
- Connection pooling for efficiency
- Failure handling and automatic retries
- Connection health monitoring

**Security Measures:**
- Uses SSH keys with restricted command execution
- No port forwarding, X11 forwarding, or agent forwarding allowed
- No PTY allocation, minimizing attack surface
- Command restrictions limit potential exploitation

**Implementation:**
- Located in `src/fleet/core/ssh.sh`
- Functions for key generation, connection testing, and command execution
- Uses standard SSH tooling available on most systems

### 2. Node Registration System

The registration system manages the inventory of nodes, storing connection details and metadata for each node in the fleet.

**Key Features:**
- Node addition, removal, and update capabilities
- Metadata storage for node details
- Status tracking
- Location and description management

**Data Structure:**
```json
{
  "nodes": [
    {
      "name": "node-1",
      "ip": "192.168.1.100",
      "username": "ubuntu",
      "port": "22",
      "location": "Data Center 1",
      "description": "Primary edge node",
      "status": "Connected",
      "registered": "2025-03-21 14:30:45",
      "last_seen": "2025-03-21 14:35:22",
      "metrics": { ... }
    },
    ...
  ]
}
```

**Implementation:**
- Located in `src/fleet/core/registration.sh`
- Uses JSON for data storage
- Includes functions for managing the node database

### 3. Metrics Collection System

The metrics collection system gathers performance and status information from all nodes in the fleet, on demand or on a schedule.

**Key Features:**
- Individual and fleet-wide metrics collection
- Scheduled collection with configurable intervals
- Historical metrics storage
- Fleet-wide summary generation

**Metrics Collected:**
- Node status (running/stopped)
- Performance metrics (reputation, points, egress)
- Resource usage (CPU, memory, disk)
- Rank and other Pipe Network metrics

**Implementation:**
- Located in `src/fleet/monitoring/collector.sh`
- Uses restricted SSH for secure data collection
- Creates time-series data for trending
- Aggregates data for fleet-wide insights

### 4. Command Execution Framework

The command execution framework allows running commands on single nodes or across the entire fleet.

**Key Features:**
- Single-node command execution
- Batch operations across multiple nodes
- Output collection and parsing
- Error handling and reporting

**Security Considerations:**
- Commands are executed through restricted SSH
- Only pre-approved commands can be executed
- All command executions are logged

**Implementation:**
- Functions for executing commands on single or multiple nodes
- Output formatting and error handling
- Integration with the SSH layer

## Data Flow

1. **Registration Flow**:
   ```
   User → Register Command → Registration System → Node Database
   ```

2. **Metrics Collection Flow**:
   ```
   Scheduler → Collection System → SSH Layer → Nodes → Metrics Data → Database → Dashboard
   ```

3. **Command Execution Flow**:
   ```
   User → Command Request → Command Framework → SSH Layer → Nodes → Results → User
   ```

## Design Decisions

### Why SSH-Based Polling?

We chose an SSH-based polling architecture for several reasons:

1. **Security**: SSH is a well-established, secure protocol
2. **Simplicity**: No additional services needed on nodes
3. **Compatibility**: Works with existing node deployments
4. **Control**: Central management server initiates all connections
5. **Restricted Access**: Command restrictions limit potential vulnerabilities

### Why JSON for Data Storage?

JSON was selected for data storage because:

1. **Human-readable**: Easy to debug and understand
2. **Native bash integration**: Works well with jq for processing
3. **No dependencies**: No database server required
4. **Flexibility**: Schema can evolve as needed
5. **Portability**: Easy to back up and restore

### Performance Considerations

The system is designed to be lightweight, with several optimizations:

1. **Connection pooling**: Reuses SSH connections where possible
2. **Batched commands**: Executes multiple operations in a single connection
3. **Selective polling**: Collects only necessary data
4. **Configurable intervals**: Adjustable polling frequency based on needs
5. **Failure handling**: Graceful degradation when nodes are unreachable

## Security Architecture

Security is a primary concern in the Fleet Management System:

### 1. SSH Key Restrictions

The system uses SSH keys with command restrictions that:
- Limit the commands that can be executed
- Prevent port forwarding, X11 forwarding, and agent forwarding
- Disable PTY allocation
- Allow only specific status and metrics commands

Example restricted key format:
```
command="./tools/pop --status; ./tools/pop --pulse --export json",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-rsa AAAA...
```

### 2. Least Privilege Principle

- Each node has restricted access
- The fleet management system only has the permissions it needs
- Command execution is limited to pre-approved operations

### 3. Data Protection

- Sensitive data is stored with appropriate permissions
- SSH keys have 600 permissions
- Configuration directories have 700 permissions
- Passwords are never stored in plaintext

## Scalability

The system is designed to scale to hundreds of nodes:

1. **Parallel operations**: Commands can be executed in parallel across nodes
2. **Configurable polling**: Adjust polling frequency based on fleet size
3. **Selective metrics**: Collect only needed metrics for efficiency
4. **Hierarchical structure**: Can be extended to support regional controllers
5. **Lightweight design**: Minimal resource usage on central server

## Extension Points

The architecture includes several extension points:

1. **Custom Commands**: Add new commands to the execution framework
2. **Additional Metrics**: Extend the metrics collection
3. **Alternative Storage**: Plug in different storage backends
4. **Web Interface**: Add a web frontend for the dashboard
5. **API Layer**: Create an API for third-party integration

## Implementation Roadmap

The implementation follows a phased approach:

### Phase 1: Core Infrastructure
- SSH key management
- Node registration
- Basic database schema

### Phase 2: Monitoring Enhancement
- Metrics collection
- Dashboard visualization
- Alerting system

### Phase 3: Command Framework
- Command execution system
- Batch operations
- Scheduled tasks

### Phase 4: Advanced Features
- Configuration management
- Update deployment
- Performance optimization

## Conclusion

The Fleet Management System provides a secure, efficient way to manage multiple Pipe Network nodes from a central location. Its architecture prioritizes security, compatibility, and ease of use, making it suitable for small to large deployments.

The SSH-based polling design ensures that:
1. No additional services need to be exposed on nodes
2. Communications are secure and encrypted
3. The system works with existing node deployments
4. Control remains with the central management server
5. The attack surface is minimized through command restrictions

Future enhancements will focus on expanding the dashboard visualization, adding more automated management features, and providing deeper integration with the Pipe Network ecosystem. 