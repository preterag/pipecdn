#!/usr/bin/env python3
"""
System compatibility check utility for Pipe Network PoP Node.
This module provides functions to check if the system meets the requirements
for running a Pipe Network PoP Node.
"""

import os
import sys
import platform
import shutil
import subprocess
import logging
import socket
import urllib.request
import json
from typing import Dict, Any, Tuple, List, Optional
import re

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger("system_check")

# Constants
MIN_MEMORY_MB = 2048  # 2 GB
MIN_DISK_SPACE_GB = 20  # 20 GB
REQUIRED_PORTS = [4500, 8585]  # Default ports
REQUIRED_COMMANDS = ["python3", "curl", "ip", "iptables"]


def check_os_compatibility() -> Tuple[bool, str]:
    """
    Check if the operating system is compatible.
    
    Returns:
        Tuple[bool, str]: (is_compatible, message)
    """
    system = platform.system()
    
    if system == "Linux":
        # Check Linux distribution and version
        try:
            # Try to get more detailed distribution info
            distro_info = {}
            
            if os.path.exists("/etc/os-release"):
                with open("/etc/os-release", "r") as f:
                    for line in f:
                        if "=" in line:
                            key, value = line.strip().split("=", 1)
                            distro_info[key] = value.strip('"')
            
            if "ID" in distro_info:
                distro_id = distro_info["ID"]
                version = distro_info.get("VERSION_ID", "unknown")
                
                # Check for recommended distributions
                if distro_id in ["ubuntu", "debian", "fedora", "centos", "rhel"]:
                    return True, f"Compatible Linux distribution: {distro_id.capitalize()} {version}"
                else:
                    return True, f"Linux distribution {distro_id.capitalize()} {version} should work but is not officially tested"
            else:
                # If we can't determine the distro, just check if it's Linux
                return True, f"Linux detected: {platform.platform()}"
        
        except Exception as e:
            logger.error(f"Error checking Linux distribution: {str(e)}")
            return True, "Linux detected, but could not determine distribution"
    
    elif system == "Darwin":  # macOS
        return False, f"macOS ({platform.mac_ver()[0]}) is not officially supported for production use"
    
    elif system == "Windows":
        return False, "Windows is not supported for Pipe Network PoP Node"
    
    else:
        return False, f"Unsupported operating system: {system}"


def check_memory() -> Tuple[bool, str]:
    """
    Check if the system has enough memory.
    
    Returns:
        Tuple[bool, str]: (has_enough_memory, message)
    """
    try:
        # Try platform-specific methods first
        if platform.system() == "Linux":
            with open("/proc/meminfo", "r") as f:
                mem_info = {}
                for line in f:
                    key, value = line.split(":", 1)
                    mem_info[key.strip()] = int(re.sub(r'[^\d]', '', value.strip())) * 1024  # Convert to bytes
            
            total_memory_mb = mem_info.get("MemTotal", 0) // (1024 * 1024)
            
        elif platform.system() == "Darwin":  # macOS
            output = subprocess.check_output(["sysctl", "-n", "hw.memsize"]).decode().strip()
            total_memory_mb = int(output) // (1024 * 1024)
            
        elif platform.system() == "Windows":
            output = subprocess.check_output(["wmic", "computersystem", "get", "totalphysicalmemory"]).decode()
            total_memory_mb = int(output.split('\n')[1].strip()) // (1024 * 1024)
            
        else:
            # Fallback to psutil if available
            try:
                import psutil
                total_memory_mb = psutil.virtual_memory().total // (1024 * 1024)
            except ImportError:
                return False, "Could not determine system memory"
        
        if total_memory_mb >= MIN_MEMORY_MB:
            return True, f"Memory: {total_memory_mb} MB (minimum: {MIN_MEMORY_MB} MB)"
        else:
            return False, f"Insufficient memory: {total_memory_mb} MB (minimum: {MIN_MEMORY_MB} MB)"
            
    except Exception as e:
        logger.error(f"Error checking memory: {str(e)}")
        return False, f"Error checking memory: {str(e)}"


def check_disk_space(directory: str = "/") -> Tuple[bool, str]:
    """
    Check if there is enough disk space in the specified directory.
    
    Args:
        directory (str): Directory to check
    
    Returns:
        Tuple[bool, str]: (has_enough_space, message)
    """
    try:
        # Get disk usage for the directory
        total, used, free = shutil.disk_usage(directory)
        
        # Convert to GB
        free_gb = free / (1024 * 1024 * 1024)
        total_gb = total / (1024 * 1024 * 1024)
        
        if free_gb >= MIN_DISK_SPACE_GB:
            return True, f"Disk space: {free_gb:.1f} GB free of {total_gb:.1f} GB total (minimum: {MIN_DISK_SPACE_GB} GB)"
        else:
            return False, f"Insufficient disk space: {free_gb:.1f} GB free (minimum: {MIN_DISK_SPACE_GB} GB)"
            
    except Exception as e:
        logger.error(f"Error checking disk space: {str(e)}")
        return False, f"Error checking disk space: {str(e)}"


