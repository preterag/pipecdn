#!/bin/bash
# Alerts Module for Pipe Network PoP Node Management Tools
# This module handles node monitoring, alerts, and notifications

# =====================
# Alert Configuration
# =====================

# Default alert configuration path
get_alerts_dir() {
  if [[ -z "$ALERTS_DIR" ]]; then
    local config_dir
    if [[ -z "$CONFIG_DIR" ]]; then
      config_dir="${INSTALL_DIR}/config"
    else
      config_dir="$CONFIG_DIR"
    fi
    ALERTS_DIR="${config_dir}/alerts"
  fi
  
  echo "$ALERTS_DIR"
}

# Ensure alerts directory exists
ensure_alerts_dir() {
  local dir=$(get_alerts_dir)
  
  if [[ ! -d "$dir" ]]; then
    log_debug "Creating alerts directory: $dir"
    sudo mkdir -p "$dir"
    sudo chmod 755 "$dir"
  fi
  
  # Create alerts config if it doesn't exist
  local config_file="${dir}/alerts.json"
  if [[ ! -f "$config_file" ]]; then
    log_debug "Creating default alerts configuration"
    create_default_alerts_config
  fi
}

# Create default alerts configuration
create_default_alerts_config() {
  local dir=$(get_alerts_dir)
  local config_file="${dir}/alerts.json"
  
  # Default alert thresholds
  cat > "$config_file" << EOF
{
  "enabled": true,
  "notification_methods": {
    "terminal": true,
    "email": false,
    "log": true
  },
  "email_settings": {
    "smtp_server": "",
    "smtp_port": 587,
    "smtp_username": "",
    "smtp_password": "",
    "from_address": "",
    "to_address": ""
  },
  "alert_thresholds": {
    "reputation": {
      "min": 70,
      "critical": 50
    },
    "uptime_score": {
      "min": 90,
      "critical": 80
    },
    "historical_score": {
      "min": 85,
      "critical": 75
    },
    "egress_score": {
      "min": 80,
      "critical": 60
    },
    "disk_usage": {
      "max": 85,
      "critical": 95
    },
    "cpu_usage": {
      "max": 80,
      "critical": 95
    },
    "memory_usage": {
      "max": 85,
      "critical": 95
    }
  },
  "check_interval_minutes": 60,
  "alert_cooldown_hours": 12,
  "log_size_limit": 1000
}
EOF
}

# Get alerts configuration
get_alerts_config() {
  local dir=$(get_alerts_dir)
  local config_file="${dir}/alerts.json"
  
  if [[ ! -f "$config_file" ]]; then
    log_error "Alerts configuration file not found: $config_file"
    return 1
  fi
  
  echo "$config_file"
}

# Get alert threshold
get_alert_threshold() {
  local metric="$1"
  local type="$2"  # min, max, critical
  local default_value="$3"
  
  local config_file=$(get_alerts_config)
  if [[ -z "$config_file" ]]; then
    echo "$default_value"
    return 1
  fi
  
  if command -v jq &> /dev/null; then
    local value
    if [[ "$type" == "critical" ]]; then
      value=$(jq -r ".alert_thresholds.$metric.critical // \"$default_value\"" "$config_file" 2>/dev/null)
    elif [[ "$type" == "max" ]]; then
      value=$(jq -r ".alert_thresholds.$metric.max // \"$default_value\"" "$config_file" 2>/dev/null)
    else
      value=$(jq -r ".alert_thresholds.$metric.min // \"$default_value\"" "$config_file" 2>/dev/null)
    fi
    
    if [[ "$value" == "null" ]]; then
      echo "$default_value"
    else
      echo "$value"
    fi
  else
    echo "$default_value"
  fi
}

# Check if alerts are enabled
alerts_enabled() {
  local config_file=$(get_alerts_config)
  if [[ -z "$config_file" ]]; then
    # Default to enabled if no config
    return 0
  fi
  
  if command -v jq &> /dev/null; then
    local enabled=$(jq -r '.enabled // true' "$config_file" 2>/dev/null)
    if [[ "$enabled" == "false" ]]; then
      return 1
    fi
  fi
  
  return 0
}

