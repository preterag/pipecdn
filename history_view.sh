#!/bin/bash

# History Visualization Script for Pipe Network PoP Node
# This script visualizes historical leaderboard data

# Installation directory
INSTALL_DIR="/opt/pipe-pop"
# Main PipeNetwork directory
PIPE_DIR="/home/karo/Workspace/PipeNetwork"
# History directory
HISTORY_DIR="${PIPE_DIR}/history"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Function to print colored messages
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show help
show_help() {
    echo "Pipe Network PoP Node History Visualization"
    echo "Usage: ./history_view.sh [OPTION]"
    echo ""
    echo "Options:"
    echo "  --rank                  Show rank history for your node"
    echo "  --reputation            Show reputation history for your node"
    echo "  --points                Show points history for your node"
    echo "  --egress                Show egress history for your node"
    echo "  --top-nodes [COUNT]     Show history for top N nodes (default: 5)"
    echo "  --days [DAYS]           Number of days to show (default: 7)"
    echo "  --help                  Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./history_view.sh --rank           Show your node's rank history"
    echo "  ./history_view.sh --reputation     Show your node's reputation history"
    echo "  ./history_view.sh --top-nodes 3    Show history for top 3 nodes"
    echo "  ./history_view.sh --days 14        Show history for the last 14 days"
}

# Check if required tools are installed
check_dependencies() {
    if ! command -v jq &> /dev/null; then
        print_error "The 'jq' command is required but not installed."
        print_message "Installing jq..."
        if [ "$EUID" -ne 0 ]; then
            print_error "This command requires root to install dependencies."
            print_message "Please run: sudo apt-get install jq"
            exit 1
        fi
        apt-get update && apt-get install -y jq
    fi
    
    if ! command -v gnuplot &> /dev/null; then
        print_warning "The 'gnuplot' command is not installed. ASCII visualization will be used instead."
        print_message "For better visualization, install gnuplot:"
        print_message "sudo apt-get install gnuplot"
        USE_ASCII=true
    else
        USE_ASCII=false
    fi
}

# Get our node ID
get_node_id() {
    NODE_ID=$(cat ${PIPE_DIR}/cache/node_info.json 2>/dev/null | grep -o '"node_id": "[^"]*' | cut -d'"' -f4)
    if [ -z "$NODE_ID" ]; then
        print_error "Could not determine node ID. Please check your installation."
        exit 1
    fi
    print_message "Found node ID: $NODE_ID"
}

# Check if history directory exists and has data
check_history() {
    if [ ! -d "$HISTORY_DIR" ]; then
        print_error "History directory not found. Please run 'pop --leaderboard' first."
        exit 1
    fi
    
    # Count history files
    HISTORY_COUNT=$(find "$HISTORY_DIR" -name "leaderboard_*.json" | wc -l)
    if [ "$HISTORY_COUNT" -eq 0 ]; then
        print_error "No history data found. Please run 'pop --leaderboard' first."
        exit 1
    fi
    
    print_message "Found $HISTORY_COUNT history files."
}

