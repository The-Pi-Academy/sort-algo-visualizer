#!/bin/bash

################################################################################
# Sorting Visualizer Runner for Raspberry Pi
#
# Runs C++, Rust, or both implementations side-by-side
#
# Usage:
#   ./run-rpi.sh <algorithm>              # Run both (default)
#   ./run-rpi.sh --both <algorithm>       # Run both explicitly
#   ./run-rpi.sh --cpp <algorithm>        # Run C++ only
#   ./run-rpi.sh --rust <algorithm>       # Run Rust only
#
# Available algorithms: bubble, selection
################################################################################

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

################################################################################
# Parse arguments
################################################################################

MODE="both"  # Default to running both
ALGORITHM=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --cpp)
            MODE="cpp"
            shift
            ;;
        --rust)
            MODE="rust"
            shift
            ;;
        --both)
            MODE="both"
            shift
            ;;
        bubble|selection)
            ALGORITHM=$1
            shift
            ;;
        *)
            echo "╔════════════════════════════════════════╗"
            echo "║  SORTING VISUALIZER RUNNER (RPi)       ║"
            echo "╚════════════════════════════════════════╝"
            echo ""
            echo "Usage:"
            echo "  $0 <algorithm>              # Run both (default)"
            echo "  $0 --both <algorithm>       # Run both explicitly"
            echo "  $0 --cpp <algorithm>        # Run C++ only"
            echo "  $0 --rust <algorithm>       # Run Rust only"
            echo ""
            echo "Available algorithms:"
            echo "  - bubble      Bubble Sort (O(n²))"
            echo "  - selection   Selection Sort (O(n²))"
            echo ""
            echo "Examples:"
            echo "  $0 bubble                  # Run both C++ and Rust"
            echo "  $0 --cpp selection         # Run C++ only"
            echo "  $0 --rust bubble           # Run Rust only"
            echo ""
            exit 1
            ;;
    esac
done

# Check if algorithm was provided
if [ -z "$ALGORITHM" ]; then
    echo -e "${RED}Error: No algorithm specified${NC}"
    echo ""
    echo "Usage: $0 [--cpp|--rust|--both] <algorithm>"
    echo "Available algorithms: bubble, selection"
    echo ""
    exit 1
fi

# Validate algorithm choice
case "$ALGORITHM" in
    bubble|selection)
        # Valid algorithm
        ;;
    *)
        echo -e "${RED}Error: Unknown algorithm '$ALGORITHM'${NC}"
        echo ""
        echo "Available algorithms:"
        echo "  - bubble"
        echo "  - selection"
        echo ""
        exit 1
        ;;
esac

################################################################################
# Run based on mode
################################################################################

echo "╔════════════════════════════════════════╗"
echo "║  SORTING VISUALIZER RUNNER (RPi)       ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo "Algorithm: $ALGORITHM"

