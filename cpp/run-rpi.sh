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
# Help text
################################################################################

show_help() {
    echo "Usage: $0 [algorithm] [options]"
    echo ""
    echo "Available algorithms:"
    echo "  bubble      Bubble Sort (O(n²))"
    echo "  selection   Selection Sort (O(n²))"
    echo ""
    echo "Options:"
    echo "  --size N      Array size (1-10000, default: 100)"
    echo "  --delay MS    Delay in milliseconds (0-1000, default: 10)"
    echo "  --no-build    Skip building, run existing binary"
    echo "  --help, -h    Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 bubble                       # Build and run bubble sort"
    echo "  $0 selection --size 500         # 500 elements"
    echo "  $0 bubble --no-build --delay 5  # Skip build, 5ms delay"
    echo ""
}

################################################################################
# Parse arguments
################################################################################

ALGORITHM="bubble"
NO_BUILD=false
EXTRA_ARGS=()

while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            show_help
            exit 0
            ;;
        --no-build)
            NO_BUILD=true
            shift
            ;;
        bubble|selection)
            ALGORITHM=$1
            shift
            ;;
        --size=*|--delay=*)
            EXTRA_ARGS+=("$1")
            shift
            ;;
        --size|--delay)
            EXTRA_ARGS+=("$1")
            if [[ $# -gt 1 ]]; then
                EXTRA_ARGS+=("$2")
                shift
            fi
            shift
            ;;
        *)
            log_error "Unknown argument: $1"
            echo ""
            show_help
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

    # Run the visualizer with algorithm and any extra arguments
    "$BIN_PATH" "$ALGORITHM" "${EXTRA_ARGS[@]}"
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
