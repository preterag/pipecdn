# Installation Guide

## Prerequisites

- Ubuntu 20.04 or later
- Python 3.8 or later
- Node.js 14 or later

## Installation

### Using DEB Package

1. Download the latest DEB package:
```bash
curl -O https://example.com/pipe-pop_latest.deb
```

2. Install the package:
```bash
sudo dpkg -i pipe-pop_latest.deb
```

3. Start the service:
```bash
sudo systemctl start pipe-pop
```

### Manual Installation

1. Clone the repository:
```bash
git clone https://github.com/preterag/ppn.git
```

2. Install dependencies:
```bash
cd pipe-pop
./scripts/install.sh
```

3. Configure the service:
```bash
./src/config/config.sh
```

4. Start the service:
```bash
./scripts/install.sh start
```