# Function to display rank history
show_rank_history() {
    print_message "Analyzing rank history for your node..."
    
    # Create temporary file for data
    TEMP_FILE=$(mktemp)
    trap 'rm -f "$TEMP_FILE"; exit 0' EXIT INT TERM
    
    # Get history files sorted by date (newest first)
    HISTORY_FILES=$(find "$HISTORY_DIR" -name "leaderboard_*.json" -type f -printf "%T@ %p\n" | sort -nr | awk '{print $2}' | head -n $DAYS)
    
    # Check if we have enough history
    HISTORY_COUNT=$(echo "$HISTORY_FILES" | wc -l)
    if [ "$HISTORY_COUNT" -lt 2 ]; then
        print_warning "Not enough history data for visualization. Need at least 2 data points."
        print_message "Current data:"
        
        # Show current rank
        LATEST_FILE=$(echo "$HISTORY_FILES" | head -n 1)
        LATEST_DATE=$(date -r "$LATEST_FILE" "+%Y-%m-%d %H:%M")
        
        # Try to find our node in the file
        OUR_RANK=$(jq -r --arg nodeid "$NODE_ID" '.nodes[] | select(.node_id == $nodeid) | .rank' "$LATEST_FILE" 2>/dev/null)
        
        if [ -z "$OUR_RANK" ] || [ "$OUR_RANK" = "null" ]; then
            # Node not in top list, check if we have specific node data in your_node section
            OUR_RANK=$(jq -r '.your_node.rank' "$LATEST_FILE" 2>/dev/null)
        fi
        
        if [ -n "$OUR_RANK" ] && [ "$OUR_RANK" != "null" ]; then
            echo "Rank on $LATEST_DATE: $OUR_RANK"
        else
            print_error "Could not find rank data for your node."
        fi
        
        exit 0
    fi
    
    # Process history files
    echo "date,rank" > "$TEMP_FILE"
    
    for file in $HISTORY_FILES; do
        FILE_DATE=$(date -r "$file" "+%Y-%m-%d %H:%M")
        
        # Try to find our node in the file
        OUR_RANK=$(jq -r --arg nodeid "$NODE_ID" '.nodes[] | select(.node_id == $nodeid) | .rank' "$file" 2>/dev/null)
        
        if [ -z "$OUR_RANK" ] || [ "$OUR_RANK" = "null" ]; then
            # Node not in top list, check if we have specific node data in your_node section
            OUR_RANK=$(jq -r '.your_node.rank' "$file" 2>/dev/null)
        fi
        
        if [ -n "$OUR_RANK" ] && [ "$OUR_RANK" != "null" ]; then
            echo "$FILE_DATE,$OUR_RANK" >> "$TEMP_FILE"
        fi
    done
    
    # Display the data
    echo -e "\n${CYAN}Rank History for Your Node${NC}"
    echo -e "${CYAN}=========================${NC}"
    
    # Sort by date (oldest first)
    SORTED_DATA=$(tail -n +2 "$TEMP_FILE" | sort -t ',' -k1)
    
    # Display as table
    echo -e "${CYAN}Date                Rank${NC}"
    echo -e "${CYAN}----                ----${NC}"
    echo "$SORTED_DATA" | while IFS=, read -r date rank; do
        printf "%-20s %s\n" "$date" "$rank"
    done
    
    # Display trend
    echo -e "\n${CYAN}Rank Trend (lower is better)${NC}"
    echo -e "${CYAN}==========================${NC}"
    
    if [ "$USE_ASCII" = true ]; then
        # Simple ASCII visualization
        PREV_RANK=""
        echo "$SORTED_DATA" | while IFS=, read -r date rank; do
            if [ -n "$PREV_RANK" ]; then
                if [[ "$rank" =~ ^[0-9]+$ ]] && [[ "$PREV_RANK" =~ ^[0-9]+$ ]]; then
                    if [ "$rank" -lt "$PREV_RANK" ]; then
                        TREND="↑ Improved"
                        TREND_COLOR=$GREEN
                    elif [ "$rank" -gt "$PREV_RANK" ]; then
                        TREND="↓ Declined"
                        TREND_COLOR=$RED
                    else
                        TREND="→ No change"
                        TREND_COLOR=$YELLOW
                    fi
                    printf "%-20s %-4s %s${TREND_COLOR}%s${NC}\n" "$date" "$rank" "from $PREV_RANK: " "$TREND"
                else
                    printf "%-20s %s\n" "$date" "$rank"
                fi
            else
                printf "%-20s %s\n" "$date" "$rank"
            fi
            PREV_RANK="$rank"
        done
    else
        # Generate gnuplot script
        GNUPLOT_SCRIPT=$(mktemp)
        cat > "$GNUPLOT_SCRIPT" << EOF
set terminal dumb 80 25
set title "Node Rank History (lower is better)"
set xlabel "Date"
set ylabel "Rank"
set yrange [*:1] reverse
set timefmt "%Y-%m-%d %H:%M"
set xdata time
set format x "%m-%d"
set grid
plot "$TEMP_FILE" using 1:2 with linespoints title "Your Node Rank"
EOF
        gnuplot "$GNUPLOT_SCRIPT"
        rm -f "$GNUPLOT_SCRIPT"
    fi
}

