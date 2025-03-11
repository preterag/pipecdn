# Pipe Network: Decentralized Content Delivery Network
## Technical Documentation and API Reference

## Table of Contents
- [Welcome](#welcome)
- [Introduction](#introduction)
- [Architecture](#architecture)
- [Key Features](#key-features)
- [Scalability and Network Growth](#scalability-and-network-growth)
- [Opportunities and Use Cases](#opportunities-and-use-cases)
- [Operating a DevNet CDN PoP Node](#operating-a-devnet-cdn-pop-node)
- [CDN API Reference](#cdn-api-reference)

## Welcome

Welcome to Pipe Network: Building a permissionless future, one node at a time.

Pipe Network is a hyper-localized, scalable content delivery network (CDN) built on Solana's high-performance blockchain. Each CDN PoP node in the network is strategically placed close to users for fast, reliable content delivery. Pipe Network's nodes ensure low-latency content streaming, making it ideal for media and real-time applications. Anyone can run a node, contributing to the network's growth and resilience.

## Introduction

Pipe Network is a decentralized, permissionless content delivery network (CDN) designed to address the limitations of traditional, centralized CDNs. By utilizing a unique architecture built on the Solana blockchain, Pipe Network offers a scalable, cost-efficient, and highly secure solution for delivering content globally.

### Current Limitations of Centralized CDNs

Centralized CDNs often require significant capital investment in infrastructure and are primarily concentrated in urban or high-traffic areas, leading to slower speeds in remote or underserved locations. Moreover, these CDNs operate within proprietary systems, creating barriers for smaller businesses and independent developers to access affordable content delivery solutions.

### The Demand for Decentralized, Permissionless CDNs

Decentralization offers the ability to spread content delivery responsibilities across a global network of independent nodes. Permissionless networks enable anyone with the necessary hardware to contribute to the network, eliminating central points of control and promoting true global distribution.

### Core Innovation

At the core of Pipe Network's innovation is the deployment of hyperlocal Pipe PoP (Points of Presence) nodes. These nodes are strategically distributed in underserved areas to optimize latency, ensuring that content is delivered faster and more efficiently than centralized CDNs, particularly in regions where traditional CDNs fall short. This hyperlocal focus enhances the user experience by dramatically reducing the distance data must travel, which is key to achieving real-time content delivery.

Through the use of Pipe Credits and Data Credits, Pipe Network offers flexible, transparent payment structures that align incentives between users and node operators. The network compensates node operators based on local resource scarcity, ensuring fair and efficient service delivery.

## Architecture

![Network Architecture](./assets/network_architecture.png)

### Node Structure and Hyperlocal PoP Strategy

At the heart of Pipe Network's architecture are its hyperlocal PoP nodes, strategically deployed to ensure that content is delivered with minimal latency. Unlike traditional CDNs that rely on large, centralized server farms in major cities, Pipe Network operates on a decentralized model, where independent operators can deploy nodes in their local regions.

### Content Distribution and Caching Mechanism

Pipe Network employs a distributed caching mechanism, where content is cached at the hyperlocal PoP nodes. The Cache Management System (CMS) manages the coordination of content, while individual nodes handle the local caching.

![CDN Advantages](./assets/cdn_advantages.png)

### Solana Blockchain Integration

Pipe Network is built on the Solana blockchain, chosen for its high throughput, low transaction costs, and speed. The Solana integration enables:
- Decentralized control through smart contracts
- Secure and efficient payment handling
- Transparent transaction recording
- Scalable performance

## Key Features

1. **Hyperlocal Pipe PoP Nodes**
   - Strategically placed close to users
   - Reduces latency significantly
   - Enables true real-time data delivery

2. **Cost Efficiency**
   - Lower operational costs through decentralization
   - Pay-as-you-use model with Data Credits
   - Transparent pricing structure

3. **Real-time Data Delivery**
   - Minimized latency through proximity
   - Optimized for streaming and real-time applications
   - Enhanced user experience

4. **Security and Data Integrity**
   - DDoS Protection
   - DMCA Complaint System
   - IP and Geo-blocking
   - Rolling egress logs

5. **Advanced Features**
   - Cache invalidation
   - Header filtering
   - URL query blocks
   - Local scarcity-based node incentives

## Scalability and Network Growth

### Decentralized Scalability
- Permissionless node operation
- Natural network expansion
- Incentive-driven growth

### Network Expansion Strategy
1. **Phase 1**: Initial deployment with CMS-connected nodes
2. **Phase 2**: Implementation of peer-to-peer connections
3. **Phase 3**: Advanced features and geographic expansion

## Opportunities and Use Cases

### CDN Space Opportunities
- Ultra-low latency content delivery
- Enhanced security through decentralization
- Cost-effective scaling
- Improved reliability

### Pipe Network CDN Advantages
- Hyper-local cache (L2 Pipe PoP)
- Reduced content travel distance
- Enhanced streaming quality
- Optimal efficiency

## Operating a DevNet CDN PoP Node

### System Requirements
- Linux OS
- Minimum 4GB RAM
- 100GB+ free disk space
- 24/7 internet connectivity
- Ports 80, 443, and 8003 accessible

### Installation and Setup
```bash
# Download the compiled pop binary
curl -L -o pop "https://dl.pipecdn.app/v0.2.8/pop"
chmod +x pop
mkdir download_cache
```

### Basic Configuration
```bash
sudo ./pop \
  --ram 8 \
  --max-disk 500 \
  --cache-dir /data \
  --pubKey <KEY>
```

### Monitoring and Management
```bash
# View metrics
./pop --status

# Check points
./pop --points-route
```

### Reputation System

The node's reputation score (0-1) is calculated based on the last 7 days of node operation:

1. **Uptime Score (40%)**
   - Reports grouped by hour
   - Good coverage: 75%+ hours reported per day
   - Weighted by coverage completeness

2. **Historical Score (30%)**
   - Based on days with good coverage
   - Rewards consistent reporting

3. **Egress Score (30%)**
   - Based on total data transferred
   - Normalized against 1TB/day target
   - Capped at 100%

### Troubleshooting

#### Common Issues and Solutions

1. **Service Activation Issues**
   ```bash
   # Verify service configuration
   sudo systemd-analyze verify pop.service
   
   # Check service config
   cat /etc/systemd/system/pop.service
   ```

2. **Download Issues**
   ```bash
   # Test download URL
   curl -I -s https://downloadurl.com | head -n 1
   ```

3. **Port Conflicts**
   ```bash
   # Check port usage
   sudo lsof -i :8003
   sudo netstat -tulpn | grep 8003
   ```

## CDN API Reference

This section provides a comprehensive overview of the Pipe CDN API. All endpoints are currently based on the Pipe Network CDN Devnet deployment on Solana Devnet.

### Base URL
All API endpoints are relative to the base URL.

### Authentication
Most endpoints require authentication using two parameters:

- `user_id`: The unique identifier for the user
- `user_app_key`: The application key for the user

These parameters are typically included as query parameters for GET requests or in the request body for POST requests.

### Account Management APIs

#### Create User
Creates a new user account.

```http
POST /createUser
Content-Type: application/json

Request Body:
{
  "username": "string"
}

Response:
{
  "user_id": "string",
  "user_app_key": "string",
  "solana_pubkey": "string"
}
```

#### Rotate App Key
Rotates (changes) the application key for a user.

```http
POST /rotateAppKey
Content-Type: application/json

Request Body:
{
  "user_id": "string",
  "user_app_key": "string"
}

Response:
{
  "user_id": "string",
  "new_user_app_key": "string"
}
```

### File Management APIs

#### Upload File
Uploads a file to Pipe CDN.

```http
POST /upload
Content-Type: multipart/form-data

Query Parameters:
- user_id: User ID
- user_app_key: User application key
- file_name: Name to store the file as
- epochs (optional): Storage duration in epochs

Body: File content as multipart/form-data
Response: The uploaded filename as a string
```

#### Priority Upload
Uploads a file with higher priority.

```http
POST /priorityUpload
Content-Type: multipart/form-data

Query Parameters:
- user_id: User ID
- user_app_key: User application key
- file_name: Name to store the file as
- epochs (optional): Storage duration in epochs

Body: File content as multipart/form-data
Response: The uploaded filename as a string
```

#### Download File
Downloads a file from Pipe CDN.

```http
GET /download

Query Parameters:
- user_id: User ID
- user_app_key: User application key
- file_name: Name of the file to download

Response: File content with appropriate Content-Type and Content-Length headers
```

#### Priority Download
Downloads a file with higher priority.

```http
GET /priorityDownload

Query Parameters:
- user_id: User ID
- user_app_key: User application key
- file_name: Name of the file to download

Response: File content as Base64-encoded string
```

#### Delete File
Deletes a file from storage.

```http
POST /deleteFile
Content-Type: application/json

Request Body:
{
  "user_id": "string",
  "user_app_key": "string",
  "file_name": "string"
}

Response:
{
  "message": "string"
}
```

#### Create Public Link
Creates a public link for a file.

```http
POST /createPublicLink
Content-Type: application/json

Request Body:
{
  "user_id": "string",
  "user_app_key": "string",
  "file_name": "string"
}

Response:
{
  "link_hash": "string"
}
```

#### Public Download
Downloads a file using a public link.

```http
GET /publicDownload

Query Parameters:
- hash: The public link hash

Response: File content with appropriate headers
```

#### Extend Storage
Extends the storage duration for a file.

```http
POST /extendStorage
Content-Type: application/json

Request Body:
{
  "user_id": "string",
  "user_app_key": "string",
  "file_name": "string",
  "additional_months": number
}

Response:
{
  "message": "string",
  "new_expires_at": "string"
}
```

### Wallet and Payments APIs

#### Check SOL Balance
```http
POST /checkWallet
Content-Type: application/json

Request Body:
{
  "user_id": "string",
  "user_app_key": "string"
}

Response:
{
  "user_id": "string",
  "public_key": "string",
  "balance_lamports": number,
  "balance_sol": number
}
```

#### Check PIPE Token Balance
```http
POST /getCustomTokenBalance
Content-Type: application/json

Request Body:
{
  "user_id": "string",
  "user_app_key": "string"
}

Response:
{
  "user_id": "string",
  "public_key": "string",
  "token_mint": "string",
  "amount": "string",
  "ui_amount": number
}
```

#### Check DC Balance
```http
POST /getDcBalance
Content-Type: application/json

Request Body:
{
  "user_id": "string",
  "user_app_key": "string"
}

Response:
{
  "user_id": "string",
  "dc_balance": number
}
```

#### Swap SOL for PIPE
```http
POST /swapSolForPipe
Content-Type: application/json

Request Body:
{
  "user_id": "string",
  "user_app_key": "string",
  "amount_sol": number
}

Response:
{
  "user_id": "string",
  "sol_spent": number,
  "tokens_minted": number
}
```

#### Swap PIPE for DC
```http
POST /swapPipeForDc
Content-Type: application/json

Request Body:
{
  "user_id": "string",
  "user_app_key": "string",
  "amount_pipe": number
}

Response:
{
  "user_id": "string",
  "pipe_spent": number,
  "dc_minted": number
}
```

#### Withdraw SOL
```http
POST /withdrawSol
Content-Type: application/json

Request Body:
{
  "user_id": "string",
  "user_app_key": "string",
  "to_pubkey": "string",
  "amount_sol": number
}

Response:
{
  "user_id": "string",
  "to_pubkey": "string",
  "amount_sol": number,
  "signature": "string"
}
```

#### Withdraw Custom Token
```http
POST /withdrawToken
Content-Type: application/json

Request Body:
{
  "user_id": "string",
  "user_app_key": "string",
  "to_pubkey": "string",
  "amount": number
}

Response:
{
  "user_id": "string",
  "to_pubkey": "string",
  "amount": number,
  "signature": "string"
}
```

### Utility APIs

#### Get Priority Fee
```http
GET /getPriorityFee

Response:
{
  "priority_fee_per_gb": number
}
```

#### Check Version
```http
POST /versionCheck
Content-Type: application/json

Request Body:
{
  "current_version": "string"
}

Response:
{
  "is_latest": boolean,
  "download_link": "string" (optional),
  "latest_version": "string" (optional),
  "release_notes": "string" (optional),
  "minimum_required": "string" (optional)
}
```

### Implementation Notes

#### Error Handling
All API calls should handle HTTP status codes appropriately:

- 200 OK: Successful request
- 400 Bad Request: Invalid request parameters
- 401 Unauthorized: Authentication failed
- 404 Not Found: Resource not found
- 500 Internal Server Error: Server-side error

Error responses typically include a text message explaining the error.

#### File Encryption
The Pipe CLI implements client-side encryption, which is not part of the API. If you want to implement encryption in your application:

- Use a strong encryption algorithm (AES-256-GCM is recommended)
- Generate and store a random salt and nonce for each encrypted file
- Derive an encryption key from the user's password using a strong KDF like Argon2
- Encrypt the file before uploading and decrypt after downloading
- Store encryption parameters (salt, nonce) securely, but never store the password

#### Best Practices
1. **Retries and Backoff**
   - Initial delay: 1000ms
   - Max delay: 10000ms
   - Limit retries: 3

2. **Upload Considerations**
   - Use chunked uploads or streaming for large files
   - Implement progress tracking
   - Limit concurrent requests to avoid overwhelming the server

## Future Development

### Testnet
Coming Soon!

### Mainnet
Coming 2025!

## Support and Resources

- [Dashboard](https://dashboard.pipenetwork.com/node-lookup)
- [DevNet Signup Form](https://docs.google.com/forms/d/e/1FAIpQLScbxN1qlstpbyU55K5I1UPufzfwshcv7uRJG6aLZQDk52ma0w/viewform)
- [GitHub Repository](https://github.com/preterag/surrealine-backend.git)

---

*Last updated: 2025* 