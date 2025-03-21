#!/bin/bash
# History Module for Pipe Network PoP Node Management Tools
# This module handles historical data storage, retrieval, and visualization

# =====================
# History Configuration
# =====================

# Default history periods
DEFAULT_PERIOD="7d"  # Default period to display (7 days)
AVAILABLE_PERIODS=("1d" "3d" "7d" "14d" "30d" "90d" "all")

# Chart rendering configuration
CHART_WIDTH=50       # Default width of charts
CHART_MAX_POINTS=100 # Maximum number of points to plot

# =====================
# History File Management
# =====================

# Get path to history directory
get_history_dir() {
  if [[ -z "$HISTORY_DIR" ]]; then
    if [[ -z "$METRICS_DIR" ]]; then
      METRICS_DIR="${INSTALL_DIR}/metrics"
    fi
    HISTORY_DIR="${METRICS_DIR}/history"
  fi
  
  echo "$HISTORY_DIR"
}

# Ensure history directory exists
ensure_history_dir() {
  local dir=$(get_history_dir)
  
  if [[ ! -d "$dir" ]]; then
    log_debug "Creating history directory: $dir"
    sudo mkdir -p "$dir"
    sudo chmod 755 "$dir"
  fi
}

# List all history files
list_history_files() {
  local dir=$(get_history_dir)
  local sort_order="$1"
  
  if [[ ! -d "$dir" ]]; then
    log_error "History directory does not exist: $dir"
    return 1
  fi
  
  # List files, optionally sort (oldest or newest first)
  if [[ "$sort_order" == "oldest" ]]; then
    find "$dir" -name "metrics_*.json" -type f | sort
  else
    # Default to newest first
    find "$dir" -name "metrics_*.json" -type f | sort -r
  fi
}

# Get history files within a specified period
get_history_files_for_period() {
  local period="$1"
  local now=$(date +%s)
  local cutoff=0
  
  # Calculate cutoff time based on period
  case "$period" in
    "1d") cutoff=$((now - 86400)) ;;       # 1 day
    "3d") cutoff=$((now - 259200)) ;;      # 3 days
    "7d") cutoff=$((now - 604800)) ;;      # 7 days
    "14d") cutoff=$((now - 1209600)) ;;    # 14 days
    "30d") cutoff=$((now - 2592000)) ;;    # 30 days
    "90d") cutoff=$((now - 7776000)) ;;    # 90 days
    "all") cutoff=0 ;;                     # All data
    *) 
      log_error "Invalid period: $period"
      return 1
      ;;
  esac
  
  # Get all history files
  local files=$(list_history_files "oldest")
  
  # Filter files by timestamp
  for file in $files; do
    local filename=$(basename "$file")
    # Extract timestamp from filename (format: metrics_YYYYMMDD_HHMMSS.json)
    if [[ "$filename" =~ metrics_([0-9]{8})_([0-9]{6})\.json ]]; then
      local date_part="${BASH_REMATCH[1]}"
      local time_part="${BASH_REMATCH[2]}"
      
      # Convert to timestamp
      local year="${date_part:0:4}"
      local month="${date_part:4:2}"
      local day="${date_part:6:2}"
      local hour="${time_part:0:2}"
      local minute="${time_part:2:2}"
      local second="${time_part:4:2}"
      
      local file_timestamp=$(date -d "$year-$month-$day $hour:$minute:$second" +%s 2>/dev/null)
      
      # Include file if newer than cutoff
      if [[ -n "$file_timestamp" && $file_timestamp -ge $cutoff ]]; then
        echo "$file"
      fi
    fi
  done
}

# Extract metric value from history file
extract_metric() {
  local file="$1"
  local metric="$2"
  local default_value="$3"
  
  if [[ ! -f "$file" ]]; then
    echo "$default_value"
    return 1
  fi
  
  # Extract value using jq if available
  if command -v jq &> /dev/null; then
    local value=$(jq -r ".$metric // \"$default_value\"" "$file" 2>/dev/null)
    # Handle percentages
    if [[ "$value" == *"%" ]]; then
      value="${value%\%}"
    fi
    echo "$value"
  else
    echo "$default_value"
  fi
}