case "$MODE" in
    cpp)
        echo "Mode: C++ only"
        echo ""

        # Delegate to cpp/run-rpi.sh
        if [ ! -f "cpp/run-rpi.sh" ]; then
            echo -e "${RED}Error: cpp/run-rpi.sh not found${NC}"
            exit 1
        fi

        cd cpp
        ./run-rpi.sh "$ALGORITHM"
        ;;

    rust)
        echo "Mode: Rust only"
        echo ""

        # Delegate to rust/run-rpi.sh
        if [ ! -f "rust/run-rpi.sh" ]; then
            echo -e "${RED}Error: rust/run-rpi.sh not found${NC}"
            exit 1
        fi

        cd rust
        ./run-rpi.sh "$ALGORITHM"
        ;;

    both)
        echo "Mode: Side-by-side comparison (C++ vs Rust)"
        echo ""

        # Build both projects
        echo -e "${BLUE}Building both projects...${NC}"
        echo ""

        # Build C++
        if [ ! -f "cpp/run-rpi.sh" ]; then
            echo -e "${RED}Error: cpp/run-rpi.sh not found${NC}"
            exit 1
        fi

        echo -e "${BLUE}→ Building C++ project...${NC}"
        (cd cpp && ./run-rpi.sh "$ALGORITHM" --no-build > /dev/null 2>&1 || ./run-rpi.sh --no-build > /dev/null 2>&1 || true)
        (cd cpp && mkdir -p cmake-build-debug && cd cmake-build-debug && cmake .. && cmake --build .) || {
            echo -e "${RED}Error: C++ build failed${NC}"
            exit 1
        }
        echo -e "${GREEN}  ✓ C++ build complete${NC}"
        echo ""

        # Build Rust
        if [ ! -f "rust/run-rpi.sh" ]; then
            echo -e "${RED}Error: rust/run-rpi.sh not found${NC}"
            exit 1
        fi

        echo -e "${BLUE}→ Building Rust project...${NC}"

        # Find cargo
        if command -v cargo &> /dev/null; then
            CARGO_CMD="cargo"
        elif [ -f "$HOME/.cargo/bin/cargo" ]; then
            source "$HOME/.cargo/env" 2>/dev/null || true
            CARGO_CMD="$HOME/.cargo/bin/cargo"
        else
            echo -e "${RED}Error: cargo not found. Please install Rust first.${NC}"
            echo "Run: ./install-rpi.sh"
            exit 1
        fi

        (cd rust && $CARGO_CMD build --release) || {
            echo -e "${RED}Error: Rust build failed${NC}"
            exit 1
        }
        echo -e "${GREEN}  ✓ Rust build complete${NC}"
        echo ""

        # Verify binaries exist
        CPP_BIN="./cpp/cmake-build-debug/sort_visualizer"
        RUST_BIN="./rust/target/release/sort_visualizer"

        if [ ! -f "$CPP_BIN" ]; then
            echo -e "${RED}Error: C++ binary not found at $CPP_BIN${NC}"
            exit 1
        fi

        if [ ! -f "$RUST_BIN" ]; then
            echo -e "${RED}Error: Rust binary not found at $RUST_BIN${NC}"
            exit 1
        fi

        echo -e "${GREEN}Both builds successful!${NC}"
        echo ""

        # Setup signal handler to kill both processes on Ctrl+C
        cleanup() {
            echo ""
            echo -e "${YELLOW}Stopping both visualizers...${NC}"

            # Kill C++ process
            if [ ! -z "$CPP_PID" ] && kill -0 $CPP_PID 2>/dev/null; then
                kill -TERM $CPP_PID 2>/dev/null || true
                sleep 0.5
                # Force kill if still running
                if kill -0 $CPP_PID 2>/dev/null; then
                    kill -KILL $CPP_PID 2>/dev/null || true
                fi
            fi

            # Kill Rust process
            if [ ! -z "$RUST_PID" ] && kill -0 $RUST_PID 2>/dev/null; then
                kill -TERM $RUST_PID 2>/dev/null || true
                sleep 0.5
                # Force kill if still running
                if kill -0 $RUST_PID 2>/dev/null; then
                    kill -KILL $RUST_PID 2>/dev/null || true
                fi
            fi

            echo -e "${GREEN}Both visualizers stopped${NC}"
            exit 0
        }

        trap cleanup SIGINT SIGTERM EXIT

        # Run both implementations in parallel
        echo -e "${BLUE}Starting C++ implementation (left side)...${NC}"
        $CPP_BIN $ALGORITHM > /dev/null 2>&1 &
        CPP_PID=$!

        # Small delay to let C++ window initialize
        sleep 0.5

        echo -e "${BLUE}Starting Rust implementation (right side)...${NC}"
        $RUST_BIN $ALGORITHM > /dev/null 2>&1 &
        RUST_PID=$!

        # Verify both processes started
        sleep 0.5
        if ! kill -0 $CPP_PID 2>/dev/null; then
            echo -e "${RED}Error: C++ process failed to start${NC}"
            cleanup
            exit 1
        fi

        if ! kill -0 $RUST_PID 2>/dev/null; then
            echo -e "${RED}Error: Rust process failed to start${NC}"
            cleanup
            exit 1
        fi

        echo ""
        echo -e "${GREEN}Both visualizers are running in parallel!${NC}"
        echo "Press Ctrl+C to stop both programs"
        echo ""
        echo "Process IDs:"
        echo "  C++:  $CPP_PID (running)"
        echo "  Rust: $RUST_PID (running)"
        echo ""

        # Wait for both processes
        wait $CPP_PID $RUST_PID

        echo ""
        echo -e "${GREEN}Comparison complete!${NC}"
        ;;
esac
