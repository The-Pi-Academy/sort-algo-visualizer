#!/bin/bash

################################################################################
# C++ Build and Run Script for Raspberry Pi
#
# Builds and runs the C++ implementation of the sorting visualizer on RPi.
# Usage: ./run-rpi.sh [algorithm] [--no-build]
################################################################################

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[C++]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[C++]${NC} $1"
}

log_error() {
    echo -e "${RED}[C++]${NC} $1"
}

################################################################################
# Parse arguments
################################################################################

ALGORITHM="bubble"
NO_BUILD=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --no-build)
            NO_BUILD=true
            shift
            ;;
        bubble|selection)
            ALGORITHM=$1
            shift
            ;;
        *)
            log_error "Unknown argument: $1"
            echo "Usage: $0 [algorithm] [--no-build]"
            echo "Available algorithms: bubble, selection"
            exit 1
            ;;
    esac
done

################################################################################
# Build project
################################################################################

build_project() {
    log_info "Building C++ project..."

    # Get script directory and navigate to cpp root
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    cd "$SCRIPT_DIR"

    # Create build directory if it doesn't exist
    if [ ! -d "cmake-build-debug" ]; then
        mkdir -p cmake-build-debug
    fi

    cd cmake-build-debug

    # Run CMake to generate build files
    log_info "Running CMake..."
    cmake .. || {
        log_error "CMake configuration failed"
        log_error "Make sure you have CMake and SDL2 installed"
        log_error "Run: ./install-rpi.sh"
        exit 1
    }

    # Build using cmake --build
    log_info "Compiling..."
    cmake --build . || {
        log_error "Build failed"
        exit 1
    }

    cd ..
    log_success "Build complete"
}

################################################################################
# Run visualizer
################################################################################

run_visualizer() {
    log_info "Running $ALGORITHM sort visualizer..."

    # Get script directory
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    BIN_PATH="$SCRIPT_DIR/cmake-build-debug/sort_visualizer"

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
    if [ "$NO_BUILD" = false ]; then
        build_project
        echo
    fi

    run_visualizer
}

main