# Function to display reputation history
show_reputation_history() {
    print_message "Analyzing reputation history for your node..."
    
    # Create temporary file for data
    TEMP_FILE=$(mktemp)
    trap 'rm -f "$TEMP_FILE"; exit 0' EXIT INT TERM
    
    # Get history files sorted by date (newest first)
    HISTORY_FILES=$(find "$HISTORY_DIR" -name "leaderboard_*.json" -type f -printf "%T@ %p\n" | sort -nr | awk '{print $2}' | head -n $DAYS)
    
    # Check if we have enough history
    HISTORY_COUNT=$(echo "$HISTORY_FILES" | wc -l)
    if [ "$HISTORY_COUNT" -lt 2 ]; then
        print_warning "Not enough history data for visualization. Need at least 2 data points."
        print_message "Current data:"
        
        # Show current reputation
        LATEST_FILE=$(echo "$HISTORY_FILES" | head -n 1)
        LATEST_DATE=$(date -r "$LATEST_FILE" "+%Y-%m-%d %H:%M")
        
        # Try to find our node in the file
        OUR_REP=$(jq -r --arg nodeid "$NODE_ID" '.nodes[] | select(.node_id == $nodeid) | .reputation' "$LATEST_FILE" 2>/dev/null)
        
        if [ -z "$OUR_REP" ] || [ "$OUR_REP" = "null" ]; then
            # Node not in top list, check if we have specific node data in your_node section
            OUR_REP=$(jq -r '.your_node.reputation' "$LATEST_FILE" 2>/dev/null)
        fi
        
        if [ -n "$OUR_REP" ] && [ "$OUR_REP" != "null" ]; then
            echo "Reputation on $LATEST_DATE: $OUR_REP"
        else
            print_error "Could not find reputation data for your node."
        fi
        
        exit 0
    fi
    
    # Process history files
    echo "date,reputation" > "$TEMP_FILE"
    
    for file in $HISTORY_FILES; do
        FILE_DATE=$(date -r "$file" "+%Y-%m-%d %H:%M")
        
        # Try to find our node in the file
        OUR_REP=$(jq -r --arg nodeid "$NODE_ID" '.nodes[] | select(.node_id == $nodeid) | .reputation' "$file" 2>/dev/null)
        
        if [ -z "$OUR_REP" ] || [ "$OUR_REP" = "null" ]; then
            # Node not in top list, check if we have specific node data in your_node section
            OUR_REP=$(jq -r '.your_node.reputation' "$file" 2>/dev/null)
        fi
        
        if [ -n "$OUR_REP" ] && [ "$OUR_REP" != "null" ]; then
            echo "$FILE_DATE,$OUR_REP" >> "$TEMP_FILE"
        fi
    done
    
    # Display the data
    echo -e "\n${CYAN}Reputation History for Your Node${NC}"
    echo -e "${CYAN}==============================${NC}"
    
    # Sort by date (oldest first)
    SORTED_DATA=$(tail -n +2 "$TEMP_FILE" | sort -t ',' -k1)
    
    # Display as table
    echo -e "${CYAN}Date                Reputation${NC}"
    echo -e "${CYAN}----                ----------${NC}"
    echo "$SORTED_DATA" | while IFS=, read -r date rep; do
        printf "%-20s %s\n" "$date" "$rep"
    done
    
    # Display trend
    echo -e "\n${CYAN}Reputation Trend (higher is better)${NC}"
    echo -e "${CYAN}=================================${NC}"
    
    if [ "$USE_ASCII" = true ]; then
        # Simple ASCII visualization
        PREV_REP=""
        echo "$SORTED_DATA" | while IFS=, read -r date rep; do
            if [ -n "$PREV_REP" ]; then
                if [[ "$rep" =~ ^[0-9.]+$ ]] && [[ "$PREV_REP" =~ ^[0-9.]+$ ]]; then
                    if (( $(echo "$rep > $PREV_REP" | bc -l) )); then
                        TREND="↑ Improved"
                        TREND_COLOR=$GREEN
                    elif (( $(echo "$rep < $PREV_REP" | bc -l) )); then
                        TREND="↓ Declined"
                        TREND_COLOR=$RED
                    else
                        TREND="→ No change"
                        TREND_COLOR=$YELLOW
                    fi
                    printf "%-20s %-10s %s${TREND_COLOR}%s${NC}\n" "$date" "$rep" "from $PREV_REP: " "$TREND"
                else
                    printf "%-20s %s\n" "$date" "$rep"
                fi
            else
                printf "%-20s %s\n" "$date" "$rep"
            fi
            PREV_REP="$rep"
        done
    else
        # Generate gnuplot script
        GNUPLOT_SCRIPT=$(mktemp)
        cat > "$GNUPLOT_SCRIPT" << EOF
set terminal dumb 80 25
set title "Node Reputation History"
set xlabel "Date"
set ylabel "Reputation"
set yrange [0:1]
set timefmt "%Y-%m-%d %H:%M"
set xdata time
set format x "%m-%d"
set grid
plot "$TEMP_FILE" using 1:2 with linespoints title "Your Node Reputation"
EOF
        gnuplot "$GNUPLOT_SCRIPT"
        rm -f "$GNUPLOT_SCRIPT"
    fi
}

