#!/bin/bash
# Dashboard Module for Pipe Network PoP Node Management Tools
# This module provides an interactive terminal-based dashboard for monitoring

# =====================
# Dashboard Configuration
# =====================

# Default refresh rate in seconds
DEFAULT_REFRESH_RATE=5

# Default dashboard layout (available: full, compact, minimal)
DEFAULT_LAYOUT="full"

# Default interactive mode
DEFAULT_INTERACTIVE=false

# =====================
# Terminal UI Functions
# =====================

# Clear the screen and reset cursor
clear_screen() {
  clear
}

# Set cursor position
set_cursor() {
  local row=$1
  local col=$2
  echo -ne "\033[${row};${col}H"
}

# Get terminal dimensions
get_terminal_size() {
  # Check if stty is available
  if command -v stty &> /dev/null; then
    TERM_ROWS=$(stty size | cut -d ' ' -f 1)
    TERM_COLS=$(stty size | cut -d ' ' -f 2)
  else
    # Default fallback values
    TERM_ROWS=24
    TERM_COLS=80
  fi
  
  export TERM_ROWS
  export TERM_COLS
}

# Draw a horizontal line
draw_line() {
  local length=${1:-$TERM_COLS}
  printf "%${length}s" | tr ' ' '─'
}

# Draw a box
draw_box() {
  local top_row=$1
  local left_col=$2
  local width=$3
  local height=$4
  local title=$5
  
  # Draw top border
  set_cursor $top_row $left_col
  echo -n "┌"
  if [[ -n "$title" ]]; then
    local title_space=$(( width - ${#title} - 2 ))
    local left_fill=$(( title_space / 2 ))
    local right_fill=$(( title_space - left_fill ))
    printf "%${left_fill}s" | tr ' ' '─'
    echo -n " $title "
    printf "%${right_fill}s" | tr ' ' '─'
  else
    printf "%$(( width - 2 ))s" | tr ' ' '─'
  fi
  echo -n "┐"
  
  # Draw sides
  for (( i=1; i<height-1; i++ )); do
    set_cursor $(( top_row + i )) $left_col
    echo -n "│"
    set_cursor $(( top_row + i )) $(( left_col + width - 1 ))
    echo -n "│"
  done
  
  # Draw bottom border
  set_cursor $(( top_row + height - 1 )) $left_col
  echo -n "└"
  printf "%$(( width - 2 ))s" | tr ' ' '─'
  echo -n "┘"
}

# Create a progress bar
draw_progress_bar() {
  local value=$1          # Value (0-100)
  local max_length=$2     # Maximum length of the bar
  local row=$3            # Row position
  local col=$4            # Column position
  local title="$5"        # Optional title
  
  # Set to 0 if not a number
  if ! [[ "$value" =~ ^[0-9]+$ ]]; then
    value=0
  fi
  
  # Ensure value is in range 0-100
  if (( value < 0 )); then value=0; fi
  if (( value > 100 )); then value=100; fi
  
  # Calculate filled and empty portions
  local filled_length=$(( max_length * value / 100 ))
  local empty_length=$(( max_length - filled_length ))
  
  # Display title if provided
  if [[ -n "$title" ]]; then
    set_cursor $row $col
    echo -n "$title"
    col=$(( col + ${#title} + 1 ))
  fi
  
  # Draw the bar
  set_cursor $row $col
  echo -n "["
  
  # Choose color based on value
  local color=""
  if (( value < 30 )); then
    color=$RED
  elif (( value < 70 )); then
    color=$YELLOW
  else
    color=$GREEN
  fi
  
  # Draw filled portion
  echo -ne "${color}"
  if (( filled_length > 0 )); then
    printf "%${filled_length}s" | tr ' ' '█'
  fi
  echo -ne "${NC}"
  
  # Draw empty portion
  if (( empty_length > 0 )); then
    printf "%${empty_length}s" | tr ' ' '░'
  fi
  
  echo -n "] ${value}%"
}

# =====================
# Dashboard Layouts
# =====================

# Full dashboard layout
draw_full_dashboard() {
  local refresh_rate=$1
  local metrics_file=$2
  
  clear_screen
  get_terminal_size
  
  # Print header
  print_header "DASHBOARD"
  
  # Get basic node status
  local status=$(get_node_status)
  local uptime=$(get_node_uptime)
  local uptime_formatted=$(printf '%dd %dh %dm %ds' $(($uptime/86400)) $(($uptime%86400/3600)) $(($uptime%3600/60)) $(($uptime%60)))
  local wallet=$(get_wallet_address)
  local registered=$(check_registration)
  
  # Current time
  echo -e "${CYAN}Last update:${NC} $(date '+%Y-%m-%d %H:%M:%S')"
  echo -e "${CYAN}Refresh rate:${NC} ${refresh_rate}s"
  
  # Node status
  echo
  if [[ "$status" == "running" ]]; then
    echo -e "Status: ${GREEN}Running${NC}"
    echo -e "Uptime: $uptime_formatted"
  else
    echo -e "Status: ${RED}Not Running${NC}"
    echo -e "${YELLOW}Use 'pop start' to start the node.${NC}"
    
    # If node is not running, we can't display the dashboard
    echo
    echo -e "Cannot display dashboard when node is not running."
    return 1
  fi
  
  # Registration and wallet info
  echo
  if [[ "$registered" == "yes" ]]; then
    echo -e "Registered: ${GREEN}Yes${NC}"
  else
    echo -e "Registered: ${RED}No${NC}"
  fi
  
  if [[ -n "$wallet" && "$wallet" != "No wallet configured" ]]; then
    echo -e "Wallet: $wallet"
  else
    echo -e "Wallet: ${RED}Not configured${NC}"
  fi
  
  # Ports section
  echo
  echo -e "${CYAN}Ports:${NC}"
  local port_80=$(check_port 80)
  local port_443=$(check_port 443)
  local port_8003=$(check_port 8003)
  echo -e "  HTTP (80):   $port_80"
  echo -e "  HTTPS (443): $port_443"
  echo -e "  MGMT (8003): $port_8003"
  
  # Performance metrics
  echo
  echo -e "${CYAN}Performance Metrics:${NC}"
  
  # If metrics file exists
  if [[ -f "$metrics_file" ]] && command -v jq &> /dev/null; then
    # Get data from metrics file
    local reputation=$(jq -r '.reputation // 0' "$metrics_file" 2>/dev/null)
    local points=$(jq -r '.points // 0' "$metrics_file" 2>/dev/null)
    local egress=$(jq -r '.egress // "0 B"' "$metrics_file" 2>/dev/null)
    local uptime_score=$(jq -r '.uptime_score // "0%"' "$metrics_file" 2>/dev/null)
    local historical_score=$(jq -r '.historical_score // "0%"' "$metrics_file" 2>/dev/null)
    local egress_score=$(jq -r '.egress_score // "0%"' "$metrics_file" 2>/dev/null)
    
    # Remove % sign for calculations
    local uptime_score_num=${uptime_score/\%/}
    local historical_score_num=${historical_score/\%/}
    local egress_score_num=${egress_score/\%/}
    
    # Calculate overall score (weighted)
    local overall_score=$(( (uptime_score_num * 40 + historical_score_num * 30 + egress_score_num * 30) / 100 ))
    
    # Display metrics
    echo -e "  Reputation: ${CYAN}$reputation${NC}"
    echo -e "  Points: ${CYAN}$points${NC}"
    echo -e "  Egress: ${CYAN}$egress${NC}"
    echo
    
    # Display score components
    echo -e "${CYAN}Score Components:${NC}"
    echo -e "  Uptime Score (40%): ${CYAN}$uptime_score${NC}"
    echo -e "  Historical Score (30%): ${CYAN}$historical_score${NC}"
    echo -e "  Egress Score (30%): ${CYAN}$egress_score${NC}"
    echo -e "  Overall Score: ${CYAN}${overall_score}%${NC}"
    
    # Show node ID if available
    local node_id=$(jq -r '.node_id // ""' "$metrics_file")
    if [[ -n "$node_id" ]]; then
      echo
      echo -e "Node ID: ${BLUE}$node_id${NC}"
    fi
  else
    echo -e "  ${YELLOW}No metrics data available. Run 'pop pulse' to generate metrics.${NC}"
  fi
  
  # System resource usage
  echo
  echo -e "${CYAN}System Resources:${NC}"
  
  # CPU usage
  local cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
  cpu_usage=${cpu_usage%.*} # Remove decimal part
  echo -e "  CPU Usage: ${CYAN}${cpu_usage}%${NC}"
  
  # Memory usage
  local mem_info=$(free -m | grep Mem)
  local mem_total=$(echo "$mem_info" | awk '{print $2}')
  local mem_used=$(echo "$mem_info" | awk '{print $3}')
  local mem_percent=$(( mem_used * 100 / mem_total ))
  echo -e "  Memory Usage: ${CYAN}${mem_percent}% (${mem_used}MB / ${mem_total}MB)${NC}"
  
  # Disk usage
  local disk_info=$(df -h . | grep -v Filesystem)
  local disk_size=$(echo "$disk_info" | awk '{print $2}')
  local disk_used=$(echo "$disk_info" | awk '{print $3}')
  local disk_percent=$(echo "$disk_info" | awk '{print $5}' | sed 's/%//')
  echo -e "  Disk Usage: ${CYAN}${disk_percent}% (${disk_used} / ${disk_size})${NC}"
  
  # Help information
  echo
  if [[ "$DEFAULT_INTERACTIVE" == "true" ]]; then
    echo -e "${YELLOW}Interactive mode:${NC} Press 'q' to quit, 'r' to refresh, 'h' for help"
  else
    echo -e "${YELLOW}Press Ctrl+C to exit${NC}"
  fi
  
  return 0
}

# Compact dashboard layout
draw_compact_dashboard() {
  local refresh_rate=$1
  local metrics_file=$2
  
  clear_screen
  get_terminal_size
  
  # Print header
  echo -e "${CYAN}=== PIPE NETWORK NODE DASHBOARD (COMPACT) ===${NC}"
  echo -e "${CYAN}Updated:${NC} $(date '+%H:%M:%S') | ${CYAN}Refresh:${NC} ${refresh_rate}s"
  
  # Get basic node status
  local status=$(get_node_status)
  local uptime=$(get_node_uptime)
  local uptime_formatted=$(printf '%dd %dh %dm' $(($uptime/86400)) $(($uptime%86400/3600)) $(($uptime%3600/60)))
  
  # Node status line
  if [[ "$status" == "running" ]]; then
    echo -e "Status: ${GREEN}Running${NC} | Uptime: $uptime_formatted"
  else
    echo -e "Status: ${RED}Not Running${NC}"
    return 1
  fi
  
  # Ports status
  local port_80=$(check_port 80)
  local port_443=$(check_port 443)
  local port_8003=$(check_port 8003)
  
  # Extract just the color-coded status without "Listening"
  port_80=${port_80//Listening/✓}
  port_443=${port_443//Listening/✓}
  port_8003=${port_8003//Listening/✓}
  port_80=${port_80//Not Listening/✗}
  port_443=${port_443//Not Listening/✗}
  port_8003=${port_8003//Not Listening/✗}
  
  echo -e "Ports: 80:$port_80 | 443:$port_443 | 8003:$port_8003"
  
  # Metrics line
  if [[ -f "$metrics_file" ]] && command -v jq &> /dev/null; then
    local reputation=$(jq -r '.reputation // 0' "$metrics_file" 2>/dev/null)
    local points=$(jq -r '.points // 0' "$metrics_file" 2>/dev/null)
    local egress=$(jq -r '.egress // "0 B"' "$metrics_file" 2>/dev/null)
    
    echo -e "Rep: ${CYAN}$reputation${NC} | Points: ${CYAN}$points${NC} | Egress: ${CYAN}$egress${NC}"
    
    # Extract scores
    local uptime_score=$(jq -r '.uptime_score // "0%"' "$metrics_file" 2>/dev/null)
    local historical_score=$(jq -r '.historical_score // "0%"' "$metrics_file" 2>/dev/null)
    local egress_score=$(jq -r '.egress_score // "0%"' "$metrics_file" 2>/dev/null)
    
    echo -e "Scores: Uptime: ${CYAN}$uptime_score${NC} | Historical: ${CYAN}$historical_score${NC} | Egress: ${CYAN}$egress_score${NC}"
  else
    echo -e "${YELLOW}No metrics data available${NC}"
  fi
  
  # Resource usage (one line)
  local cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
  cpu_usage=${cpu_usage%.*}
  local mem_info=$(free -m | grep Mem)
  local mem_percent=$(( $(echo "$mem_info" | awk '{print $3}') * 100 / $(echo "$mem_info" | awk '{print $2}') ))
  local disk_percent=$(df -h . | grep -v Filesystem | awk '{print $5}' | sed 's/%//')
  
  echo -e "System: CPU: ${CYAN}${cpu_usage}%${NC} | Mem: ${CYAN}${mem_percent}%${NC} | Disk: ${CYAN}${disk_percent}%${NC}"
  
  return 0
}

# Minimal dashboard layout (single line)
draw_minimal_dashboard() {
  local refresh_rate=$1
  local metrics_file=$2
  
  clear_screen
  get_terminal_size
  
  # Gather data
  local status=$(get_node_status)
  
  # Basic status icons
  local status_icon="${RED}■${NC}"
  if [[ "$status" == "running" ]]; then
    status_icon="${GREEN}■${NC}"
    
    # If node is running, get additional metrics
    local uptime=$(get_node_uptime)
    local uptime_hours=$(( uptime / 3600 ))
    
    # Get port status (simplified)
    local ports_ok=0
    local total_ports=3
    if netstat -tuln | grep -q ":80 "; then ((ports_ok++)); fi
    if netstat -tuln | grep -q ":443 "; then ((ports_ok++)); fi
    if netstat -tuln | grep -q ":8003 "; then ((ports_ok++)); fi
    
    # Get system metrics
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    cpu_usage=${cpu_usage%.*}
    local mem_info=$(free -m | grep Mem)
    local mem_percent=$(( $(echo "$mem_info" | awk '{print $3}') * 100 / $(echo "$mem_info" | awk '{print $2}') ))
    
    # Get node metrics if available
    local reputation="--"
    local points="--"
    
    if [[ -f "$metrics_file" ]] && command -v jq &> /dev/null; then
      reputation=$(jq -r '.reputation // "--"' "$metrics_file" 2>/dev/null)
      points=$(jq -r '.points // "--"' "$metrics_file" 2>/dev/null)
    fi
    
    # Print one-line summary
    echo -e "$status_icon Pipe Node: Up ${uptime_hours}h | Ports: ${ports_ok}/${total_ports} | Rep: ${CYAN}${reputation}${NC} | Points: ${CYAN}${points}${NC} | CPU: ${CYAN}${cpu_usage}%${NC} | Mem: ${CYAN}${mem_percent}%${NC}"
  else
    # Node not running
    echo -e "$status_icon Pipe Node: ${RED}Down${NC} | Run 'pop start' to start the node"
  fi
  
  return 0
}

# =====================
# Interactive Mode
# =====================

# Process keyboard input in interactive mode
process_key() {
  local key=$1
  local result=0
  
  case "$key" in
    q|Q)
      # Quit
      result=1
      ;;
    r|R)
      # Refresh (do nothing, the loop will refresh)
      ;;
    h|H)
      # Show help
      show_dashboard_help
      # Wait for any key
      read -n 1 -s -r -p "Press any key to continue..."
      ;;
    1)
      # Full layout
      LAYOUT="full"
      ;;
    2)
      # Compact layout
      LAYOUT="compact"
      ;;
    3)
      # Minimal layout
      LAYOUT="minimal"
      ;;
    *)
      # Ignore other keys
      ;;
  esac
  
  return $result
}

# Show help for interactive mode
show_dashboard_help() {
  clear_screen
  print_header "DASHBOARD HELP"
  
  echo -e "Interactive Dashboard Controls:"
  echo -e "  ${CYAN}q${NC}              Exit dashboard"
  echo -e "  ${CYAN}r${NC}              Refresh data now"
  echo -e "  ${CYAN}h${NC}              Show this help screen"
  echo
  echo -e "Display Layouts:"
  echo -e "  ${CYAN}1${NC}              Full dashboard (detailed view)"
  echo -e "  ${CYAN}2${NC}              Compact dashboard"
  echo -e "  ${CYAN}3${NC}              Minimal dashboard (single line)"
  echo
  echo -e "Command Line Options:"
  echo -e "  ${CYAN}--refresh=N${NC}    Set refresh interval to N seconds"
  echo -e "  ${CYAN}--layout=TYPE${NC}  Set layout (full, compact, minimal)"
  echo -e "  ${CYAN}--no-interactive${NC} Disable interactive mode"
  echo
  echo -e "Examples:"
  echo -e "  ${CYAN}pop dashboard${NC}                     Run with default settings"
  echo -e "  ${CYAN}pop dashboard --layout=compact${NC}    Use compact layout"
  echo -e "  ${CYAN}pop dashboard --refresh=10${NC}        Refresh every 10 seconds"
  echo
}

# =====================
# Main Dashboard Function
# =====================

# Run the dashboard with the given options
run_dashboard() {
  local refresh_rate=$DEFAULT_REFRESH_RATE
  local layout=$DEFAULT_LAYOUT
  local interactive=$DEFAULT_INTERACTIVE
  
  # Parse options
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --refresh=*)
        refresh_rate="${1#*=}"
        shift
        ;;
      --refresh)
        if [[ -n "$2" && "$2" =~ ^[0-9]+$ ]]; then
          refresh_rate="$2"
          shift 2
        else
          log_error "Invalid or missing value for --refresh"
          return 1
        fi
        ;;
      --layout=*)
        layout="${1#*=}"
        shift
        ;;
      --layout)
        if [[ -n "$2" ]]; then
          layout="$2"
          shift 2
        else
          log_error "Invalid or missing value for --layout"
          return 1
        fi
        ;;
      --interactive)
        interactive=true
        shift
        ;;
      --no-interactive)
        interactive=false
        shift
        ;;
      --help)
        show_dashboard_help
        return 0
        ;;
      *)
        shift
        ;;
    esac
  done
  
  # Validate refresh rate
  if ! [[ "$refresh_rate" =~ ^[0-9]+$ ]]; then
    log_error "Invalid refresh rate: $refresh_rate"
    return 1
  fi
  
  # Validate layout
  case "$layout" in
    full|compact|minimal)
      # Valid layout
      ;;
    *)
      log_error "Invalid layout: $layout"
      log_error "Available layouts: full, compact, minimal"
      return 1
      ;;
  esac
  
  # Metrics file path
  local metrics_file="${METRICS_DIR}/current.json"
  
  # Make sure metrics file directory exists
  ensure_metrics_dir
  
  # Collect initial metrics
  collect_metrics
  
  # Hide cursor
  echo -ne "\033[?25l"
  
  # Trap for clean exit
  trap 'echo -ne "\033[?25h"; clear_screen' EXIT
  
  # Interactive mode
  if [[ "$interactive" == "true" ]]; then
    # Configure terminal for non-blocking input
    saved_tty_settings=$(stty -g)
    stty -echo -icanon min 0 time 0
    
    # Main dashboard loop
    local should_exit=0
    while (( should_exit == 0 )); do
      # Update timestamp and collect metrics
      collect_metrics
      
      # Draw the appropriate dashboard
      case "$layout" in
        full)
          draw_full_dashboard "$refresh_rate" "$metrics_file"
          ;;
        compact)
          draw_compact_dashboard "$refresh_rate" "$metrics_file"
          ;;
        minimal)
          draw_minimal_dashboard "$refresh_rate" "$metrics_file"
          ;;
      esac
      
      # Wait for input or timeout (0.1 second checks)
      local waited=0
      while (( waited < refresh_rate * 10 )); do
        local key=$(dd bs=1 count=1 2>/dev/null | od -An -tx1 | tr -d ' ')
        if [[ -n "$key" ]]; then
          # Process the key
          process_key "$key"
          should_exit=$?
        fi
        
        # Break loop if exit requested
        if (( should_exit > 0 )); then
          break
        fi
        
        # Wait a tenth of a second
        sleep 0.1
        (( waited++ ))
      done
    done
    
    # Restore terminal settings
    stty "$saved_tty_settings"
  else
    # Non-interactive mode - just refresh continuously
    while true; do
      # Update timestamp and collect metrics
      collect_metrics
      
      # Draw the appropriate dashboard
      case "$layout" in
        full)
          draw_full_dashboard "$refresh_rate" "$metrics_file"
          ;;
        compact)
          draw_compact_dashboard "$refresh_rate" "$metrics_file"
          ;;
        minimal)
          draw_minimal_dashboard "$refresh_rate" "$metrics_file"
          ;;
      esac
      
      # Wait for refresh
      sleep "$refresh_rate"
    done
  fi
  
  # Show cursor again
  echo -ne "\033[?25h"
  
  return 0
}
