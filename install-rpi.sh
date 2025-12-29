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
# Install C++ dependencies (SDL2, CMake, build tools)
################################################################################

install_cpp_dependencies() {
    log_info "Installing C++ dependencies..."

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
        if dpkg -l | grep -q "^ii  $pkg "; then
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
        sudo apt-get install -y "${PACKAGES_TO_INSTALL[@]}"
        log_success "C++ dependencies installed"
    fi

    # Verify CMake version
    CMAKE_VERSION=$(cmake --version | head -n1 | awk '{print $3}')
    log_info "CMake version: $CMAKE_VERSION"
}

################################################################################
# Install Rust and its dependencies
################################################################################

install_rust_dependencies() {
    log_info "Installing Rust dependencies..."

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

    # Install ALSA development libraries (required for rodio audio)
    if dpkg -l | grep -q "^ii  libasound2-dev "; then
        log_info "  ✓ libasound2-dev already installed"
    else
        log_info "Installing ALSA development libraries..."
        sudo apt-get install -y libasound2-dev
        log_success "ALSA development libraries installed"
    fi

    # Verify cargo
    CARGO_VERSION=$(cargo --version)
    log_info "Cargo version: $CARGO_VERSION"
}

################################################################################
# Verify installations
################################################################################

verify_installations() {
    log_info "Verifying installations..."

    VERIFICATION_FAILED=0

    # Check C++ tools
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
    if pkg-config --exists sdl2; then
        log_info "  ✓ SDL2 $(pkg-config --modversion sdl2)"
    else
        log_error "  ✗ SDL2 not found"
        VERIFICATION_FAILED=1
    fi

    if pkg-config --exists SDL2_mixer; then
        log_info "  ✓ SDL2_mixer $(pkg-config --modversion SDL2_mixer)"
    else
        log_error "  ✗ SDL2_mixer not found"
        VERIFICATION_FAILED=1
    fi

    if pkg-config --exists SDL2_ttf; then
        log_info "  ✓ SDL2_ttf $(pkg-config --modversion SDL2_ttf)"
    else
        log_error "  ✗ SDL2_ttf not found"
        VERIFICATION_FAILED=1
    fi

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
    if pkg-config --exists alsa; then
        log_info "  ✓ ALSA $(pkg-config --modversion alsa)"
    else
        log_error "  ✗ ALSA development libraries not found"
        VERIFICATION_FAILED=1
    fi

    if [ $VERIFICATION_FAILED -eq 1 ]; then
        log_error "Some dependencies are missing. Please review the errors above."
        exit 1
    fi

    log_success "All dependencies verified successfully"
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
    echo "2. Build the C++ version:"
    echo "   ${GREEN}cd cpp${NC}"
    echo "   ${GREEN}mkdir -p cmake-build-debug && cd cmake-build-debug${NC}"
    echo "   ${GREEN}cmake .. && make${NC}"
    echo "   ${GREEN}./sort_visualizer bubble${NC}"
    echo
    echo "3. Build and run the Rust version:"
    echo "   ${GREEN}cd rust${NC}"
    echo "   ${GREEN}cargo run --release -- bubble${NC}"
    echo
    echo "4. Run side-by-side comparison:"
    echo "   ${GREEN}./run_comparison.sh bubble${NC}"
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