def check_network_connectivity() -> Tuple[bool, str]:
    """
    Check network connectivity.
    
    Returns:
        Tuple[bool, str]: (has_connectivity, message)
    """
    # Check internet connectivity
    try:
        # Try to connect to a reliable host
        urllib.request.urlopen("https://www.google.com", timeout=5)
        internet_connectivity = True
        internet_message = "Internet connectivity: OK"
    except Exception:
        try:
            # Try another host in case the first one is blocked
            urllib.request.urlopen("https://www.cloudflare.com", timeout=5)
            internet_connectivity = True
            internet_message = "Internet connectivity: OK"
        except Exception as e:
            internet_connectivity = False
            internet_message = f"No internet connectivity: {str(e)}"
    
    # Try to get public IP address
    try:
        response = urllib.request.urlopen("https://api.ipify.org?format=json", timeout=5)
        data = json.loads(response.read().decode())
        public_ip = data.get("ip", "unknown")
        ip_message = f"Public IP: {public_ip}"
    except Exception:
        public_ip = "unknown"
        ip_message = "Could not determine public IP address"
    
    # Check if the required ports are available
    open_ports = []
    closed_ports = []
    
    for port in REQUIRED_PORTS:
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(1)
            result = sock.connect_ex(('127.0.0.1', port))
            sock.close()
            
            if result == 0:
                closed_ports.append(port)
            else:
                open_ports.append(port)
        except Exception:
            open_ports.append(port)  # Assume port is available if we couldn't check
    
    if closed_ports:
        port_message = f"Ports already in use: {', '.join(map(str, closed_ports))}"
        port_check = False
    else:
        port_message = f"Required ports are available: {', '.join(map(str, REQUIRED_PORTS))}"
        port_check = True
    
    # Combine results
    is_ok = internet_connectivity and port_check
    message = f"{internet_message}. {ip_message}. {port_message}"
    
    return is_ok, message


def check_dependencies() -> Tuple[bool, str]:
    """
    Check if required dependencies are installed.
    
    Returns:
        Tuple[bool, str]: (has_dependencies, message)
    """
    missing_commands = []
    
    for cmd in REQUIRED_COMMANDS:
        if not shutil.which(cmd):
            missing_commands.append(cmd)
    
    if missing_commands:
        return False, f"Missing dependencies: {', '.join(missing_commands)}"
    else:
        return True, f"All required dependencies are installed: {', '.join(REQUIRED_COMMANDS)}"


def check_system() -> Dict[str, Any]:
    """
    Perform all system checks and return the results.
    
    Returns:
        Dict[str, Any]: Dictionary with check results
    """
    results = {
        "timestamp": platform.node(),
        "system_info": {
            "hostname": platform.node(),
            "system": platform.system(),
            "release": platform.release(),
            "version": platform.version(),
            "processor": platform.processor(),
            "architecture": platform.architecture()[0]
        }
    }
    
    # Perform checks
    os_ok, os_message = check_os_compatibility()
    memory_ok, memory_message = check_memory()
    disk_ok, disk_message = check_disk_space()
    network_ok, network_message = check_network_connectivity()
    dependencies_ok, dependencies_message = check_dependencies()
    
    # Store results
    results["os"] = os_ok
    results["os_message"] = os_message
    
    results["memory"] = memory_ok
    results["memory_message"] = memory_message
    
    results["disk"] = disk_ok
    results["disk_message"] = disk_message
    
    results["network"] = network_ok
    results["network_message"] = network_message
    
    results["dependencies"] = dependencies_ok
    results["dependencies_message"] = dependencies_message
    
    # Overall result
    results["all_checks_passed"] = os_ok and memory_ok and disk_ok and network_ok and dependencies_ok
    
    return results


def get_installation_recommendations(check_results: Dict[str, Any]) -> List[str]:
    """
    Generate recommendations based on system check results.
    
    Args:
        check_results (Dict[str, Any]): Results from check_system()
    
    Returns:
        List[str]: List of recommendations
    """
    recommendations = []
    
    if not check_results.get("os", False):
        recommendations.append("Consider using a supported Linux distribution (Ubuntu 20.04+ recommended)")
    
    if not check_results.get("memory", False):
        recommendations.append(f"Increase system memory to at least {MIN_MEMORY_MB} MB for optimal performance")
    
    if not check_results.get("disk", False):
        recommendations.append(f"Ensure at least {MIN_DISK_SPACE_GB} GB of free disk space is available")
    
    if not check_results.get("network", False):
        if "already in use" in check_results.get("network_message", ""):
            ports = re.findall(r'Ports already in use: ([\d, ]+)', check_results.get("network_message", ""))
            if ports:
                recommendations.append(f"Free up the following ports: {ports[0]}")
        
        if "No internet connectivity" in check_results.get("network_message", ""):
            recommendations.append("Ensure the system has a working internet connection")
    
    if not check_results.get("dependencies", False):
        missing = re.findall(r'Missing dependencies: ([\w, ]+)', check_results.get("dependencies_message", ""))
        if missing:
            recommendations.append(f"Install missing dependencies: {missing[0]}")
    
    return recommendations


if __name__ == "__main__":
    print("Running Pipe Network PoP Node System Compatibility Check...\n")
    
    results = check_system()
    
    print("\n=== System Check Results ===\n")
    
    if results["all_checks_passed"]:
        print("✅ All checks passed! This system meets the requirements for running a Pipe Network PoP Node.\n")
    else:
        print("⚠️ Some checks failed. This system may not meet all requirements for optimal performance.\n")
    
    print(f"Operating System: {'✅' if results['os'] else '❌'} {results['os_message']}")
    print(f"Memory: {'✅' if results['memory'] else '❌'} {results['memory_message']}")
    print(f"Disk Space: {'✅' if results['disk'] else '❌'} {results['disk_message']}")
    print(f"Network: {'✅' if results['network'] else '❌'} {results['network_message']}")
    print(f"Dependencies: {'✅' if results['dependencies'] else '❌'} {results['dependencies_message']}")
    
    recommendations = get_installation_recommendations(results)
    if recommendations:
        print("\n=== Recommendations ===\n")
        for i, rec in enumerate(recommendations, 1):
            print(f"{i}. {rec}") 