# Get notification method status
notification_method_enabled() {
  local method="$1"  # terminal, email, log
  local default_value="$2"
  
  local config_file=$(get_alerts_config)
  if [[ -z "$config_file" ]]; then
    # Use default
    if [[ "$default_value" == "true" ]]; then
      return 0
    else
      return 1
    fi
  fi
  
  if command -v jq &> /dev/null; then
    local enabled=$(jq -r ".notification_methods.$method // \"$default_value\"" "$config_file" 2>/dev/null)
    if [[ "$enabled" == "true" ]]; then
      return 0
    else
      return 1
    fi
  else
    # Use default
    if [[ "$default_value" == "true" ]]; then
      return 0
    else
      return 1
    fi
  fi
}

# =====================
# Alert Functions
# =====================

# Get notifications log path
get_notifications_log() {
  local dir=$(get_alerts_dir)
  echo "${dir}/notifications.log"
}

# Log notification to file
log_notification() {
  local level="$1"
  local message="$2"
  local log_file=$(get_notifications_log)
  
  # Create log entry
  local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
  local entry="[$timestamp] [$level] $message"
  
  # Append to log file
  echo "$entry" >> "$log_file"
  
  # Rotate log if too large
  local config_file=$(get_alerts_config)
  local log_limit=1000
  
  if [[ -f "$config_file" ]] && command -v jq &> /dev/null; then
    log_limit=$(jq -r '.log_size_limit // 1000' "$config_file" 2>/dev/null)
  fi
  
  # Count lines in log file
  local line_count=$(wc -l < "$log_file")
  
  # Rotate if exceeds limit
  if [[ $line_count -gt $log_limit ]]; then
    log_debug "Rotating notifications log (entries: $line_count, limit: $log_limit)"
    local temp_file="${log_file}.tmp"
    
    # Keep the most recent entries
    tail -n "$log_limit" "$log_file" > "$temp_file"
    mv "$temp_file" "$log_file"
  fi
}

# Send notification via configured methods
send_notification() {
  local level="$1"  # info, warning, critical
  local subject="$2"
  local message="$3"
  
  # Check if alerts are enabled
  alerts_enabled || return 0
  
  # Format the notification
  local formatted_subject="Pipe Network Node Alert: $subject"
  local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
  local formatted_message="[$timestamp] [$level] $message"
  
  # Log notification if enabled
  if notification_method_enabled "log" "true"; then
    log_notification "$level" "$message"
  fi
  
  # Display in terminal if enabled
  if notification_method_enabled "terminal" "true"; then
    case "$level" in
      "info")     echo -e "${CYAN}INFO${NC}: $message" ;;
      "warning")  echo -e "${YELLOW}WARNING${NC}: $message" ;;
      "critical") echo -e "${RED}CRITICAL${NC}: $message" ;;
      *)          echo -e "$message" ;;
    esac
  fi
  
  # Send email if enabled
  if notification_method_enabled "email" "false"; then
    send_email_notification "$level" "$formatted_subject" "$formatted_message"
  fi
}

