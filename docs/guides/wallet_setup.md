# Wallet Setup

Your Pipe Network node needs a Solana wallet address to collect rewards.

## Quick Setup

During installation, you'll be prompted for your wallet address:

```
Enter your Solana wallet address: [your address]
```

## Updating Your Wallet

To update your wallet later:

```bash
sudo pop wallet set YOUR_WALLET_ADDRESS
```

## Creating a Wallet

If you don't have a Solana wallet:

1. **Download a wallet app:**
   - [Phantom](https://phantom.app/) (recommended)
   - [Solflare](https://solflare.com/)

2. **Create a new wallet**
   - Write down your recovery phrase
   - Store it securely offline

3. **Copy your public address**
   - This is what you'll use for your node

## Checking Your Wallet

Verify which wallet is connected:

```bash
pop wallet info
```

## Security Tips

- Never share your recovery phrase or private key
- Only use your public address with your node
- Keep a backup of your wallet information
- Use a dedicated wallet for your node 