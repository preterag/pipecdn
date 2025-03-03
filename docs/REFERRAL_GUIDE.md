# Pipe Network Referral System Guide

## Overview

The Pipe Network includes a referral system that allows node operators to earn additional rewards by referring new nodes to the network. This guide explains how to generate and use referral codes, as well as how to track your referrals.

## How Referrals Work

According to the [official Pipe Network documentation](https://docs.pipe.network/devnet-2):

- Nodes can generate referral codes using the command: `./pop --gen-referral-route`
- New nodes can sign up with a referral code using: `./pop --signup-by-referral-route <CODE>`
- The referrer earns 10 points when the referred node:
  - Stays active for 7+ days
  - Maintains a reputation score > 0.5
- The referrer must also maintain a good reputation score for the referrals to be counted
- The program will expand over time to include rewards sharing

## Generating a Referral Code

To generate your own referral code:

1. Make sure your Pipe PoP node is running and has a good reputation score
2. Run the following command:
   ```bash
   ./bin/pipe-pop --gen-referral-route
   ```
3. The command will output a referral code that you can share with others

## Using a Referral Code

When setting up a new Pipe PoP node, you can use a referral code to help both yourself and the referrer:

1. After downloading the Pipe PoP binary, run:
   ```bash
   sudo ./bin/pipe-pop --signup-by-referral-route <REFERRAL_CODE>
   ```
2. Replace `<REFERRAL_CODE>` with the actual referral code you received
3. Continue with the normal setup process

## Using the Surrealine Referral Code

As a Surrealine user or customer, you can use our referral code when setting up your Pipe PoP node:

1. After downloading the Pipe PoP binary, run:
   ```bash
   sudo ./bin/pipe-pop --signup-by-referral-route <SURREALINE_REFERRAL_CODE>
   ```
2. This helps support the Surrealine platform while also benefiting your node

## Checking Referral Status

To check the status of your referrals:

1. Browse to [https://dashboard.pipenetwork.com/node-lookup](https://dashboard.pipenetwork.com/node-lookup)
2. Enter your node ID in the Node Lookup
3. Scroll down to "Referral Stats" to review your referred nodes

## Benefits of the Referral System

- **Additional Rewards**: Earn points for successful referrals
- **Network Growth**: Help expand the Pipe Network ecosystem
- **Future Benefits**: The referral program will expand to include more rewards in the future

## Best Practices

- Only refer people who have the necessary hardware and network capabilities
- Ensure referred nodes understand how to maintain a good reputation score
- Monitor your referrals to ensure they remain active and maintain good reputation scores
- Generate a new referral code periodically for security reasons 