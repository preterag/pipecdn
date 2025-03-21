#!/bin/bash

# Script to install Git hooks for PipeNetwork development

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored messages
print_message() { echo -e "${GREEN}[INFO]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if running in a git repository
if [ ! -d ".git" ]; then
    print_error "Not a git repository. Please run this script from the repository root."
    exit 1
fi

# Create hooks directory if it doesn't exist
mkdir -p .git/hooks

# Create pre-commit hook
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash

# Pre-commit hook to prevent accidental commits of sensitive or runtime data

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Running pre-commit checks...${NC}"

# Check for sensitive files in the staging area
SENSITIVE_PATTERNS=(
    "node_info.json"
    "cache/"
    "logs/"
    "backups/"
    "config/config.json"
    "\.env"
    "pipe-pop\.log"
    "_token"
    "_key"
    "_secret"
    "_password"
    "_credential"
    "\.dat$"
    "\.db$"
    "download_cache/"
)

STAGED_FILES=$(git diff --cached --name-only)

BLOCKED=0

for pattern in "${SENSITIVE_PATTERNS[@]}"; do
    MATCHES=$(echo "$STAGED_FILES" | grep -E "$pattern" || true)
    if [ -n "$MATCHES" ]; then
        echo -e "${RED}ERROR: Potential sensitive data found:${NC}"
        echo "$MATCHES"
        echo
        echo -e "${YELLOW}These files may contain sensitive information.${NC}"
        echo -e "If you're sure you want to commit them, use ${GREEN}git commit --no-verify${NC}"
        BLOCKED=1
    fi
done

# Check for large files (> 1MB)
for file in $STAGED_FILES; do
    if [ -f "$file" ]; then
        size=$(du -k "$file" | cut -f1)
        if [ "$size" -gt 1024 ]; then  # > 1MB
            echo -e "${RED}ERROR: Large file detected:${NC} $file ($size KB)"
            echo -e "Large files should not be committed to the repository."
            BLOCKED=1
        fi
    fi
done

# Check for personal wallet address
for file in $STAGED_FILES; do
    if [ -f "$file" ]; then
        # Exclude binary files
        if file "$file" | grep -q text; then
            # Look for Solana wallet pattern but exclude template strings and examples
            WALLET_MATCHES=$(grep -E "[1-9A-HJ-NP-Za-km-z]{32,44}" "$file" | grep -v "YOUR_SOLANA_WALLET_ADDRESS" | grep -v "\${PIPE_WALLET_ADDRESS}" | grep -v "6ee148015d530fb0" || true)
            if [ -n "$WALLET_MATCHES" ]; then
                echo -e "${RED}ERROR: Potential wallet address found in:${NC} $file"
                echo "$WALLET_MATCHES"
                BLOCKED=1
            fi
        fi
    fi
done

if [ "$BLOCKED" -eq 1 ]; then
    echo -e "${RED}Commit blocked due to potentially sensitive data.${NC}"
    echo -e "Review the issues above and adjust your commit."
    echo -e "To bypass these checks (USE WITH CAUTION), use: ${GREEN}git commit --no-verify${NC}"
    exit 1
fi

echo -e "${GREEN}Pre-commit checks passed.${NC}"
exit 0
EOF

# Make hooks executable
chmod +x .git/hooks/pre-commit

print_message "Git hooks installed successfully!"
print_message "Pre-commit hook will now prevent accidental commits of sensitive data." 