# Send email notification
send_email_notification() {
  local level="$1"
  local subject="$2"
  local message="$3"
  
  local config_file=$(get_alerts_config)
  if [[ -z "$config_file" ]]; then
    log_error "Cannot send email: configuration not found"
    return 1
  fi
  
  # Extract email settings
  if ! command -v jq &> /dev/null; then
    log_error "Cannot send email: jq not installed"
    return 1
  fi
  
  local smtp_server=$(jq -r '.email_settings.smtp_server // ""' "$config_file" 2>/dev/null)
  local smtp_port=$(jq -r '.email_settings.smtp_port // 587' "$config_file" 2>/dev/null)
  local smtp_user=$(jq -r '.email_settings.smtp_username // ""' "$config_file" 2>/dev/null)
  local smtp_pass=$(jq -r '.email_settings.smtp_password // ""' "$config_file" 2>/dev/null)
  local from_addr=$(jq -r '.email_settings.from_address // ""' "$config_file" 2>/dev/null)
  local to_addr=$(jq -r '.email_settings.to_address // ""' "$config_file" 2>/dev/null)
  
  # Validate required fields
  if [[ -z "$smtp_server" || -z "$from_addr" || -z "$to_addr" ]]; then
    log_error "Cannot send email: missing required email settings"
    return 1
  fi
  
  # Create email content
  local temp_file=$(mktemp)
  cat > "$temp_file" << EOF
Subject: $subject
From: $from_addr
To: $to_addr
Content-Type: text/plain; charset=UTF-8

$message

---
Sent by Pipe Network PoP Node Management Tools
EOF
  
  # Check if we have mail command
  if command -v mail &> /dev/null; then
    cat "$temp_file" | mail -s "$subject" -r "$from_addr" "$to_addr"
    local status=$?
    rm -f "$temp_file"
    return $status
  fi
  
  # Check if we have sendmail
  if command -v sendmail &> /dev/null; then
    sendmail -f "$from_addr" "$to_addr" < "$temp_file"
    local status=$?
    rm -f "$temp_file"
    return $status
  fi
  
  # Check if we have curl for API-based email sending
  if command -v curl &> /dev/null && [[ -n "$smtp_user" && -n "$smtp_pass" ]]; then
    # Use curl to send email via SMTP
    curl --ssl-reqd --url "smtps://${smtp_server}:${smtp_port}" \
         --user "${smtp_user}:${smtp_pass}" \
         --mail-from "$from_addr" \
         --mail-rcpt "$to_addr" \
         --upload-file "$temp_file"
    local status=$?
    rm -f "$temp_file"
    return $status
  fi
  
  # No mail sending method available
  rm -f "$temp_file"
  log_error "Cannot send email: no mail sending method available"
  return 1
}

# =====================
# Monitoring Functions
# =====================

# Check alert thresholds and trigger alerts if needed
check_alert_thresholds() {
  # Ensure alerts directory and config exist
  ensure_alerts_dir
  
  # Check if alerts are enabled
  alerts_enabled || {
    log_debug "Alerts are disabled, skipping checks"
    return 0
  }
  
  log_debug "Checking alert thresholds..."
  
  # Get current metrics
  # These functions are from metrics.sh
  local reputation=$(get_current_reputation)
  local uptime_score=$(get_uptime_score)
  local historical_score=$(get_historical_score)
  local egress_score=$(get_egress_score)
  local cpu_usage=$(get_cpu_usage)
  local memory_usage=$(get_memory_usage)
  local disk_usage=$(get_disk_usage)
  
  # Remove percentage signs
  uptime_score=${uptime_score/\%/}
  historical_score=${historical_score/\%/}
  egress_score=${egress_score/\%/}
  cpu_usage=${cpu_usage/\%/}
  memory_usage=${memory_usage/\%/}
  disk_usage=${disk_usage/\%/}
  
  # Check low metrics (higher is better)
  check_low_metric "reputation" "$reputation"
  check_low_metric "uptime_score" "$uptime_score"
  check_low_metric "historical_score" "$historical_score"
  check_low_metric "egress_score" "$egress_score"
  
  # Check high metrics (lower is better)
  check_high_metric "cpu_usage" "$cpu_usage"
  check_high_metric "memory_usage" "$memory_usage"
  check_high_metric "disk_usage" "$disk_usage"
  
  log_debug "Alert threshold checks completed"
  return 0
}

