#!/bin/bash

# Pipe PoP Node Package Testing Script
# Version: 1.0.0
#
# This script helps test the installation packages for the Pipe PoP node
# across different Linux distributions using Docker containers.
#
# Contributors:
# - Preterag Team (original implementation)

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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
    echo -e "${BLUE}==== $1 ====${NC}"
}

print_highlight() {
    echo -e "${CYAN}$1${NC}"
}

# Display version information
print_header "Pipe PoP Package Testing Tool v1.0.0"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. This script requires Docker to test packages in isolated environments."
    print_message "Please install Docker and try again: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_warning "This script is not running as root. Docker commands may fail."
    read -p "Continue anyway? (y/n): " continue_anyway
    if [[ ! "$continue_anyway" =~ ^[Yy]$ ]]; then
        print_message "Exiting. Please run with sudo if you encounter permission issues."
        exit 0
    fi
fi

# Set variables
WORKSPACE_DIR="$(pwd)"
RELEASE_DIR="${WORKSPACE_DIR}/installers/v1.0.0"
VERSION="1.0.0"
PACKAGE_NAME="pipe-pop-node"
FULL_PACKAGE_NAME="${PACKAGE_NAME}-${VERSION}"

# Check if release directory exists
if [ ! -d "${RELEASE_DIR}" ]; then
    print_error "Release directory not found: ${RELEASE_DIR}"
    print_message "Please run create_packages.sh first to generate the packages."
    exit 1
fi

# Define distributions to test
declare -A distributions=(
    ["debian"]="Debian 11 (Bullseye)"
    ["ubuntu"]="Ubuntu 22.04 (Jammy)"
    ["fedora"]="Fedora 36"
    ["centos"]="CentOS Stream 9"
    ["alpine"]="Alpine Linux 3.16"
    ["arch"]="Arch Linux"
)

# Define Docker images for each distribution
declare -A docker_images=(
    ["debian"]="debian:bullseye"
    ["ubuntu"]="ubuntu:22.04"
    ["fedora"]="fedora:36"
    ["centos"]="quay.io/centos/centos:stream9"
    ["alpine"]="alpine:3.16"
    ["arch"]="archlinux:latest"
)

# Define package types for each distribution
declare -A package_types=(
    ["debian"]="deb"
    ["ubuntu"]="deb"
    ["fedora"]="rpm"
    ["centos"]="rpm"
    ["alpine"]="appimage"
    ["arch"]="appimage"
)

# Define installation commands for each package type
declare -A install_commands=(
    ["deb"]="apt-get update && apt-get install -y ./pipe-pop-node_${VERSION}_amd64.deb"
    ["rpm"]="dnf install -y ./pipe-pop-node-${VERSION}-1.x86_64.rpm"
    ["appimage"]="chmod +x ./pipe-pop-node-${VERSION}-x86_64.AppImage && ./pipe-pop-node-${VERSION}-x86_64.AppImage --help"
    ["source"]="tar -xzf pipe-pop-node-${VERSION}-source.tar.gz && cd pipe-pop-node-${VERSION} && ./easy_setup.sh --help"
)

# Define verification commands
VERIFY_COMMAND="pop --help"

# Function to test a package on a specific distribution
test_package() {
    local distro=$1
    local distro_name="${distributions[$distro]}"
    local docker_image="${docker_images[$distro]}"
    local package_type="${package_types[$distro]}"
    local install_command="${install_commands[$package_type]}"
    
    print_header "Testing on ${distro_name}"
    
    # Check if the package exists
    local package_file=""
    case $package_type in
        deb)
            package_file="${RELEASE_DIR}/pipe-pop-node_${VERSION}_amd64.deb"
            ;;
        rpm)
            package_file="${RELEASE_DIR}/pipe-pop-node-${VERSION}-1.x86_64.rpm"
            ;;
        appimage)
            package_file="${RELEASE_DIR}/pipe-pop-node-${VERSION}-x86_64.AppImage"
            ;;
        source)
            package_file="${RELEASE_DIR}/pipe-pop-node-${VERSION}-source.tar.gz"
            ;;
    esac
    
    if [ ! -f "$package_file" ]; then
        print_warning "Package file not found: $package_file"
        print_message "Skipping test for ${distro_name}"
        return 1
    fi
    
    print_message "Using Docker image: ${docker_image}"
    print_message "Package type: ${package_type}"
    print_message "Package file: $(basename "$package_file")"
    
    # Create a temporary Dockerfile
    local temp_dir=$(mktemp -d)
    local dockerfile="${temp_dir}/Dockerfile"
    
    cat > "$dockerfile" << EOF
