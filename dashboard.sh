#!/bin/bash

# Pipe Network PoP Node Dashboard
# This script provides a comprehensive dashboard for monitoring your node

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
WHITE='\033[1;37m'
BOLD='\033[1m'
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

print_header() {
    echo -e "${CYAN}${BOLD}$1${NC}"
}

print_subheader() {
    echo -e "${BLUE}$1${NC}"
}

# Function to show help
show_help() {
    echo "Pipe Network PoP Node Dashboard"
    echo "Usage: ./dashboard.sh [OPTION]"
    echo ""
    echo "Options:"
    echo "  --refresh SECONDS      Set refresh interval in seconds (default: 5)"
    echo "  --compact              Show compact view (less details)"
    echo "  --full                 Show full view with all details (default)"
    echo "  --no-history           Don't show historical data"
    echo "  --export HTML          Export dashboard to HTML file"
    echo "  --help                 Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./dashboard.sh                   # Show dashboard with default settings"
    echo "  ./dashboard.sh --refresh 10      # Refresh every 10 seconds"
    echo "  ./dashboard.sh --compact         # Show compact view"
    echo "  ./dashboard.sh --export HTML     # Export dashboard to HTML file"
}

# Check dependencies
check_dependencies() {
    local missing_deps=0
    
    # Check for jq
    if ! command -v jq &> /dev/null; then
        print_warning "jq is not installed. Some features may not work properly."
        print_message "To install jq: sudo apt-get install jq"
        missing_deps=1
    fi
    
    # Check for watch (for refresh functionality)
    if ! command -v watch &> /dev/null; then
        print_warning "watch is not installed. Auto-refresh will not work."
        print_message "To install watch: sudo apt-get install procps"
        missing_deps=1
    fi
    
    return $missing_deps
}

# Function to get node status
get_node_status() {
    if pgrep -f "pipe-pop" > /dev/null; then
        local pid=$(pgrep -f "pipe-pop" | head -1)
        local uptime=$(ps -p "$pid" -o etime= 2>/dev/null || echo "unknown")
        
        # Get the start time of the process
        local start_time=$(ps -p "$pid" -o lstart= 2>/dev/null || echo "unknown")
        
        # Format uptime to be more readable
        local formatted_uptime=""
        if [[ "$uptime" == *-* ]]; then
            # Contains days
            local days=$(echo "$uptime" | cut -d'-' -f1)
            local rest=$(echo "$uptime" | cut -d'-' -f2)
            formatted_uptime="${days} days, ${rest}"
        else
            formatted_uptime="$uptime"
        fi
        
        echo -e "${GREEN}Running${NC} (PID: $pid)\nUptime: ${BOLD}${formatted_uptime}${NC}\nStarted: ${start_time}"
    else
        echo -e "${RED}Not running${NC}"
    fi
}

# Function to get system resources
get_system_resources() {
    # CPU usage
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
    cpu_usage=$(printf "%.1f" $cpu_usage)
    
    # RAM usage
    local total_ram=$(free -m | awk '/^Mem:/{print $2}')
    local used_ram=$(free -m | awk '/^Mem:/{print $3}')
    local ram_usage_percent=$((used_ram * 100 / total_ram))
    
    # Disk usage
    local disk_total=$(df -m . | awk 'NR==2 {print $2}')
    local disk_used=$(df -m . | awk 'NR==2 {print $3}')
    local disk_usage_percent=$((disk_used * 100 / disk_total))
    
    echo "CPU: ${cpu_usage}% | RAM: ${ram_usage_percent}% (${used_ram}/${total_ram} MB) | Disk: ${disk_usage_percent}% ($(($disk_used/1024))/$(($disk_total/1024)) GB)"
}

# Function to check port status
check_ports() {
    local result=""
    
    for port in 80 443 8003; do
        if netstat -tuln | grep ":${port} " > /dev/null; then
            result="${result}${port}: ${GREEN}✓${NC}  "
        else
            result="${result}${port}: ${RED}✗${NC}  "
        fi
    done
    
    echo -e "$result"
}