# Check low metric (where lower values are concerning)
check_low_metric() {
  local metric="$1"
  local value="$2"
  
  # Skip if not a number
  if ! [[ "$value" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    log_debug "Skipping check for $metric: non-numeric value '$value'"
    return 0
  fi
  
  # Get thresholds
  local min_threshold=$(get_alert_threshold "$metric" "min" "")
  local critical_threshold=$(get_alert_threshold "$metric" "critical" "")
  
  # Skip if thresholds not set
  if [[ -z "$min_threshold" || -z "$critical_threshold" ]]; then
    log_debug "Skipping check for $metric: thresholds not configured"
    return 0
  fi
  
  # Check if alert should be triggered
  if [[ $(echo "$value < $critical_threshold" | bc -l 2>/dev/null) -eq 1 ]]; then
    # Critical alert
    if ! is_alert_in_cooldown "$metric" "critical"; then
      local message="${metric^} is critically low: $value (threshold: $critical_threshold)"
      send_notification "critical" "Critical: Low ${metric^}" "$message"
      set_alert_cooldown "$metric" "critical"
    fi
  elif [[ $(echo "$value < $min_threshold" | bc -l 2>/dev/null) -eq 1 ]]; then
    # Warning alert
    if ! is_alert_in_cooldown "$metric" "warning"; then
      local message="${metric^} is low: $value (threshold: $min_threshold)"
      send_notification "warning" "Warning: Low ${metric^}" "$message"
      set_alert_cooldown "$metric" "warning"
    fi
  fi
}

# Check high metric (where higher values are concerning)
check_high_metric() {
  local metric="$1"
  local value="$2"
  
  # Skip if not a number
  if ! [[ "$value" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    log_debug "Skipping check for $metric: non-numeric value '$value'"
    return 0
  fi
  
  # Get thresholds
  local max_threshold=$(get_alert_threshold "$metric" "max" "")
  local critical_threshold=$(get_alert_threshold "$metric" "critical" "")
  
  # Skip if thresholds not set
  if [[ -z "$max_threshold" || -z "$critical_threshold" ]]; then
    log_debug "Skipping check for $metric: thresholds not configured"
    return 0
  fi
  
  # Check if alert should be triggered
  if [[ $(echo "$value > $critical_threshold" | bc -l 2>/dev/null) -eq 1 ]]; then
    # Critical alert
    if ! is_alert_in_cooldown "$metric" "critical"; then
      local message="${metric^} is critically high: $value% (threshold: $critical_threshold%)"
      send_notification "critical" "Critical: High ${metric^}" "$message"
      set_alert_cooldown "$metric" "critical"
    fi
  elif [[ $(echo "$value > $max_threshold" | bc -l 2>/dev/null) -eq 1 ]]; then
    # Warning alert
    if ! is_alert_in_cooldown "$metric" "warning"; then
      local message="${metric^} is high: $value% (threshold: $max_threshold%)"
      send_notification "warning" "Warning: High ${metric^}" "$message"
      set_alert_cooldown "$metric" "warning"
    fi
  fi
}

# Get alerts cooldown file path
get_alerts_cooldown_file() {
  local dir=$(get_alerts_dir)
  echo "${dir}/cooldown.json"
}

# Check if alert is in cooldown period
is_alert_in_cooldown() {
  local metric="$1"
  local level="$2"
  
  local cooldown_file=$(get_alerts_cooldown_file)
  
  # If no cooldown file, not in cooldown
  if [[ ! -f "$cooldown_file" ]]; then
    return 1
  fi
  
  if ! command -v jq &> /dev/null; then
    # Without jq, can't check properly
    return 1
  fi
  
  # Get timestamp of last alert for this metric and level
  local timestamp_key="${metric}_${level}"
  local last_timestamp=$(jq -r ".$timestamp_key // 0" "$cooldown_file" 2>/dev/null)
  
  # If no timestamp, not in cooldown
  if [[ -z "$last_timestamp" || "$last_timestamp" == "null" || "$last_timestamp" == "0" ]]; then
    return 1
  fi
  
  # Get cooldown period from config
  local config_file=$(get_alerts_config)
  local cooldown_hours=12
  
  if [[ -f "$config_file" ]]; then
    cooldown_hours=$(jq -r '.alert_cooldown_hours // 12' "$config_file" 2>/dev/null)
  fi
  
  # Calculate cooldown expiry
  local now=$(date +%s)
  local expiry=$((last_timestamp + cooldown_hours * 3600))
  
  # Check if still in cooldown
  if [[ $now -lt $expiry ]]; then
    return 0  # In cooldown
  else
    return 1  # Not in cooldown
  fi
}

# Set alert cooldown
set_alert_cooldown() {
  local metric="$1"
  local level="$2"
  
  local cooldown_file=$(get_alerts_cooldown_file)
  local now=$(date +%s)
  local timestamp_key="${metric}_${level}"
  
  # If no cooldown file, create one
  if [[ ! -f "$cooldown_file" ]]; then
    echo "{}" > "$cooldown_file"
  fi
  
  if command -v jq &> /dev/null; then
    # Update timestamp using jq
    local temp_file=$(mktemp)
    jq --arg key "$timestamp_key" --arg ts "$now" '.[$key] = ($ts | tonumber)' "$cooldown_file" > "$temp_file"
    mv "$temp_file" "$cooldown_file"
  else
    # Without jq, replace the file with a simple entry
    echo "{\"$timestamp_key\": $now}" > "$cooldown_file"
  fi
}

# =====================
# Alert Configuration Management
# =====================

# Show alert configuration
show_alert_config() {
  # Ensure alerts directory and config exist
  ensure_alerts_dir
  
  local config_file=$(get_alerts_config)
  
  print_header "ALERT CONFIGURATION"
  
  # Check if alerts are enabled
  if alerts_enabled; then
    echo -e "Alerts: ${GREEN}Enabled${NC}"
  else
    echo -e "Alerts: ${RED}Disabled${NC}"
  fi
  
  echo
  echo -e "${CYAN}Notification Methods:${NC}"
  
  # Terminal notifications
  if notification_method_enabled "terminal" "true"; then
    echo -e "  Terminal alerts: ${GREEN}Enabled${NC}"
  else
    echo -e "  Terminal alerts: ${RED}Disabled${NC}"
  fi
  
  # Email notifications
  if notification_method_enabled "email" "false"; then
    echo -e "  Email alerts: ${GREEN}Enabled${NC}"
    
    # Show email configuration
    if command -v jq &> /dev/null; then
      local smtp_server=$(jq -r '.email_settings.smtp_server // "Not configured"' "$config_file" 2>/dev/null)
      local from_addr=$(jq -r '.email_settings.from_address // "Not configured"' "$config_file" 2>/dev/null)
      local to_addr=$(jq -r '.email_settings.to_address // "Not configured"' "$config_file" 2>/dev/null)
      
      echo -e "    SMTP Server: $smtp_server"
      echo -e "    From: $from_addr"
      echo -e "    To: $to_addr"
    fi
  else
    echo -e "  Email alerts: ${RED}Disabled${NC}"
  fi
  
  # Log notifications
  if notification_method_enabled "log" "true"; then
    echo -e "  Log alerts: ${GREEN}Enabled${NC}"
  else
    echo -e "  Log alerts: ${RED}Disabled${NC}"
  fi
  
  echo
  echo -e "${CYAN}Alert Thresholds:${NC}"
  
  # Display thresholds table
  echo -e "  Metric                  | Warning | Critical"
  echo -e "  -----------------------|---------|----------"
  
  # Low metrics
  echo -e "  Reputation              | < $(get_alert_threshold "reputation" "min" "70")      | < $(get_alert_threshold "reputation" "critical" "50")"
  echo -e "  Uptime Score (%)        | < $(get_alert_threshold "uptime_score" "min" "90")      | < $(get_alert_threshold "uptime_score" "critical" "80")"
  echo -e "  Historical Score (%)    | < $(get_alert_threshold "historical_score" "min" "85")      | < $(get_alert_threshold "historical_score" "critical" "75")"
  echo -e "  Egress Score (%)        | < $(get_alert_threshold "egress_score" "min" "80")      | < $(get_alert_threshold "egress_score" "critical" "60")"
  
  # High metrics
  echo -e "  CPU Usage (%)           | > $(get_alert_threshold "cpu_usage" "max" "80")      | > $(get_alert_threshold "cpu_usage" "critical" "95")"
  echo -e "  Memory Usage (%)        | > $(get_alert_threshold "memory_usage" "max" "85")      | > $(get_alert_threshold "memory_usage" "critical" "95")"
  echo -e "  Disk Usage (%)          | > $(get_alert_threshold "disk_usage" "max" "85")      | > $(get_alert_threshold "disk_usage" "critical" "95")"
  
  echo
  
  # Check interval and cooldown
  if command -v jq &> /dev/null; then
    local check_interval=$(jq -r '.check_interval_minutes // 60' "$config_file" 2>/dev/null)
    local cooldown_hours=$(jq -r '.alert_cooldown_hours // 12' "$config_file" 2>/dev/null)
    
    echo -e "Check interval: ${CYAN}$check_interval minutes${NC}"
    echo -e "Alert cooldown: ${CYAN}$cooldown_hours hours${NC}"
  fi
  
  return 0
}

# Update alert settings
update_alert_settings() {
  local setting="$1"
  local value="$2"
  
  # Ensure alerts directory and config exist
  ensure_alerts_dir
  
  local config_file=$(get_alerts_config)
  local temp_file=$(mktemp)
  
  case "$setting" in
    "enable"|"enabled")
      jq '.enabled = true' "$config_file" > "$temp_file"
      mv "$temp_file" "$config_file"
      echo "Alerts enabled"
      ;;
    "disable"|"disabled")
      jq '.enabled = false' "$config_file" > "$temp_file"
      mv "$temp_file" "$config_file"
      echo "Alerts disabled"
      ;;
    "email.enable"|"email.enabled")
      jq '.notification_methods.email = true' "$config_file" > "$temp_file"
      mv "$temp_file" "$config_file"
      echo "Email notifications enabled"
      ;;
    "email.disable"|"email.disabled")
      jq '.notification_methods.email = false' "$config_file" > "$temp_file"
      mv "$temp_file" "$config_file"
      echo "Email notifications disabled"
      ;;
    "smtp_server"|"email.server")
      if [[ -n "$value" ]]; then
        jq --arg val "$value" '.email_settings.smtp_server = $val' "$config_file" > "$temp_file"
        mv "$temp_file" "$config_file"
        echo "SMTP server updated to: $value"
      else
        echo "Error: SMTP server value is required"
        rm -f "$temp_file"
        return 1
      fi
      ;;
    "email.from"|"from_address")
      if [[ -n "$value" ]]; then
        jq --arg val "$value" '.email_settings.from_address = $val' "$config_file" > "$temp_file"
        mv "$temp_file" "$config_file"
        echo "From address updated to: $value"
      else
        echo "Error: From address value is required"
        rm -f "$temp_file"
        return 1
      fi
      ;;
    "email.to"|"to_address")
      if [[ -n "$value" ]]; then
        jq --arg val "$value" '.email_settings.to_address = $val' "$config_file" > "$temp_file"
        mv "$temp_file" "$config_file"
        echo "To address updated to: $value"
      else
        echo "Error: To address value is required"
        rm -f "$temp_file"
        return 1
      fi
      ;;
    "threshold."*)
      # Extract metric and threshold type from setting
      local metric_part="${setting#threshold.}"
      local metric="${metric_part%%.*}"
      local threshold_type="${metric_part#*.}"
      
      if [[ -z "$metric" || -z "$threshold_type" || -z "$value" ]]; then
        echo "Error: Invalid threshold setting format"
        echo "Expected: threshold.<metric>.<type> <value>"
        echo "Example: threshold.reputation.min 70"
        rm -f "$temp_file"
        return 1
      fi
      
      # Validate metric
      case "$metric" in
        "reputation"|"uptime_score"|"historical_score"|"egress_score"|"cpu_usage"|"memory_usage"|"disk_usage")
          ;;
        *)
          echo "Error: Unknown metric: $metric"
          rm -f "$temp_file"
          return 1
          ;;
      esac
      
      # Validate threshold type
      case "$threshold_type" in
        "min"|"max"|"critical")
          ;;
        *)
          echo "Error: Unknown threshold type: $threshold_type"
          echo "Expected: min, max, or critical"
          rm -f "$temp_file"
          return 1
          ;;
      esac
      
      # Validate value is numeric
      if ! [[ "$value" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        echo "Error: Threshold value must be numeric"
        rm -f "$temp_file"
        return 1
      fi
      
      # Update threshold
      jq --arg metric "$metric" --arg type "$threshold_type" --arg val "$value" \
         '.alert_thresholds[$metric][$type] = ($val | tonumber)' "$config_file" > "$temp_file"
      mv "$temp_file" "$config_file"
      echo "Updated $metric $threshold_type threshold to: $value"
      ;;
    "interval"|"check_interval")
      if [[ -n "$value" ]] && [[ "$value" =~ ^[0-9]+$ ]]; then
        jq --arg val "$value" '.check_interval_minutes = ($val | tonumber)' "$config_file" > "$temp_file"
        mv "$temp_file" "$config_file"
        echo "Check interval updated to: $value minutes"
      else
        echo "Error: Check interval must be a positive integer"
        rm -f "$temp_file"
        return 1
      fi
      ;;
    "cooldown"|"alert_cooldown")
      if [[ -n "$value" ]] && [[ "$value" =~ ^[0-9]+$ ]]; then
        jq --arg val "$value" '.alert_cooldown_hours = ($val | tonumber)' "$config_file" > "$temp_file"
        mv "$temp_file" "$config_file"
        echo "Alert cooldown updated to: $value hours"
      else
        echo "Error: Alert cooldown must be a positive integer"
        rm -f "$temp_file"
        return 1
      fi
      ;;
    *)
      echo "Error: Unknown setting: $setting"
      echo "Run 'pop alerts help' for available settings"
      rm -f "$temp_file"
      return 1
      ;;
  esac
  
  rm -f "$temp_file"
  return 0
}