FROM ${docker_image}
WORKDIR /app
COPY $(basename "$package_file") .
RUN if command -v apt-get &> /dev/null; then apt-get update && apt-get install -y curl; fi
RUN if command -v dnf &> /dev/null; then dnf install -y curl; fi
RUN if command -v apk &> /dev/null; then apk add --no-cache curl bash; fi
RUN if command -v pacman &> /dev/null; then pacman -Sy --noconfirm curl; fi
RUN ${install_command}
CMD ["${VERIFY_COMMAND}"]
EOF
    
    # Build and run the Docker container
    print_message "Building Docker container..."
    docker build -t "pipe-pop-test-${distro}" -f "$dockerfile" --build-arg package_file="$package_file" "$RELEASE_DIR" > /dev/null 2>&1
    
    if [ $? -ne 0 ]; then
        print_error "Failed to build Docker container for ${distro_name}"
        return 1
    fi
    
    print_message "Running installation test..."
    docker run --rm "pipe-pop-test-${distro}" > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        print_highlight "✅ Test PASSED for ${distro_name}"
        return 0
    else
        print_error "❌ Test FAILED for ${distro_name}"
        return 1
    fi
}

# Function to test the source package
test_source_package() {
    print_header "Testing Source Package"
    
    local package_file="${RELEASE_DIR}/pipe-pop-node-${VERSION}-source.tar.gz"
    
    if [ ! -f "$package_file" ]; then
        print_warning "Source package file not found: $package_file"
        return 1
    fi
    
    print_message "Using Docker image: ubuntu:22.04"
    print_message "Package file: $(basename "$package_file")"
    
    # Create a temporary Dockerfile
    local temp_dir=$(mktemp -d)
    local dockerfile="${temp_dir}/Dockerfile"
    
    cat > "$dockerfile" << EOF
FROM ubuntu:22.04
WORKDIR /app
COPY $(basename "$package_file") .
RUN apt-get update && apt-get install -y curl tar
RUN tar -xzf pipe-pop-node-${VERSION}-source.tar.gz
WORKDIR /app/pipe-pop-node-${VERSION}
RUN ./easy_setup.sh --help
CMD ["ls", "-la"]
EOF
    
    # Build and run the Docker container
    print_message "Building Docker container..."
    docker build -t "pipe-pop-test-source" -f "$dockerfile" "$RELEASE_DIR" > /dev/null 2>&1
    
    if [ $? -ne 0 ]; then
        print_error "Failed to build Docker container for source package"
        return 1
    fi
    
    print_message "Running installation test..."
    docker run --rm "pipe-pop-test-source" > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        print_highlight "✅ Test PASSED for source package"
        return 0
    else
        print_error "❌ Test FAILED for source package"
        return 1
    fi
}

# Main testing loop
print_header "Starting Package Tests"

# Track test results
declare -A test_results
total_tests=0
passed_tests=0

# Test each distribution
for distro in "${!distributions[@]}"; do
    test_package "$distro"
    test_results[$distro]=$?
    total_tests=$((total_tests + 1))
    if [ ${test_results[$distro]} -eq 0 ]; then
        passed_tests=$((passed_tests + 1))
    fi
done

# Test source package
test_source_package
test_results["source"]=$?
total_tests=$((total_tests + 1))
if [ ${test_results["source"]} -eq 0 ]; then
    passed_tests=$((passed_tests + 1))
fi

# Display summary
print_header "Test Summary"
print_message "Total tests: $total_tests"
print_message "Passed tests: $passed_tests"
print_message "Failed tests: $((total_tests - passed_tests))"

for distro in "${!test_results[@]}"; do
    if [ "$distro" == "source" ]; then
        distro_name="Source Package"
    else
        distro_name="${distributions[$distro]}"
    fi
    
    if [ ${test_results[$distro]} -eq 0 ]; then
        print_highlight "✅ ${distro_name}: PASSED"
    else
        print_error "❌ ${distro_name}: FAILED"
    fi
done

# Final message
if [ $passed_tests -eq $total_tests ]; then
    print_header "All Tests Passed! 🎉"
    print_message "The packages are ready for distribution."
else
    print_header "Some Tests Failed! ⚠️"
    print_message "Please review the failed tests and fix any issues before distribution."
fi

# Cleanup
print_message "Cleaning up Docker images..."
for distro in "${!distributions[@]}"; do
    docker rmi "pipe-pop-test-${distro}" > /dev/null 2>&1
done
docker rmi "pipe-pop-test-source" > /dev/null 2>&1

print_message "Testing complete!" 