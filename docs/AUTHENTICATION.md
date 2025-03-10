# 🔐 GitHub Authentication Scripts

This document explains the scripts available for GitHub authentication and secure repository management.

## ⚠️ Security Warning

**IMPORTANT**: Never commit files containing tokens, passwords, or other sensitive information to your repository!

## 🛠️ Available Scripts

### 1. `setup_github_auth.sh`

This script helps you set up GitHub authentication using a Personal Access Token (PAT).

**Features:**
- 🧭 Guides you through creating a GitHub PAT if you don't have one
- 🔒 Configures Git to store credentials securely
- 🔗 Sets up your repository remote URL

**Usage:**
```bash
./setup_github_auth.sh
```

### 2. `secure_push.sh`

This script helps you commit and push changes to GitHub without exposing tokens.

**Features:**
- 🔍 Detects changes in the repository
- ✅ Assists with committing changes
- 🚀 Pushes changes to the remote repository
- 🛡️ Handles authentication securely

**Usage:**
```bash
./secure_push.sh
```

### 3. `git_setup.sh`

This script configures Git with useful aliases and secure credential storage.

**Features:**
- 🔐 Sets up secure credential storage
- ⚡ Configures useful Git aliases
- 🛑 Does not store any tokens in the repository

**Usage:**
```bash
./git_setup.sh
```

## 📋 How to Use

1. First, run `setup_github_auth.sh` to set up your GitHub authentication
2. Use `secure_push.sh` whenever you want to push changes
3. (Optional) Run `git_setup.sh` to configure useful Git aliases

## 🔒 Security Best Practices

1. **Never** include tokens or passwords in your code or commit them to the repository
2. Use `.gitignore` to prevent accidentally committing sensitive files
3. Regularly rotate your GitHub Personal Access Tokens
4. Use the most secure credential helper available on your system
5. Consider using SSH keys for authentication instead of PATs for even better security

## 🔑 Using SSH Instead of HTTPS

For even better security, consider using SSH keys instead of HTTPS with PATs:

1. Generate an SSH key pair:
   ```bash
   ssh-keygen -t ed25519 -C "your_email@example.com"
   ```

2. Add the public key to your GitHub account:
   - Copy the contents of `~/.ssh/id_ed25519.pub`
   - Go to GitHub → Settings → SSH and GPG keys → New SSH key
   - Paste your key and save

3. Change your remote URL to use SSH:
   ```bash
   git remote set-url origin git@github.com:username/repository.git
   ```

With SSH keys, you won't need to enter your credentials each time you push. 