# Show alerts log
show_alerts_log() {
  local log_file=$(get_notifications_log)
  
  print_header "ALERTS LOG"
  
  if [[ ! -f "$log_file" ]]; then
    echo -e "${YELLOW}No alerts log found.${NC}"
    return 0
  fi
  
  local lines=${1:-20}
  
  # Validate lines is a positive integer
  if ! [[ "$lines" =~ ^[0-9]+$ ]] || [[ $lines -eq 0 ]]; then
    lines=20
  fi
  
  echo -e "Showing last $lines log entries:"
  echo
  
  # Display log with colorization
  tail -n $lines "$log_file" | while read -r line; do
    if [[ "$line" == *"[critical]"* ]]; then
      echo -e "${RED}$line${NC}"
    elif [[ "$line" == *"[warning]"* ]]; then
      echo -e "${YELLOW}$line${NC}"
    elif [[ "$line" == *"[info]"* ]]; then
      echo -e "${CYAN}$line${NC}"
    else
      echo -e "$line"
    fi
  done
  
  return 0
}

# Reset alerts (clear cooldown)
reset_alerts() {
  local cooldown_file=$(get_alerts_cooldown_file)
  
  if [[ -f "$cooldown_file" ]]; then
    rm -f "$cooldown_file"
    echo "Alerts reset: cooldown cleared"
  else
    echo "No alert cooldowns to reset"
  fi
  
  return 0
}

