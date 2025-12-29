#!/bin/bash

################################################################################
# Rust Dependencies Installation Script for Raspberry Pi
#
# Installs all dependencies needed for the Rust (Macroquad) implementation on RPi.
# Can be run standalone or called from the top-level install-rpi.sh script.
################################################################################

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[Rust INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[Rust SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[Rust WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[Rust ERROR]${NC} $1"
}

################################################################################
# Install Rust toolchain
################################################################################

install_rust_toolchain() {
    log_info "Checking Rust installation..."

    # Check if Rust is already installed
    if command -v rustc &> /dev/null; then
        RUST_VERSION=$(rustc --version)
        log_info "  ✓ Rust already installed: $RUST_VERSION"

        # Update Rust to latest stable
        log_info "Updating Rust to latest stable version..."
        rustup update stable
        log_success "Rust updated"
    else
        log_info "Installing Rust via rustup..."

        # Install Rust using rustup (non-interactive)
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable

        # Source cargo environment
        source "$HOME/.cargo/env"

        RUST_VERSION=$(rustc --version)
        log_success "Rust installed: $RUST_VERSION"
    fi

    # Ensure cargo is in PATH for current session
    if ! command -v cargo &> /dev/null; then
        if [[ -f "$HOME/.cargo/env" ]]; then
            source "$HOME/.cargo/env"
        fi
    fi
}

################################################################################
# Install system dependencies
################################################################################

install_system_dependencies() {
    log_info "Installing system dependencies for Raspberry Pi..."

    # Install ALSA development libraries (required for rodio audio)
    if dpkg -l 2>/dev/null | grep -q "^ii  libasound2-dev "; then
        log_info "  ✓ libasound2-dev already installed"
    else
        log_info "Installing ALSA development libraries..."
        sudo apt-get update -qq
        sudo apt-get install -y libasound2-dev
        log_success "ALSA development libraries installed"
    fi
}

################################################################################
# Verify installation
################################################################################

verify_installation() {
    log_info "Verifying Rust dependencies..."

    VERIFICATION_FAILED=0

    # Check Rust tools
    if command -v rustc &> /dev/null; then
        log_info "  ✓ rustc $(rustc --version | awk '{print $2}')"
    else
        log_error "  ✗ rustc not found"
        VERIFICATION_FAILED=1
    fi

    if command -v cargo &> /dev/null; then
        log_info "  ✓ cargo $(cargo --version | awk '{print $2}')"
    else
        log_error "  ✗ cargo not found"
        VERIFICATION_FAILED=1
    fi

    # Check ALSA
    if pkg-config --exists alsa 2>/dev/null; then
        log_info "  ✓ ALSA $(pkg-config --modversion alsa)"
    else
        log_error "  ✗ ALSA development libraries not found"
        VERIFICATION_FAILED=1
    fi

    if [ $VERIFICATION_FAILED -eq 1 ]; then
        log_error "Some dependencies are missing"
        exit 1
    fi

    log_success "All Rust dependencies verified"
}

################################################################################
# Show environment setup instructions
################################################################################

show_env_instructions() {
    # Check if cargo is available in current shell
    if ! command -v cargo &> /dev/null; then
        echo
        log_warning "Cargo not found in current shell environment"
        log_info "Run the following command to add Rust to your PATH:"
        echo "  ${GREEN}source \$HOME/.cargo/env${NC}"
        echo
    fi
}

################################################################################
# Main
################################################################################

main() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Rust Dependencies Installation (RPi)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo

    install_rust_toolchain
    echo
    install_system_dependencies
    echo
    verify_installation
    echo

    log_success "Rust setup complete!"
    show_env_instructions
}

# Only run main if executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
