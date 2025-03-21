#!/bin/bash
# Fleet Management - Deployment Module
# Handles file deployment across multiple nodes

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Ensure we're in the correct directory
if [[ -z "$ROOT_DIR" ]]; then
  # Determine script location for relative paths
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
fi

# Define paths
FLEET_DIR="${ROOT_DIR}/src/fleet"
CONFIG_DIR="${ROOT_DIR}/config/fleet"
NODE_DB="${CONFIG_DIR}/nodes.json"
SSH_DIR="${ROOT_DIR}/config/fleet/ssh"
KEY_FILE="${SSH_DIR}/fleet_rsa"

# Source required modules
source "${FLEET_DIR}/core/ssh.sh"
source "${FLEET_DIR}/core/registration.sh"

# Deploy a file to a specific node
deploy_to_node() {
  local node_name="$1"
  local src_file="$2"
  local dest_path="$3"
  
  # Verify node exists
  if ! node_exists "$node_name"; then
    echo -e "${RED}Error: Node '$node_name' not found in the database.${NC}"
    return 1
  fi
  
  # Get node connection details
  local node_data=$(get_node_data "$node_name")
  local host=$(echo "$node_data" | jq -r '.ip')
  local username=$(echo "$node_data" | jq -r '.username')
  local port=$(echo "$node_data" | jq -r '.port')
  
  echo -e "${BLUE}Deploying to node:${NC} $node_name ($username@$host:$port)"
  
  # Verify source file exists
  if [[ ! -f "$src_file" ]]; then
    echo -e "${RED}Error: Source file '$src_file' not found.${NC}"
    return 1
  fi
  
  # Transfer the file
  echo -e "${YELLOW}Copying:${NC} $src_file -> $dest_path"
  scp -i "$KEY_FILE" -P "$port" "$src_file" "$username@$host:$dest_path"
  local status=$?
  
  if [[ $status -eq 0 ]]; then
    echo -e "${GREEN}Successfully deployed file to $node_name.${NC}"
  else
    echo -e "${RED}Failed to deploy file to $node_name. Error code: $status${NC}"
  fi
  
  return $status
}

# Deploy a file to multiple nodes
deploy_file() {
  local src_file="$1"
  shift
  local dest_path="$1"
  shift
  local target_nodes=("$@")
  
  # If no specific nodes are provided, use all nodes
  if [[ ${#target_nodes[@]} -eq 0 ]]; then
    target_nodes=($(list_node_names))
  fi
  
  if [[ ${#target_nodes[@]} -eq 0 ]]; then
    echo -e "${YELLOW}No nodes are registered. Use 'pop --fleet register' to add nodes.${NC}"
    return 1
  fi
  
  local success_count=0
  local failed_nodes=()
  
  echo -e "${CYAN}=== DEPLOYMENT TO MULTIPLE NODES ===${NC}"
  echo -e "Source file: $src_file"
  echo -e "Destination: $dest_path"
  echo -e "Target nodes: ${target_nodes[*]}"
  echo
  
  # Deploy to each node
  for node in "${target_nodes[@]}"; do
    deploy_to_node "$node" "$src_file" "$dest_path"
    if [[ $? -eq 0 ]]; then
      ((success_count++))
    else
      failed_nodes+=("$node")
    fi
  done
  
  # Summary
  echo
  echo -e "${CYAN}Deployment Summary:${NC}"
  echo -e "Total nodes: ${#target_nodes[@]}"
  echo -e "Successful: $success_count"
  echo -e "Failed: ${#failed_nodes[@]}"
  
  if [[ ${#failed_nodes[@]} -gt 0 ]]; then
    echo -e "${RED}Failed nodes: ${failed_nodes[*]}${NC}"
    return 1
  fi
  
  return 0
}

# Deploy a folder to a node
deploy_folder() {
  local node_name="$1"
  local src_folder="$2"
  local dest_path="$3"
  
  # Verify node exists
  if ! node_exists "$node_name"; then
    echo -e "${RED}Error: Node '$node_name' not found in the database.${NC}"
    return 1
  fi
  
  # Get node connection details
  local node_data=$(get_node_data "$node_name")
  local host=$(echo "$node_data" | jq -r '.ip')
  local username=$(echo "$node_data" | jq -r '.username')
  local port=$(echo "$node_data" | jq -r '.port')
  
  echo -e "${BLUE}Deploying folder to node:${NC} $node_name ($username@$host:$port)"
  
  # Verify source folder exists
  if [[ ! -d "$src_folder" ]]; then
    echo -e "${RED}Error: Source folder '$src_folder' not found.${NC}"
    return 1
  fi
  
  # Transfer the folder using rsync if available, otherwise use scp -r
  echo -e "${YELLOW}Copying folder:${NC} $src_folder -> $dest_path"
  
  if command -v rsync &>/dev/null; then
    rsync -avz -e "ssh -i '$KEY_FILE' -p $port" "$src_folder" "$username@$host:$dest_path"
  else
    scp -i "$KEY_FILE" -P "$port" -r "$src_folder" "$username@$host:$dest_path"
  fi
  
  local status=$?
  
  if [[ $status -eq 0 ]]; then
    echo -e "${GREEN}Successfully deployed folder to $node_name.${NC}"
  else
    echo -e "${RED}Failed to deploy folder to $node_name. Error code: $status${NC}"
  fi
  
  return $status
}

# Main entry point for deploy commands
deploy_command() {
  local src_path="$1"
  local dest_path="$2"
  shift 2
  local target_nodes=("$@")
  
  # Check if source is a file or directory
  if [[ -f "$src_path" ]]; then
    deploy_file "$src_path" "$dest_path" "${target_nodes[@]}"
  elif [[ -d "$src_path" ]]; then
    if [[ ${#target_nodes[@]} -eq 0 ]]; then
      echo -e "${RED}Error: You must specify at least one target node for folder deployment.${NC}"
      return 1
    fi
    
    for node in "${target_nodes[@]}"; do
      deploy_folder "$node" "$src_path" "$dest_path"
    done
  else
    echo -e "${RED}Error: Source path '$src_path' not found.${NC}"
    return 1
  fi
}

# If this script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  deploy_command "$@"
fi