# Test alert system
test_alert() {
  local level=${1:-"warning"}
  
  print_header "TESTING ALERT SYSTEM"
  
  # Validate level
  case "$level" in
    "info"|"warning"|"critical")
      ;;
    *)
      echo "Invalid alert level: $level"
      echo "Expected: info, warning, or critical"
      return 1
      ;;
  esac
  
  echo "Sending test $level alert..."
  send_notification "$level" "Test Alert" "This is a test alert of level: $level"
  
  echo
  echo "Test alert sent successfully."
  
  return 0
}

# =====================
# Alert Command Functions
# =====================

# Run the alert system in daemon mode
run_alert_daemon() {
  print_header "STARTING ALERT DAEMON"
  
  # Ensure alerts directory and config exist
  ensure_alerts_dir
  
  # Get check interval
  local config_file=$(get_alerts_config)
  local check_interval=60  # Default 60 minutes
  
  if command -v jq &> /dev/null && [[ -f "$config_file" ]]; then
    check_interval=$(jq -r '.check_interval_minutes // 60' "$config_file" 2>/dev/null)
  fi
  
  echo "Starting alert daemon with check interval: $check_interval minutes"
  echo "Press Ctrl+C to stop"
  
  # Run first check immediately
  check_alert_thresholds
  
  # Convert minutes to seconds
  local interval_seconds=$((check_interval * 60))
  
  while true; do
    # Sleep until next check
    echo "Next check in $check_interval minutes..."
    sleep $interval_seconds
    
    # Run check
    check_alert_thresholds
  done
}

