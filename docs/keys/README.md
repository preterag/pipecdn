# pipe-pop GPG Keys

This directory contains the GPG keys used to sign pipe-pop packages.

## Contents

- `README.md`: This file
- `public.key`: The public GPG key used to verify pipe-pop packages

## Usage

### Importing the Public Key

To import the public key for verifying packages:

```bash
# Download and import the key
wget -O- https://raw.githubusercontent.com/preterag/pipe-pop/main/keys/public.key | gpg --import
```

### Verifying a Package

To verify a package signature:

```bash
# Download the package and signature
wget https://github.com/preterag/pipe-pop/releases/download/v1.0.0/pipe-pop-1.0.0-amd64.AppImage
wget https://github.com/preterag/pipe-pop/releases/download/v1.0.0/pipe-pop-1.0.0-amd64.AppImage.asc

# Verify the signature
gpg --verify pipe-pop-1.0.0-amd64.AppImage.asc pipe-pop-1.0.0-amd64.AppImage
```

## Key Generation

The GPG key was generated using the `installers/generate_gpg_key.sh` script. The private key is stored securely and is not included in this repository.

## Security

The private key is kept secure and is only used for signing official pipe-pop releases. If you suspect a security issue with any pipe-pop package, please report it immediately by opening an issue on GitHub.