# Function to display top nodes history
show_top_nodes_history() {
    print_message "Analyzing history for top $TOP_NODES nodes..."
    
    # Create temporary directory for data
    TEMP_DIR=$(mktemp -d)
    trap 'rm -rf "$TEMP_DIR"; exit 0' EXIT INT TERM
    
    # Get history files sorted by date (newest first)
    HISTORY_FILES=$(find "$HISTORY_DIR" -name "leaderboard_reputation_*.json" -type f -printf "%T@ %p\n" | sort -nr | awk '{print $2}' | head -n $DAYS)
    
    # Check if we have enough history
    HISTORY_COUNT=$(echo "$HISTORY_FILES" | wc -l)
    if [ "$HISTORY_COUNT" -lt 2 ]; then
        print_warning "Not enough history data for visualization. Need at least 2 data points."
        exit 0
    fi
    
    # Get the latest file to identify top nodes
    LATEST_FILE=$(echo "$HISTORY_FILES" | head -n 1)
    TOP_NODE_IDS=$(jq -r ".nodes | sort_by(.rank) | .[0:$TOP_NODES] | .[].node_id" "$LATEST_FILE" 2>/dev/null)
    
    if [ -z "$TOP_NODE_IDS" ]; then
        print_error "Could not extract top node IDs from history data."
        exit 1
    fi
    
    # Process history files for each top node
    NODE_COUNT=0
    for node_id in $TOP_NODE_IDS; do
        NODE_COUNT=$((NODE_COUNT + 1))
        NODE_FILE="$TEMP_DIR/node_${NODE_COUNT}.csv"
        echo "date,rank,reputation" > "$NODE_FILE"
        
        # Get short node ID for display
        SHORT_ID="${node_id:0:12}..."
        
        # Process each history file for this node
        for file in $HISTORY_FILES; do
            FILE_DATE=$(date -r "$file" "+%Y-%m-%d %H:%M")
            
            # Extract node data
            NODE_DATA=$(jq -r --arg nodeid "$node_id" '.nodes[] | select(.node_id == $nodeid) | "\(.rank),\(.reputation)"' "$file" 2>/dev/null)
            
            if [ -n "$NODE_DATA" ]; then
                echo "$FILE_DATE,$NODE_DATA" >> "$NODE_FILE"
            fi
        done
    done
    
    # Display the data
    echo -e "\n${CYAN}Top $TOP_NODES Nodes History${NC}"
    echo -e "${CYAN}======================${NC}"
    
    # Display each node's data
    for i in $(seq 1 $NODE_COUNT); do
        NODE_FILE="$TEMP_DIR/node_${i}.csv"
        NODE_ID=$(echo "$TOP_NODE_IDS" | sed -n "${i}p")
        SHORT_ID="${NODE_ID:0:12}..."
        
        echo -e "\n${YELLOW}Node $i: $SHORT_ID${NC}"
        
        # Sort by date (oldest first)
        SORTED_DATA=$(tail -n +2 "$NODE_FILE" | sort -t ',' -k1)
        
        # Display as table
        echo -e "${CYAN}Date                Rank    Reputation${NC}"
        echo -e "${CYAN}----                ----    ----------${NC}"
        echo "$SORTED_DATA" | while IFS=, read -r date rank rep; do
            printf "%-20s %-7s %s\n" "$date" "$rank" "$rep"
        done
    done
    
    # Display comparison
    if [ "$USE_ASCII" = false ] && [ "$NODE_COUNT" -gt 0 ]; then
        echo -e "\n${CYAN}Reputation Comparison${NC}"
        echo -e "${CYAN}=====================${NC}"
        
        # Generate gnuplot script for reputation comparison
        GNUPLOT_SCRIPT="$TEMP_DIR/plot.gp"
        cat > "$GNUPLOT_SCRIPT" << EOF
set terminal dumb 80 25
set title "Top Nodes Reputation Comparison"
set xlabel "Date"
set ylabel "Reputation"
set yrange [0:1]
set timefmt "%Y-%m-%d %H:%M"
set xdata time
set format x "%m-%d"
set grid
plot \\
EOF
        
        # Add each node to the plot
        for i in $(seq 1 $NODE_COUNT); do
            NODE_FILE="$TEMP_DIR/node_${i}.csv"
            if [ "$i" -lt "$NODE_COUNT" ]; then
                echo "\"$NODE_FILE\" using 1:3 with linespoints title \"Node $i\", \\" >> "$GNUPLOT_SCRIPT"
            else
                echo "\"$NODE_FILE\" using 1:3 with linespoints title \"Node $i\"" >> "$GNUPLOT_SCRIPT"
            fi
        done
        
        gnuplot "$GNUPLOT_SCRIPT"
    fi
}