# Show help for alerts command
show_alerts_help() {
  print_header "ALERTS HELP"
  
  echo -e "Usage: pop alerts [COMMAND] [OPTIONS]"
  echo
  echo -e "Manage node monitoring, alerts, and notifications."
  echo
  echo -e "Commands:"
  echo -e "  ${CYAN}status${NC}                      Show alert system status and configuration"
  echo -e "  ${CYAN}check${NC}                       Run a one-time check against alert thresholds"
  echo -e "  ${CYAN}daemon${NC}                      Run alert system in daemon mode (continuous monitoring)"
  echo -e "  ${CYAN}log [N]${NC}                     Show last N alert log entries (default: 20)"
  echo -e "  ${CYAN}test [LEVEL]${NC}                Test alert system with specified level (info|warning|critical)"
  echo -e "  ${CYAN}reset${NC}                       Reset alert system (clear cooldown periods)"
  echo -e "  ${CYAN}config SETTING [VALUE]${NC}      View or update alert configuration"
  echo -e "  ${CYAN}help${NC}                        Show this help information"
  echo
  echo -e "Configuration Settings:"
  echo -e "  ${CYAN}enable/disable${NC}              Enable or disable the alert system"
  echo -e "  ${CYAN}email.enable/email.disable${NC}  Enable or disable email notifications"
  echo -e "  ${CYAN}email.server VALUE${NC}          Set SMTP server address"
  echo -e "  ${CYAN}email.from VALUE${NC}            Set email sender address"
  echo -e "  ${CYAN}email.to VALUE${NC}              Set email recipient address"
  echo -e "  ${CYAN}threshold.METRIC.TYPE VALUE${NC} Set alert threshold for metric"
  echo -e "  ${CYAN}interval VALUE${NC}              Set check interval in minutes"
  echo -e "  ${CYAN}cooldown VALUE${NC}              Set alert cooldown period in hours"
  echo
  echo -e "Examples:"
  echo -e "  ${CYAN}pop alerts status${NC}                         Show alert system status"
  echo -e "  ${CYAN}pop alerts config enable${NC}                  Enable the alert system"
  echo -e "  ${CYAN}pop alerts config threshold.reputation.min 75${NC}  Set min reputation threshold"
  echo -e "  ${CYAN}pop alerts check${NC}                          Run a manual check"
  echo -e "  ${CYAN}pop alerts log 50${NC}                         Show last 50 alert log entries"
  echo
  
  return 0
}

# Run alerts command with options
run_alerts() {
  local command="status"
  
  if [[ $# -gt 0 ]]; then
    command="$1"
    shift
  fi
  
  # Ensure alerts directory and config exist
  ensure_alerts_dir
  
  case "$command" in
    "status"|"show"|"config")
      if [[ $# -eq 0 ]]; then
        # No arguments, show current config
        show_alert_config
      else
        # Update setting
        update_alert_settings "$1" "$2"
      fi
      ;;
    "check")
      check_alert_thresholds
      ;;
    "daemon"|"monitor"|"start")
      run_alert_daemon
      ;;
    "log"|"logs"|"history")
      show_alerts_log "$1"
      ;;
    "test")
      test_alert "$1"
      ;;
    "reset"|"clear")
      reset_alerts
      ;;
    "help"|"--help"|"-h")
      show_alerts_help
      ;;
    *)
      log_error "Unknown alerts command: $command"
      echo
      show_alerts_help
      return 1
      ;;
  esac
  
  return $?
} 