# Function to get node metrics
get_node_metrics() {
    # This would normally call the pipe-pop binary to get metrics
    # For now, we'll use sample data from the leaderboard file
    
    if [ -d "$HISTORY_DIR" ]; then
        # Get the latest leaderboard file
        local latest_file=$(ls -t "$HISTORY_DIR"/leaderboard_*.json 2>/dev/null | head -1)
        
        if [ -n "$latest_file" ]; then
            local reputation=$(jq -r '.your_node.reputation' "$latest_file" 2>/dev/null)
            local points=$(jq -r '.your_node.points' "$latest_file" 2>/dev/null)
            local egress=$(jq -r '.your_node.egress' "$latest_file" 2>/dev/null)
            local rank=$(jq -r '.your_node.rank' "$latest_file" 2>/dev/null)
            
            echo "Rank: $rank | Reputation: $reputation | Points: $points | Egress: $egress"
        else
            echo "No metrics data available. Run './pop --leaderboard' to collect data."
        fi
    else
        echo "History directory not found. Run './pop --leaderboard' to collect data."
    fi
}

# Function to get historical trends
get_historical_trends() {
    local result=""
    
    if [ -d "$HISTORY_DIR" ]; then
        # Get the two most recent leaderboard files
        local files=($(ls -t "$HISTORY_DIR"/leaderboard_*.json 2>/dev/null | head -2))
        
        if [ ${#files[@]} -ge 2 ]; then
            local current_file="${files[0]}"
            local previous_file="${files[1]}"
            
            # Get metrics from both files
            local current_reputation=$(jq -r '.your_node.reputation' "$current_file" 2>/dev/null)
            local previous_reputation=$(jq -r '.your_node.reputation' "$previous_file" 2>/dev/null)
            
            local current_points=$(jq -r '.your_node.points' "$current_file" 2>/dev/null)
            local previous_points=$(jq -r '.your_node.points' "$previous_file" 2>/dev/null)
            
            local current_egress=$(jq -r '.your_node.egress' "$current_file" 2>/dev/null | sed 's/ TB//')
            local previous_egress=$(jq -r '.your_node.egress' "$previous_file" 2>/dev/null | sed 's/ TB//')
            
            local current_rank=$(jq -r '.your_node.rank' "$current_file" 2>/dev/null)
            local previous_rank=$(jq -r '.your_node.rank' "$previous_file" 2>/dev/null)
            
            # Calculate trends
            if (( $(echo "$current_reputation > $previous_reputation" | bc -l) )); then
                result="${result}Reputation: ${GREEN}↑${NC} "
            elif (( $(echo "$current_reputation < $previous_reputation" | bc -l) )); then
                result="${result}Reputation: ${RED}↓${NC} "
            else
                result="${result}Reputation: ${YELLOW}→${NC} "
            fi
            
            if (( current_points > previous_points )); then
                result="${result}| Points: ${GREEN}↑${NC} (+$((current_points - previous_points))) "
            elif (( current_points < previous_points )); then
                result="${result}| Points: ${RED}↓${NC} ($((current_points - previous_points))) "
            else
                result="${result}| Points: ${YELLOW}→${NC} "
            fi
            
            if (( $(echo "$current_egress > $previous_egress" | bc -l) )); then
                local diff=$(echo "$current_egress - $previous_egress" | bc -l)
                result="${result}| Egress: ${GREEN}↑${NC} (+${diff} TB) "
            elif (( $(echo "$current_egress < $previous_egress" | bc -l) )); then
                local diff=$(echo "$previous_egress - $current_egress" | bc -l)
                result="${result}| Egress: ${RED}↓${NC} (-${diff} TB) "
            else
                result="${result}| Egress: ${YELLOW}→${NC} "
            fi
            
            if (( current_rank < previous_rank )); then
                result="${result}| Rank: ${GREEN}↑${NC} (+$((previous_rank - current_rank))) "
            elif (( current_rank > previous_rank )); then
                result="${result}| Rank: ${RED}↓${NC} (-$((current_rank - previous_rank))) "
            else
                result="${result}| Rank: ${YELLOW}→${NC} "
            fi
            
            echo -e "$result"
        else
            echo "Not enough historical data. Run './pop --leaderboard' multiple times to collect data."
        fi
    else
        echo "History directory not found. Run './pop --leaderboard' to collect data."
    fi
}

# Function to display the dashboard
display_dashboard() {
    local view_mode="$1"
    
    clear
    echo "╔═════════════════════════════════════════════════════════════════════════╗"
    echo "║                    PIPE NETWORK POP NODE DASHBOARD                      ║"
    echo "╚═════════════════════════════════════════════════════════════════════════╝"
    echo "  Time: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "  Node ID: $(jq -r '.node_id' "$PIPE_DIR/node_info.json" 2>/dev/null || echo "Unknown")"
    echo "╔═════════════════════════════════════════════════════════════════════════╗"
    echo "║ STATUS                                                                  ║"
    echo "╚═════════════════════════════════════════════════════════════════════════╝"
    echo -e "  Status: $(get_node_status)"
    echo "  Resources: $(get_system_resources)"
    echo "  Ports: $(check_ports)"
    
    echo "╔═════════════════════════════════════════════════════════════════════════╗"
    echo "║ PERFORMANCE METRICS                                                     ║"
    echo "╚═════════════════════════════════════════════════════════════════════════╝"
    echo "  $(get_node_metrics)"
    
    if [ "$view_mode" != "compact" ] && [ "$view_mode" != "no-history" ]; then
        echo "╔═════════════════════════════════════════════════════════════════════════╗"
        echo "║ HISTORICAL TRENDS                                                       ║"
        echo "╚═════════════════════════════════════════════════════════════════════════╝"
        echo "  $(get_historical_trends)"
    fi
    
    if [ "$view_mode" = "full" ]; then
        echo "╔═════════════════════════════════════════════════════════════════════════╗"
        echo "║ ACTIONS                                                                 ║"
        echo "╚═════════════════════════════════════════════════════════════════════════╝"
        echo "  - View detailed metrics: ./pop --pulse"
        echo "  - View leaderboard: ./pop --leaderboard"
        echo "  - View historical data: ./history_view.sh --help"
        echo "  - Restart node: ./pop --restart"
    fi
    
    echo ""
    echo "Press Ctrl+C to exit"
}

# Function to export dashboard to HTML
export_to_html() {
    local html_file="pipe_network_dashboard_$(date '+%Y%m%d_%H%M%S').html"
    
    # Create HTML file
    cat > "$html_file" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pipe Network PoP Node Dashboard</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            background-color: #f5f5f5;
        }
        .dashboard {
            max-width: 900px;
            margin: 0 auto;
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            padding: 20px;
        }
        .header {
            text-align: center;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 1px solid #eee;
        }
        .section {
            margin-bottom: 20px;
            padding: 15px;
            border-radius: 5px;
            background-color: #f9f9f9;
        }
        .section-title {
            font-size: 18px;
            font-weight: bold;
            margin-bottom: 10px;
            color: #333;
        }
        .metric {
            margin: 5px 0;
        }
        .status-running {
            color: green;
            font-weight: bold;
        }
        .status-stopped {
            color: red;
            font-weight: bold;
        }
        .trend-up {
            color: green;
        }
        .trend-down {
            color: red;
        }
        .trend-same {
            color: orange;
        }
        .footer {
            text-align: center;
            font-size: 12px;
            color: #777;
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <div class="dashboard">
        <div class="header">
            <h1>Pipe Network PoP Node Dashboard</h1>
            <p>Generated on $(date '+%Y-%m-%d %H:%M:%S')</p>
            <p>Node ID: $(jq -r '.node_id' "$PIPE_DIR/node_info.json" 2>/dev/null || echo "Unknown")</p>
        </div>
        
        <div class="section">
            <div class="section-title">Status</div>
EOF
    
    # Add node status
    if pgrep -f "pipe-pop" > /dev/null; then
        local pid=$(pgrep -f "pipe-pop" | head -1)
        local uptime=$(ps -p "$pid" -o etime= 2>/dev/null || echo "unknown")
        local start_time=$(ps -p "$pid" -o lstart= 2>/dev/null || echo "unknown")
        
        # Format uptime to be more readable
        local formatted_uptime=""
        if [[ "$uptime" == *-* ]]; then
            # Contains days
            local days=$(echo "$uptime" | cut -d'-' -f1)
            local rest=$(echo "$uptime" | cut -d'-' -f2)
            formatted_uptime="${days} days, ${rest}"
        else
            formatted_uptime="$uptime"
        fi
        
        echo "<div class='metric'>Status: <span class='status-running'>Running</span> (PID: $pid)</div>" >> "$html_file"
        echo "<div class='metric'>Uptime: <strong>${formatted_uptime}</strong></div>" >> "$html_file"
        echo "<div class='metric'>Started: ${start_time}</div>" >> "$html_file"
    else
        echo "<div class='metric'>Status: <span class='status-stopped'>Not running</span></div>" >> "$html_file"
    fi
    
    # Add system resources
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
    cpu_usage=$(printf "%.1f" $cpu_usage)
    
    local total_ram=$(free -m | awk '/^Mem:/{print $2}')
    local used_ram=$(free -m | awk '/^Mem:/{print $3}')
    local ram_usage_percent=$((used_ram * 100 / total_ram))
    
    local disk_total=$(df -m . | awk 'NR==2 {print $2}')
    local disk_used=$(df -m . | awk 'NR==2 {print $3}')
    local disk_usage_percent=$((disk_used * 100 / disk_total))
    
    echo "<div class='metric'>CPU Usage: ${cpu_usage}%</div>" >> "$html_file"
    echo "<div class='metric'>RAM Usage: ${ram_usage_percent}% (${used_ram}/${total_ram} MB)</div>" >> "$html_file"
    echo "<div class='metric'>Disk Usage: ${disk_usage_percent}% ($(($disk_used/1024))/$(($disk_total/1024)) GB)</div>" >> "$html_file"
    
    # Add port status
    echo "<div class='metric'>Ports: " >> "$html_file"
    for port in 80 443 8003; do
        if netstat -tuln | grep ":${port} " > /dev/null; then
            echo "Port ${port}: <span class='status-running'>Open</span> " >> "$html_file"
        else
            echo "Port ${port}: <span class='status-stopped'>Closed</span> " >> "$html_file"
        fi
    done
    echo "</div>" >> "$html_file"
    
    # Add performance metrics
    echo "</div><div class='section'><div class='section-title'>Performance Metrics</div>" >> "$html_file"
    
    if [ -d "$HISTORY_DIR" ]; then
        local latest_file=$(ls -t "$HISTORY_DIR"/leaderboard_*.json 2>/dev/null | head -1)
        
        if [ -n "$latest_file" ]; then
            local reputation=$(jq -r '.your_node.reputation' "$latest_file" 2>/dev/null)
            local points=$(jq -r '.your_node.points' "$latest_file" 2>/dev/null)
            local egress=$(jq -r '.your_node.egress' "$latest_file" 2>/dev/null)
            local rank=$(jq -r '.your_node.rank' "$latest_file" 2>/dev/null)
            
            echo "<div class='metric'>Rank: $rank</div>" >> "$html_file"
            echo "<div class='metric'>Reputation: $reputation</div>" >> "$html_file"
            echo "<div class='metric'>Points: $points</div>" >> "$html_file"
            echo "<div class='metric'>Egress: $egress</div>" >> "$html_file"
        else
            echo "<div class='metric'>No metrics data available.</div>" >> "$html_file"
        fi
    else
        echo "<div class='metric'>History directory not found.</div>" >> "$html_file"
    fi
    
    # Add historical trends
    echo "</div><div class='section'><div class='section-title'>Historical Trends</div>" >> "$html_file"
    
    if [ -d "$HISTORY_DIR" ]; then
        local files=($(ls -t "$HISTORY_DIR"/leaderboard_*.json 2>/dev/null | head -2))
        
        if [ ${#files[@]} -ge 2 ]; then
            local current_file="${files[0]}"
            local previous_file="${files[1]}"
            
            local current_reputation=$(jq -r '.your_node.reputation' "$current_file" 2>/dev/null)
            local previous_reputation=$(jq -r '.your_node.reputation' "$previous_file" 2>/dev/null)
            
            local current_points=$(jq -r '.your_node.points' "$current_file" 2>/dev/null)
            local previous_points=$(jq -r '.your_node.points' "$previous_file" 2>/dev/null)
            
            local current_egress=$(jq -r '.your_node.egress' "$current_file" 2>/dev/null | sed 's/ TB//')
            local previous_egress=$(jq -r '.your_node.egress' "$previous_file" 2>/dev/null | sed 's/ TB//')
            
            local current_rank=$(jq -r '.your_node.rank' "$current_file" 2>/dev/null)
            local previous_rank=$(jq -r '.your_node.rank' "$previous_file" 2>/dev/null)
            
            # Calculate trends
            if (( $(echo "$current_reputation > $previous_reputation" | bc -l) )); then
                echo "<div class='metric'>Reputation: <span class='trend-up'>↑ Increased</span> (from $previous_reputation to $current_reputation)</div>" >> "$html_file"
            elif (( $(echo "$current_reputation < $previous_reputation" | bc -l) )); then
                echo "<div class='metric'>Reputation: <span class='trend-down'>↓ Decreased</span> (from $previous_reputation to $current_reputation)</div>" >> "$html_file"
            else
                echo "<div class='metric'>Reputation: <span class='trend-same'>→ Unchanged</span> ($current_reputation)</div>" >> "$html_file"
            fi
            
            if (( current_points > previous_points )); then
                echo "<div class='metric'>Points: <span class='trend-up'>↑ Increased</span> (from $previous_points to $current_points, +$((current_points - previous_points)))</div>" >> "$html_file"
            elif (( current_points < previous_points )); then
                echo "<div class='metric'>Points: <span class='trend-down'>↓ Decreased</span> (from $previous_points to $current_points, $((current_points - previous_points)))</div>" >> "$html_file"
            else
                echo "<div class='metric'>Points: <span class='trend-same'>→ Unchanged</span> ($current_points)</div>" >> "$html_file"
            fi
            
            if (( $(echo "$current_egress > $previous_egress" | bc -l) )); then
                local diff=$(echo "$current_egress - $previous_egress" | bc -l)
                echo "<div class='metric'>Egress: <span class='trend-up'>↑ Increased</span> (from $previous_egress TB to $current_egress TB, +${diff} TB)</div>" >> "$html_file"
            elif (( $(echo "$current_egress < $previous_egress" | bc -l) )); then
                local diff=$(echo "$previous_egress - $current_egress" | bc -l)
                echo "<div class='metric'>Egress: <span class='trend-down'>↓ Decreased</span> (from $previous_egress TB to $current_egress TB, -${diff} TB)</div>" >> "$html_file"
            else
                echo "<div class='metric'>Egress: <span class='trend-same'>→ Unchanged</span> ($current_egress TB)</div>" >> "$html_file"
            fi
            
            if (( current_rank < previous_rank )); then
                echo "<div class='metric'>Rank: <span class='trend-up'>↑ Improved</span> (from $previous_rank to $current_rank, +$((previous_rank - current_rank)) positions)</div>" >> "$html_file"
            elif (( current_rank > previous_rank )); then
                echo "<div class='metric'>Rank: <span class='trend-down'>↓ Declined</span> (from $previous_rank to $current_rank, -$((current_rank - previous_rank)) positions)</div>" >> "$html_file"
            else
                echo "<div class='metric'>Rank: <span class='trend-same'>→ Unchanged</span> ($current_rank)</div>" >> "$html_file"
            fi
        else
            echo "<div class='metric'>Not enough historical data available.</div>" >> "$html_file"
        fi
    else
        echo "<div class='metric'>History directory not found.</div>" >> "$html_file"
    fi
    
    # Close HTML file
    cat >> "$html_file" << EOF
        </div>
        
        <div class="footer">
            <p>Pipe Network PoP Node Dashboard | Generated by dashboard.sh</p>
        </div>
    </div>
</body>
</html>
EOF
    
    print_message "Dashboard exported to $html_file"
}

# Main function
main() {
    local refresh_interval=5
    local view_mode="full"
    local export_format=""
    
    # Process command line arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --refresh)
                if [[ "$2" =~ ^[0-9]+$ ]]; then
                    refresh_interval="$2"
                    shift 2
                else
                    print_error "Invalid refresh interval: $2"
                    exit 1
                fi
                ;;
            --compact)
                view_mode="compact"
                shift
                ;;
            --full)
                view_mode="full"
                shift
                ;;
            --no-history)
                view_mode="no-history"
                shift
                ;;
            --export)
                export_format="$2"
                shift 2
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
    
    # Export dashboard if requested
    if [ "$export_format" = "HTML" ] || [ "$export_format" = "html" ]; then
        export_to_html
        exit 0
    fi
    
    # Display dashboard with auto-refresh
    if command -v watch &> /dev/null; then
        watch -n "$refresh_interval" -c "bash -c 'source \"$0\"; display_dashboard \"$view_mode\"'"
    else
        while true; do
            display_dashboard "$view_mode"
            sleep "$refresh_interval"
            clear
        done
    fi
}

# Run the main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 