# Function to display points history
show_points_history() {
    print_message "Analyzing points history for your node..."
    
    # Create temporary file for data
    TEMP_FILE=$(mktemp)
    trap 'rm -f "$TEMP_FILE"; exit 0' EXIT INT TERM
    
    # Get history files sorted by date (newest first)
    HISTORY_FILES=$(find "$HISTORY_DIR" -name "leaderboard_*.json" -type f -printf "%T@ %p\n" | sort -nr | awk '{print $2}' | head -n $DAYS)
    
    # Check if we have enough history
    HISTORY_COUNT=$(echo "$HISTORY_FILES" | wc -l)
    if [ "$HISTORY_COUNT" -lt 2 ]; then
        print_warning "Not enough history data for visualization. Need at least 2 data points."
        print_message "Current data:"
        
        # Show current points
        LATEST_FILE=$(echo "$HISTORY_FILES" | head -n 1)
        LATEST_DATE=$(date -r "$LATEST_FILE" "+%Y-%m-%d %H:%M")
        
        # Try to find our node in the file
        OUR_POINTS=$(jq -r --arg nodeid "$NODE_ID" '.nodes[] | select(.node_id == $nodeid) | .points' "$LATEST_FILE" 2>/dev/null)
        
        if [ -z "$OUR_POINTS" ] || [ "$OUR_POINTS" = "null" ]; then
            # Node not in top list, check if we have specific node data in your_node section
            OUR_POINTS=$(jq -r '.your_node.points' "$LATEST_FILE" 2>/dev/null)
        fi
        
        if [ -n "$OUR_POINTS" ] && [ "$OUR_POINTS" != "null" ]; then
            echo "Points on $LATEST_DATE: $OUR_POINTS"
        else
            print_error "Could not find points data for your node."
        fi
        
        exit 0
    fi
    
    # Process history files
    echo "date,points" > "$TEMP_FILE"
    
    for file in $HISTORY_FILES; do
        FILE_DATE=$(date -r "$file" "+%Y-%m-%d %H:%M")
        
        # Try to find our node in the file
        OUR_POINTS=$(jq -r --arg nodeid "$NODE_ID" '.nodes[] | select(.node_id == $nodeid) | .points' "$file" 2>/dev/null)
        
        if [ -z "$OUR_POINTS" ] || [ "$OUR_POINTS" = "null" ]; then
            # Node not in top list, check if we have specific node data in your_node section
            OUR_POINTS=$(jq -r '.your_node.points' "$file" 2>/dev/null)
        fi
        
        if [ -n "$OUR_POINTS" ] && [ "$OUR_POINTS" != "null" ]; then
            echo "$FILE_DATE,$OUR_POINTS" >> "$TEMP_FILE"
        fi
    done
    
    # Display the data
    echo -e "\n${CYAN}Points History for Your Node${NC}"
    echo -e "${CYAN}==========================${NC}"
    
    # Sort by date (oldest first)
    SORTED_DATA=$(tail -n +2 "$TEMP_FILE" | sort -t ',' -k1)
    
    # Display as table
    echo -e "${CYAN}Date                Points${NC}"
    echo -e "${CYAN}----                ------${NC}"
    echo "$SORTED_DATA" | while IFS=, read -r date points; do
        printf "%-20s %s\n" "$date" "$points"
    done
    
    # Display trend
    echo -e "\n${CYAN}Points Trend (higher is better)${NC}"
    echo -e "${CYAN}==============================${NC}"
    
    if [ "$USE_ASCII" = true ]; then
        # Simple ASCII visualization
        PREV_POINTS=""
        echo "$SORTED_DATA" | while IFS=, read -r date points; do
            if [ -n "$PREV_POINTS" ]; then
                if [[ "$points" =~ ^[0-9]+$ ]] && [[ "$PREV_POINTS" =~ ^[0-9]+$ ]]; then
                    if [ "$points" -gt "$PREV_POINTS" ]; then
                        TREND="↑ Increased"
                        TREND_COLOR=$GREEN
                        DIFF=$((points - PREV_POINTS))
                        TREND="$TREND (+$DIFF)"
                    elif [ "$points" -lt "$PREV_POINTS" ]; then
                        TREND="↓ Decreased"
                        TREND_COLOR=$RED
                        DIFF=$((PREV_POINTS - points))
                        TREND="$TREND (-$DIFF)"
                    else
                        TREND="→ No change"
                        TREND_COLOR=$YELLOW
                    fi
                    printf "%-20s %-7s %s${TREND_COLOR}%s${NC}\n" "$date" "$points" "from $PREV_POINTS: " "$TREND"
                else
                    printf "%-20s %s\n" "$date" "$points"
                fi
            else
                printf "%-20s %s\n" "$date" "$points"
            fi
            PREV_POINTS="$points"
        done
    else
        # Generate gnuplot script
        GNUPLOT_SCRIPT=$(mktemp)
        cat > "$GNUPLOT_SCRIPT" << EOF
set terminal dumb 80 25
set title "Node Points History"
set xlabel "Date"
set ylabel "Points"
set timefmt "%Y-%m-%d %H:%M"
set xdata time
set format x "%m-%d"
set grid
plot "$TEMP_FILE" using 1:2 with linespoints title "Your Node Points"
EOF
        gnuplot "$GNUPLOT_SCRIPT"
        rm -f "$GNUPLOT_SCRIPT"
    fi
}

