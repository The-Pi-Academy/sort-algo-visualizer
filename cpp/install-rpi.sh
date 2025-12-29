#!/bin/bash

################################################################################
# C++ Dependencies Installation Script for Raspberry Pi
#
# Installs all dependencies needed for the C++ (SDL2) implementation on RPi.
# Can be run standalone or called from the top-level install-rpi.sh script.
################################################################################

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[C++ INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[C++ SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[C++ ERROR]${NC} $1"
}

################################################################################
# Install C++ dependencies
################################################################################

install_dependencies() {
    log_info "Installing C++ dependencies for Raspberry Pi..."

    # List of required packages
    CPP_PACKAGES=(
        "build-essential"
        "cmake"
        "libsdl2-dev"
        "libsdl2-mixer-dev"
        "libsdl2-ttf-dev"
    )

    # Check which packages are already installed
    PACKAGES_TO_INSTALL=()
    for pkg in "${CPP_PACKAGES[@]}"; do
        if dpkg -l 2>/dev/null | grep -q "^ii  $pkg "; then
            log_info "  ✓ $pkg already installed"
        else
            PACKAGES_TO_INSTALL+=("$pkg")
        fi
    done

    # Install missing packages
    if [ ${#PACKAGES_TO_INSTALL[@]} -eq 0 ]; then
        log_success "All C++ dependencies already installed"
    else
        log_info "Installing: ${PACKAGES_TO_INSTALL[*]}"
        sudo apt-get update -qq
        sudo apt-get install -y "${PACKAGES_TO_INSTALL[@]}"
        log_success "C++ dependencies installed"
    fi
}

################################################################################
# Verify installation
################################################################################

verify_installation() {
    log_info "Verifying C++ dependencies..."

    VERIFICATION_FAILED=0

    # Check build tools
    if command -v g++ &> /dev/null; then
        log_info "  ✓ g++ $(g++ --version | head -n1 | awk '{print $NF}')"
    else
        log_error "  ✗ g++ not found"
        VERIFICATION_FAILED=1
    fi

    if command -v cmake &> /dev/null; then
        log_info "  ✓ cmake $(cmake --version | head -n1 | awk '{print $3}')"
    else
        log_error "  ✗ cmake not found"
        VERIFICATION_FAILED=1
    fi

    # Check SDL2 libraries
    if pkg-config --exists sdl2 2>/dev/null; then
        log_info "  ✓ SDL2 $(pkg-config --modversion sdl2)"
    else
        log_error "  ✗ SDL2 not found"
        VERIFICATION_FAILED=1
    fi

    if pkg-config --exists SDL2_mixer 2>/dev/null; then
        log_info "  ✓ SDL2_mixer $(pkg-config --modversion SDL2_mixer)"
    else
        log_error "  ✗ SDL2_mixer not found"
        VERIFICATION_FAILED=1
    fi

    if pkg-config --exists SDL2_ttf 2>/dev/null; then
        log_info "  ✓ SDL2_ttf $(pkg-config --modversion SDL2_ttf)"
    else
        log_error "  ✗ SDL2_ttf not found"
        VERIFICATION_FAILED=1
    fi

    if [ $VERIFICATION_FAILED -eq 1 ]; then
        log_error "Some dependencies are missing"
        exit 1
    fi

    log_success "All C++ dependencies verified"
}

################################################################################
# Main
################################################################################

main() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  C++ Dependencies Installation (RPi)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo

    install_dependencies
    echo
    verify_installation
    echo

    log_success "C++ setup complete!"
}

# Only run main if executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
