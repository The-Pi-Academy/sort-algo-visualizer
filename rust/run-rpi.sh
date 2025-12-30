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
    echo "  --debug       Build in debug mode (default: release)"
    echo "  --help, -h    Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 bubble                        # Build and run bubble sort"
    echo "  $0 selection --size 500          # 500 elements"
    echo "  $0 bubble --debug --delay 5      # Debug build, 5ms delay"
    echo "  $0 selection --no-build          # Skip build"
    echo ""
}

################################################################################
# Parse arguments
################################################################################

ALGORITHM="bubble"
NO_BUILD=false
BUILD_MODE="release"
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
        --debug)
            BUILD_MODE="debug"
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

    # Run the visualizer with algorithm and any extra arguments
    "$BIN_PATH" "$ALGORITHM" "${EXTRA_ARGS[@]}"
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