# Function to display egress history
show_egress_history() {
    print_message "Analyzing egress history for your node..."
    
    # Create temporary file for data
    TEMP_FILE=$(mktemp)
    trap 'rm -f "$TEMP_FILE"; exit 0' EXIT INT TERM
    
    # Get history files sorted by date (newest first)
    HISTORY_FILES=$(find "$HISTORY_DIR" -name "leaderboard_*.json" -type f -printf "%T@ %p\n" | sort -nr | awk '{print $2}' | head -n $DAYS)
    
    # Check if we have enough history
    HISTORY_COUNT=$(echo "$HISTORY_FILES" | wc -l)
    if [ "$HISTORY_COUNT" -lt 2 ]; then
        print_warning "Not enough history data for visualization. Need at least 2 data points."
        print_message "Current data:"
        
        # Show current egress
        LATEST_FILE=$(echo "$HISTORY_FILES" | head -n 1)
        LATEST_DATE=$(date -r "$LATEST_FILE" "+%Y-%m-%d %H:%M")
        
        # Try to find our node in the file
        OUR_EGRESS=$(jq -r --arg nodeid "$NODE_ID" '.nodes[] | select(.node_id == $nodeid) | .egress' "$LATEST_FILE" 2>/dev/null)
        
        if [ -z "$OUR_EGRESS" ] || [ "$OUR_EGRESS" = "null" ]; then
            # Node not in top list, check if we have specific node data in your_node section
            OUR_EGRESS=$(jq -r '.your_node.egress' "$LATEST_FILE" 2>/dev/null)
        fi
        
        if [ -n "$OUR_EGRESS" ] && [ "$OUR_EGRESS" != "null" ]; then
            echo "Egress on $LATEST_DATE: $OUR_EGRESS"
        else
            print_error "Could not find egress data for your node."
        fi
        
        exit 0
    fi
    
    # Process history files
    echo "date,egress,numeric_egress" > "$TEMP_FILE"
    
    for file in $HISTORY_FILES; do
        FILE_DATE=$(date -r "$file" "+%Y-%m-%d %H:%M")
        
        # Try to find our node in the file
        OUR_EGRESS=$(jq -r --arg nodeid "$NODE_ID" '.nodes[] | select(.node_id == $nodeid) | .egress' "$file" 2>/dev/null)
        
        if [ -z "$OUR_EGRESS" ] || [ "$OUR_EGRESS" = "null" ]; then
            # Node not in top list, check if we have specific node data in your_node section
            OUR_EGRESS=$(jq -r '.your_node.egress' "$file" 2>/dev/null)
        fi
        
        if [ -n "$OUR_EGRESS" ] && [ "$OUR_EGRESS" != "null" ]; then
            # Extract numeric value for comparison (assuming format like "3.2 TB")
            NUMERIC_EGRESS=$(echo "$OUR_EGRESS" | awk '{print $1}')
            echo "$FILE_DATE,$OUR_EGRESS,$NUMERIC_EGRESS" >> "$TEMP_FILE"
        fi
    done
    
    # Display the data
    echo -e "\n${CYAN}Egress History for Your Node${NC}"
    echo -e "${CYAN}==========================${NC}"
    
    # Sort by date (oldest first)
    SORTED_DATA=$(tail -n +2 "$TEMP_FILE" | sort -t ',' -k1)
    
    # Display as table
    echo -e "${CYAN}Date                Egress${NC}"
    echo -e "${CYAN}----                ------${NC}"
    echo "$SORTED_DATA" | while IFS=, read -r date egress numeric; do
        printf "%-20s %s\n" "$date" "$egress"
    done
    
    # Display trend
    echo -e "\n${CYAN}Egress Trend (higher is better)${NC}"
    echo -e "${CYAN}=============================${NC}"
    
    if [ "$USE_ASCII" = true ]; then
        # Simple ASCII visualization
        PREV_EGRESS=""
        PREV_NUMERIC=""
        echo "$SORTED_DATA" | while IFS=, read -r date egress numeric; do
            if [ -n "$PREV_EGRESS" ]; then
                if [[ "$numeric" =~ ^[0-9.]+$ ]] && [[ "$PREV_NUMERIC" =~ ^[0-9.]+$ ]]; then
                    if (( $(echo "$numeric > $PREV_NUMERIC" | bc -l) )); then
                        TREND="↑ Increased"
                        TREND_COLOR=$GREEN
                        DIFF=$(echo "$numeric - $PREV_NUMERIC" | bc -l)
                        DIFF=$(printf "%.2f" $DIFF)
                        TREND="$TREND (+$DIFF)"
                    elif (( $(echo "$numeric < $PREV_NUMERIC" | bc -l) )); then
                        TREND="↓ Decreased"
                        TREND_COLOR=$RED
                        DIFF=$(echo "$PREV_NUMERIC - $numeric" | bc -l)
                        DIFF=$(printf "%.2f" $DIFF)
                        TREND="$TREND (-$DIFF)"
                    else
                        TREND="→ No change"
                        TREND_COLOR=$YELLOW
                    fi
                    printf "%-20s %-10s %s${TREND_COLOR}%s${NC}\n" "$date" "$egress" "from $PREV_EGRESS: " "$TREND"
                else
                    printf "%-20s %s\n" "$date" "$egress"
                fi
            else
                printf "%-20s %s\n" "$date" "$egress"
            fi
            PREV_EGRESS="$egress"
            PREV_NUMERIC="$numeric"
        done
    else
        # Generate gnuplot script
        GNUPLOT_SCRIPT=$(mktemp)
        cat > "$GNUPLOT_SCRIPT" << EOF
set terminal dumb 80 25
set title "Node Egress History"
set xlabel "Date"
set ylabel "Egress (TB)"
set timefmt "%Y-%m-%d %H:%M"
set xdata time
set format x "%m-%d"
set grid
plot "$TEMP_FILE" using 1:3 with linespoints title "Your Node Egress"
EOF
        gnuplot "$GNUPLOT_SCRIPT"
        rm -f "$GNUPLOT_SCRIPT"
    fi
}