# Extract timestamp from history file
extract_timestamp() {
  local file="$1"
  
  if [[ ! -f "$file" ]]; then
    echo "0"
    return 1
  fi
  
  # Try to get timestamp from file content first
  if command -v jq &> /dev/null; then
    local timestamp=$(jq -r '.timestamp // 0' "$file" 2>/dev/null)
    if [[ -n "$timestamp" && "$timestamp" != "null" && "$timestamp" != "0" ]]; then
      echo "$timestamp"
      return 0
    fi
  fi
  
  # Fall back to extracting from filename
  local filename=$(basename "$file")
  if [[ "$filename" =~ metrics_([0-9]{8})_([0-9]{6})\.json ]]; then
    local date_part="${BASH_REMATCH[1]}"
    local time_part="${BASH_REMATCH[2]}"
    
    # Convert to timestamp
    local year="${date_part:0:4}"
    local month="${date_part:4:2}"
    local day="${date_part:6:2}"
    local hour="${time_part:0:2}"
    local minute="${time_part:2:2}"
    local second="${time_part:4:2}"
    
    date -d "$year-$month-$day $hour:$minute:$second" +%s 2>/dev/null || echo "0"
  else
    echo "0"
  fi
}

# =====================
# Data Analysis
# =====================

# Get average value for a metric over a period
get_metric_average() {
  local period="$1"
  local metric="$2"
  local default_value="$3"
  
  local files=$(get_history_files_for_period "$period")
  local sum=0
  local count=0
  
  for file in $files; do
    local value=$(extract_metric "$file" "$metric" "$default_value")
    
    # Skip non-numeric values
    if [[ "$value" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
      sum=$(echo "$sum + $value" | bc -l 2>/dev/null)
      ((count++))
    fi
  done
  
  # Calculate average
  if [[ $count -gt 0 ]]; then
    local avg=$(echo "scale=2; $sum / $count" | bc -l 2>/dev/null)
    echo "$avg"
  else
    echo "$default_value"
  fi
}

# Get maximum value for a metric over a period
get_metric_max() {
  local period="$1"
  local metric="$2"
  local default_value="$3"
  
  local files=$(get_history_files_for_period "$period")
  local max="$default_value"
  
  for file in $files; do
    local value=$(extract_metric "$file" "$metric" "$default_value")
    
    # Skip non-numeric values
    if [[ "$value" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
      if [[ $(echo "$value > $max" | bc -l 2>/dev/null) -eq 1 ]]; then
        max="$value"
      fi
    fi
  done
  
  echo "$max"
}

# Get minimum value for a metric over a period
get_metric_min() {
  local period="$1"
  local metric="$2"
  local default_value="$3"
  
  local files=$(get_history_files_for_period "$period")
  local min=""
  
  for file in $files; do
    local value=$(extract_metric "$file" "$metric" "$default_value")
    
    # Skip non-numeric values
    if [[ "$value" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
      if [[ -z "$min" || $(echo "$value < $min" | bc -l 2>/dev/null) -eq 1 ]]; then
        min="$value"
      fi
    fi
  done
  
  if [[ -n "$min" ]]; then
    echo "$min"
  else
    echo "$default_value"
  fi
}

# Get trend direction for a metric over a period
# Returns: "up", "down", "stable", or "unknown"
get_metric_trend() {
  local period="$1"
  local metric="$2"
  
  local files=$(get_history_files_for_period "$period")
  local file_count=$(echo "$files" | wc -l)
  
  # Need at least 2 data points for a trend
  if [[ $file_count -lt 2 ]]; then
    echo "unknown"
    return
  fi
  
  # Get first and last values
  local first_file=$(echo "$files" | head -n 1)
  local last_file=$(echo "$files" | tail -n 1)
  
  local first_value=$(extract_metric "$first_file" "$metric" "0")
  local last_value=$(extract_metric "$last_file" "$metric" "0")
  
  # Skip non-numeric values
  if ! [[ "$first_value" =~ ^[0-9]+(\.[0-9]+)?$ ]] || ! [[ "$last_value" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    echo "unknown"
    return
  fi
  
  # Calculate percent change
  local diff=$(echo "$last_value - $first_value" | bc -l 2>/dev/null)
  local percent_change=0
  
  if [[ $(echo "$first_value != 0" | bc -l 2>/dev/null) -eq 1 ]]; then
    percent_change=$(echo "scale=2; ($diff / $first_value) * 100" | bc -l 2>/dev/null)
  fi
  
  # Determine trend direction
  if [[ $(echo "$percent_change > 5" | bc -l 2>/dev/null) -eq 1 ]]; then
    echo "up"
  elif [[ $(echo "$percent_change < -5" | bc -l 2>/dev/null) -eq 1 ]]; then
    echo "down"
  else
    echo "stable"
  fi
}

# =====================
# Visualization
# =====================

# Generate a simple ASCII chart for a metric
generate_ascii_chart() {
  local period="$1"
  local metric="$2"
  local chart_width="$3"
  local chart_title="$4"
  
  [[ -z "$chart_width" ]] && chart_width=$CHART_WIDTH
  [[ -z "$chart_title" ]] && chart_title="$metric"
  
  local files=$(get_history_files_for_period "$period")
  local file_count=$(echo "$files" | wc -l)
  
  # Need at least 2 data points for a chart
  if [[ $file_count -lt 2 ]]; then
    echo "Not enough data points to generate chart"
    return 1
  fi
  
  # Collect values and timestamps
  local values=()
  local timestamps=()
  local max_value=0
  local min_value=999999999
  
  for file in $files; do
    local value=$(extract_metric "$file" "$metric" "0")
    local timestamp=$(extract_timestamp "$file")
    
    # Skip non-numeric values
    if [[ "$value" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
      timestamps+=("$timestamp")
      values+=("$value")
      
      # Update min/max
      if [[ $(echo "$value > $max_value" | bc -l 2>/dev/null) -eq 1 ]]; then
        max_value="$value"
      fi
      if [[ $(echo "$value < $min_value" | bc -l 2>/dev/null) -eq 1 ]]; then
        min_value="$value"
      fi
    fi
  done
  
  # Ensure min and max are different to avoid division by zero
  if [[ $(echo "$max_value - $min_value < 0.01" | bc -l 2>/dev/null) -eq 1 ]]; then
    min_value=$(echo "$max_value - 1" | bc -l 2>/dev/null)
    [[ $(echo "$min_value < 0" | bc -l 2>/dev/null) -eq 1 ]] && min_value=0
  fi
  
  # Calculate chart height based on terminal size
  get_terminal_size
  local chart_height=$((TERM_ROWS / 4))
  [[ $chart_height -lt 5 ]] && chart_height=5
  [[ $chart_height -gt 20 ]] && chart_height=20
  
  # Chart title
  echo
  echo -e "${CYAN}$chart_title over $period${NC}"
  
  # Sample values if too many data points
  local data_count=${#values[@]}
  local sample_step=1
  
  if [[ $data_count -gt $chart_width ]]; then
    sample_step=$(( data_count / chart_width + 1 ))
  fi
  
  # Calculate sampled data
  local sampled_values=()
  local sampled_timestamps=()
  
  for ((i=0; i<data_count; i+=sample_step)); do
    sampled_values+=("${values[$i]}")
    sampled_timestamps+=("${timestamps[$i]}")
  done
  
  # Draw Y-axis
  for ((y=chart_height; y>=0; y--)); do
    local y_value=$(echo "scale=1; $min_value + ($max_value - $min_value) * $y / $chart_height" | bc -l 2>/dev/null)
    
    if [[ $y -eq $chart_height || $y -eq 0 || $y -eq $((chart_height/2)) ]]; then
      printf "%-8.1f │" $y_value
    else
      printf "        │"
    fi
    
    # Draw data points
    for ((i=0; i<${#sampled_values[@]}; i++)); do
      local value=${sampled_values[$i]}
      local scaled_value=$(echo "scale=5; ($value - $min_value) / ($max_value - $min_value) * $chart_height" | bc -l 2>/dev/null)
      local rounded_value=$(echo "($scaled_value+0.5)/1" | bc 2>/dev/null)
      
      if [[ $rounded_value -eq $y ]]; then
        echo -ne "${GREEN}●${NC}"
      elif [[ $y -eq 0 ]]; then
        echo -n "─"
      else
        echo -n " "
      fi
    done
    echo
  done
  
  # Draw X-axis
  printf "        └"
  for ((i=0; i<${#sampled_values[@]}; i++)); do
    echo -n "─"
  done
  echo
  
  # Draw X-axis labels
  printf "         "
  local label_step=$(( ${#sampled_timestamps[@]} / 3 ))
  [[ $label_step -lt 1 ]] && label_step=1
  
  for ((i=0; i<${#sampled_timestamps[@]}; i+=$label_step)); do
    local date_str=$(date -d "@${sampled_timestamps[$i]}" "+%m/%d" 2>/dev/null)
    printf "%-$label_step.${label_step}s" "$date_str"
  done
  echo
  
  # Print statistics
  echo
  echo -e "Min: ${CYAN}$(get_metric_min "$period" "$metric" "N/A")${NC}  |  "
  echo -e "Max: ${CYAN}$(get_metric_max "$period" "$metric" "N/A")${NC}  |  "
  echo -e "Avg: ${CYAN}$(get_metric_average "$period" "$metric" "N/A")${NC}  |  "
  
  # Show trend
  local trend=$(get_metric_trend "$period" "$metric")
  case "$trend" in
    "up") echo -e "Trend: ${GREEN}↑ Increasing${NC}" ;;
    "down") echo -e "Trend: ${RED}↓ Decreasing${NC}" ;;
    "stable") echo -e "Trend: ${YELLOW}→ Stable${NC}" ;;
    *) echo -e "Trend: ${YELLOW}? Unknown${NC}" ;;
  esac
  
  return 0
}

# =====================
# Main Functions
# =====================

# Show history summary
show_history_summary() {
  local period="$1"
  [[ -z "$period" ]] && period="$DEFAULT_PERIOD"
  
  print_header "HISTORY SUMMARY ($period)"
  
  # Check if we have enough data
  local files=$(get_history_files_for_period "$period")
  local file_count=$(echo "$files" | wc -l)
  
  if [[ $file_count -lt 2 ]]; then
    echo -e "${YELLOW}Not enough data points for history. Run 'pop pulse' regularly to collect data.${NC}"
    return 1
  fi
  
  # Show first and last data point timestamps
  local first_file=$(echo "$files" | head -n 1)
  local last_file=$(echo "$files" | tail -n 1)
  
  local first_ts=$(extract_timestamp "$first_file")
  local last_ts=$(extract_timestamp "$last_file")
  
  local first_date=$(date -d "@$first_ts" "+%Y-%m-%d %H:%M:%S" 2>/dev/null)
  local last_date=$(date -d "@$last_ts" "+%Y-%m-%d %H:%M:%S" 2>/dev/null)
  
  echo -e "Data from: ${CYAN}$first_date${NC} to ${CYAN}$last_date${NC}"
  echo -e "Data points: ${CYAN}$file_count${NC}"
  echo
  
  # Performance metrics summary
  echo -e "${CYAN}Performance Metrics:${NC}"
  
  local metrics=("reputation" "points" "uptime_score" "historical_score" "egress_score")
  local labels=("Reputation" "Points" "Uptime Score" "Historical Score" "Egress Score")
  
  for ((i=0; i<${#metrics[@]}; i++)); do
    local metric="${metrics[$i]}"
    local label="${labels[$i]}"
    
    local avg=$(get_metric_average "$period" "$metric" "N/A")
    local min=$(get_metric_min "$period" "$metric" "N/A")
    local max=$(get_metric_max "$period" "$metric" "N/A")
    
    # Add percentage sign back if needed
    if [[ "$metric" == *"score" ]]; then
      [[ "$avg" != "N/A" ]] && avg="${avg}%"
      [[ "$min" != "N/A" ]] && min="${min}%"
      [[ "$max" != "N/A" ]] && max="${max}%"
    fi
    
    # Show trend indicator
    local trend=$(get_metric_trend "$period" "$metric")
    local trend_indicator=""
    
    case "$trend" in
      "up") trend_indicator="${GREEN}↑${NC}" ;;
      "down") trend_indicator="${RED}↓${NC}" ;;
      "stable") trend_indicator="${YELLOW}→${NC}" ;;
      *) trend_indicator="${YELLOW}?${NC}" ;;
    esac
    
    echo -e "  $label: Avg ${CYAN}$avg${NC} (Min: $min, Max: $max) $trend_indicator"
  done
  
  # Generate a chart for reputation
  generate_ascii_chart "$period" "reputation" "$CHART_WIDTH" "Reputation"
  
  return 0
}

# Show detailed history for a specific metric
show_metric_history() {
  local metric="$1"
  local period="$2"
  
  [[ -z "$metric" ]] && metric="reputation"
  [[ -z "$period" ]] && period="$DEFAULT_PERIOD"
  
  print_header "METRIC HISTORY: $metric ($period)"
  
  # Check if we have enough data
  local files=$(get_history_files_for_period "$period")
  local file_count=$(echo "$files" | wc -l)
  
  if [[ $file_count -lt 2 ]]; then
    echo -e "${YELLOW}Not enough data points for history. Run 'pop pulse' regularly to collect data.${NC}"
    return 1
  fi
  
  # Generate chart
  generate_ascii_chart "$period" "$metric" "$CHART_WIDTH"
  
  # Show raw data
  echo
  echo -e "${CYAN}Raw Data Points:${NC}"
  echo -e "Timestamp               | Value"
  echo -e "------------------------|---------"
  
  local count=0
  local max_display=20  # Limit the number of points shown
  
  for file in $files; do
    local value=$(extract_metric "$file" "$metric" "N/A")
    local timestamp=$(extract_timestamp "$file")
    local date_str=$(date -d "@$timestamp" "+%Y-%m-%d %H:%M:%S" 2>/dev/null)
    
    # Add percentage sign if needed
    [[ "$metric" == *"score" && "$value" != "N/A" ]] && value="${value}%"
    
    echo -e "$date_str | $value"
    
    ((count++))
    if [[ $count -ge $max_display ]]; then
      echo -e "... and $(( file_count - max_display )) more data points"
      break
    fi
  done
  
  return 0
}

# Run the history command with options
run_history() {
  local metric=""
  local period="$DEFAULT_PERIOD"
  local mode="summary"
  
  # Parse options
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --period=*)
        period="${1#*=}"
        shift
        ;;
      --period)
        if [[ -n "$2" ]]; then
          period="$2"
          shift 2
        else
          log_error "Missing value for --period"
          return 1
        fi
        ;;
      --metric=*)
        metric="${1#*=}"
        shift
        ;;
      --metric)
        if [[ -n "$2" ]]; then
          metric="$2"
          shift 2
        else
          log_error "Missing value for --metric"
          return 1
        fi
        ;;
      --detailed)
        mode="detailed"
        shift
        ;;
      --list)
        mode="list"
        shift
        ;;
      --help)
        show_history_help
        return 0
        ;;
      *)
        # First positional arg is metric, second is period
        if [[ -z "$metric" ]]; then
          metric="$1"
        elif [[ -z "$period" || "$period" == "$DEFAULT_PERIOD" ]]; then
          period="$1"
        fi
        shift
        ;;
    esac
  done
  
  # Validate period
  local valid_period=0
  for p in "${AVAILABLE_PERIODS[@]}"; do
    if [[ "$period" == "$p" ]]; then
      valid_period=1
      break
    fi
  done
  
  if [[ $valid_period -eq 0 ]]; then
    log_error "Invalid period: $period"
    log_error "Available periods: ${AVAILABLE_PERIODS[*]}"
    return 1
  fi
  
  # Ensure we have a metrics directory
  ensure_metrics_dir
  ensure_history_dir
  
  # Process based on mode
  case "$mode" in
    "summary")
      show_history_summary "$period"
      ;;
    "detailed")
      # If metric is not specified, use reputation as default
      [[ -z "$metric" ]] && metric="reputation"
      show_metric_history "$metric" "$period"
      ;;
    "list")
      print_header "HISTORY FILES"
      local files=$(list_history_files)
      if [[ -z "$files" ]]; then
        echo -e "${YELLOW}No history files found.${NC}"
        return 1
      fi
      
      echo -e "Found $(echo "$files" | wc -l) history files:"
      echo
      for file in $files; do
        local timestamp=$(extract_timestamp "$file")
        local date_str=$(date -d "@$timestamp" "+%Y-%m-%d %H:%M:%S" 2>/dev/null)
        echo -e "$(basename "$file") - $date_str"
      done
      ;;
    *)
      log_error "Unknown mode: $mode"
      return 1
      ;;
  esac
  
  return 0
}

# Show help for history command
show_history_help() {
  print_header "HISTORY HELP"
  
  echo -e "Usage: pop history [OPTIONS] [METRIC] [PERIOD]"
  echo
  echo -e "View historical performance data for your Pipe Network node."
  echo
  echo -e "Options:"
  echo -e "  ${CYAN}--period=PERIOD${NC}      Set time period (${AVAILABLE_PERIODS[*]})"
  echo -e "  ${CYAN}--metric=METRIC${NC}      View specific metric history"
  echo -e "  ${CYAN}--detailed${NC}           Show detailed view with raw data"
  echo -e "  ${CYAN}--list${NC}               List all history files"
  echo -e "  ${CYAN}--help${NC}               Show this help information"
  echo
  echo -e "Available Metrics:"
  echo -e "  ${CYAN}reputation${NC}           Node reputation score"
  echo -e "  ${CYAN}points${NC}               Earned points"
  echo -e "  ${CYAN}uptime_score${NC}         Uptime performance score"
  echo -e "  ${CYAN}historical_score${NC}     Historical performance score"
  echo -e "  ${CYAN}egress_score${NC}         Egress performance score"
  echo
  echo -e "Examples:"
  echo -e "  ${CYAN}pop history${NC}                        Show summary for default period (7d)"
  echo -e "  ${CYAN}pop history --period=30d${NC}           Show 30-day history summary"
  echo -e "  ${CYAN}pop history reputation 14d${NC}         Show reputation history for 14 days"
  echo -e "  ${CYAN}pop history --metric=points --detailed${NC}  Show detailed points history"
  echo
  
  return 0
}
