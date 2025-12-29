#!/bin/bash

################################################################################
# Rust Build and Run Script for Raspberry Pi
#
# Builds and runs the Rust implementation of the sorting visualizer on RPi.
# Usage: ./run-rpi.sh [algorithm] [--no-build] [--debug]
################################################################################

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[Rust]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[Rust]${NC} $1"
}

log_error() {
    echo -e "${RED}[Rust]${NC} $1"
}

################################################################################
# Parse arguments
################################################################################

ALGORITHM="bubble"
NO_BUILD=false
BUILD_MODE="release"

while [[ $# -gt 0 ]]; do
    case $1 in
        --no-build)
            NO_BUILD=true
            shift
            ;;
        --debug)
            BUILD_MODE="debug"
            shift
            ;;
        bubble|selection)
            ALGORITHM=$1
            shift
            ;;
        *)
            log_error "Unknown argument: $1"
            echo "Usage: $0 [algorithm] [--no-build] [--debug]"
            echo "Available algorithms: bubble, selection"
            exit 1
            ;;
    esac
done

################################################################################
# Find cargo
################################################################################

find_cargo() {
    if command -v cargo &> /dev/null; then
        CARGO_CMD="cargo"
    elif [ -f "$HOME/.cargo/bin/cargo" ]; then
        # Source cargo environment if not in PATH
        source "$HOME/.cargo/env" 2>/dev/null || true
        CARGO_CMD="$HOME/.cargo/bin/cargo"
    else
        log_error "cargo not found. Please install Rust first:"
        log_error "  ./install-rpi.sh"
        exit 1
    fi
}

################################################################################
# Build project
################################################################################

build_project() {
    log_info "Building Rust project ($BUILD_MODE mode)..."

    # Get script directory and navigate to rust root
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    cd "$SCRIPT_DIR"

    # Build based on mode
    if [ "$BUILD_MODE" = "release" ]; then
        $CARGO_CMD build --release || {
            log_error "Build failed"
            exit 1
        }
    else
        $CARGO_CMD build || {
            log_error "Build failed"
            exit 1
        }
    fi

    log_success "Build complete"
}

################################################################################
# Run visualizer
################################################################################

run_visualizer() {
    log_info "Running $ALGORITHM sort visualizer..."

    # Get script directory
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # Determine binary path based on build mode
    if [ "$BUILD_MODE" = "release" ]; then
        BIN_PATH="$SCRIPT_DIR/target/release/sort_visualizer"
    else
        BIN_PATH="$SCRIPT_DIR/target/debug/sort_visualizer"
    fi

    # Verify binary exists
    if [ ! -f "$BIN_PATH" ]; then
        log_error "Binary not found at $BIN_PATH"
        log_error "Run without --no-build flag to build first"
        exit 1
    fi

    # Run the visualizer
    "$BIN_PATH" "$ALGORITHM"
}

################################################################################
# Main
################################################################################

main() {
    find_cargo

    if [ "$NO_BUILD" = false ]; then
        build_project
        echo
    fi

    run_visualizer
}

main