# Main execution
# Set defaults
DAYS=7
TOP_NODES=5

# Parse command line arguments
if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

while [ $# -gt 0 ]; do
    case "$1" in
        --rank)
            SHOW_RANK=true
            shift
            ;;
        --reputation)
            SHOW_REPUTATION=true
            shift
            ;;
        --points)
            SHOW_POINTS=true
            shift
            ;;
        --egress)
            SHOW_EGRESS=true
            shift
            ;;
        --top-nodes)
            SHOW_TOP_NODES=true
            if [[ "$2" =~ ^[0-9]+$ ]]; then
                TOP_NODES="$2"
                shift
            fi
            shift
            ;;
        --days)
            if [[ "$2" =~ ^[0-9]+$ ]]; then
                DAYS="$2"
                shift
            fi
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Check dependencies
check_dependencies

# Check history directory
check_history

# Get node ID
get_node_id

# Show requested data
if [ "$SHOW_RANK" = true ]; then
    show_rank_history
fi

if [ "$SHOW_REPUTATION" = true ]; then
    show_reputation_history
fi

if [ "$SHOW_TOP_NODES" = true ]; then
    show_top_nodes_history
fi

if [ "$SHOW_POINTS" = true ]; then
    show_points_history
fi

if [ "$SHOW_EGRESS" = true ]; then
    show_egress_history
fi

# If no specific visualization was requested, show help
if [ "$SHOW_RANK" != true ] && [ "$SHOW_REPUTATION" != true ] && [ "$SHOW_TOP_NODES" != true ] && [ "$SHOW_POINTS" != true ] && [ "$SHOW_EGRESS" != true ]; then
    print_warning "No visualization option specified."
    show_help
fi

exit 0 