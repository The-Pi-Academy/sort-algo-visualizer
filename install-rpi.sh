#!/bin/bash

################################################################################
# Raspberry Pi 4B Installation Script for Sort Algorithm Visualizer
#
# This script installs all dependencies for both C++ and Rust implementations.
# It is idempotent and can be safely run multiple times.
################################################################################

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

################################################################################
# Validation: Check if running on Raspberry Pi 4B
################################################################################

validate_hardware() {
    log_info "Validating hardware and architecture..."

    # Check if running on Linux
    if [[ "$(uname -s)" != "Linux" ]]; then
        log_error "This script is designed for Raspberry Pi OS (Linux)."
        log_error "Detected OS: $(uname -s)"
        exit 1
    fi

    # Check CPU architecture (should be ARM)
    ARCH=$(uname -m)
    if [[ ! "$ARCH" =~ ^(armv7l|aarch64|arm64)$ ]]; then
        log_error "This script requires ARM architecture (Raspberry Pi)."
        log_error "Detected architecture: $ARCH"
        exit 1
    fi

    # Check if running on Raspberry Pi by looking for specific hardware info
    if [[ -f /proc/device-tree/model ]]; then
        MODEL=$(cat /proc/device-tree/model)
        log_info "Detected hardware: $MODEL"

        # Validate it's a Raspberry Pi 4 Model B
        if [[ ! "$MODEL" =~ "Raspberry Pi 4" ]]; then
            log_warning "This script is optimized for Raspberry Pi 4 Model B."
            log_warning "Detected: $MODEL"
            read -p "Continue anyway? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                log_info "Installation cancelled."
                exit 0
            fi
        fi
    else
        log_warning "Could not detect Raspberry Pi model. Proceeding with caution..."
    fi

    log_success "Hardware validation passed (Architecture: $ARCH)"
}

################################################################################
# Update package lists
################################################################################

update_package_lists() {
    log_info "Updating package lists..."
    sudo apt-get update -qq
    log_success "Package lists updated"
}

################################################################################
# Install C++ dependencies (delegates to cpp/install-rpi.sh)
################################################################################

install_cpp_dependencies() {
    log_info "Installing C++ dependencies..."

    if [[ -f "cpp/install-rpi.sh" ]]; then
        source cpp/install-rpi.sh
    else
        log_error "cpp/install-rpi.sh not found"
        exit 1
    fi
}

################################################################################
# Install Rust and its dependencies (delegates to rust/install-rpi.sh)
################################################################################

install_rust_dependencies() {
    log_info "Installing Rust dependencies..."

    if [[ -f "rust/install-rpi.sh" ]]; then
        source rust/install-rpi.sh
    else
        log_error "rust/install-rpi.sh not found"
        exit 1
    fi
}

################################################################################
# Verify installations (verification done by delegated scripts)
################################################################################

verify_installations() {
    log_success "All dependencies installed and verified"
}

################################################################################
# Display next steps
################################################################################

show_next_steps() {
    echo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_success "Installation complete!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    echo "Next steps:"
    echo
    echo "1. Source Rust environment (for current session):"
    echo "   ${GREEN}source \$HOME/.cargo/env${NC}"
    echo
    echo "2. Run C++ version only:"
    echo "   ${GREEN}cd cpp && ./run-rpi.sh bubble${NC}"
    echo
    echo "3. Run Rust version only:"
    echo "   ${GREEN}cd rust && ./run-rpi.sh bubble${NC}"
    echo
    echo "4. Run side-by-side comparison (both C++ and Rust):"
    echo "   ${GREEN}./run-rpi.sh bubble${NC}"
    echo
    echo "5. Run only C++ or only Rust from top level:"
    echo "   ${GREEN}./run-rpi.sh --cpp bubble${NC}"
    echo "   ${GREEN}./run-rpi.sh --rust bubble${NC}"
    echo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo

    # Check if Rust env needs sourcing
    if ! command -v cargo &> /dev/null; then
        log_warning "Remember to run: source \$HOME/.cargo/env"
    fi
}

################################################################################
# Main installation flow
################################################################################

main() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Raspberry Pi 4B - Sort Algorithm Visualizer Installer"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo

    validate_hardware
    echo
    update_package_lists
    echo
    install_cpp_dependencies
    echo
    install_rust_dependencies
    echo
    verify_installations
    echo
    show_next_steps
}

# Run main installation
main
