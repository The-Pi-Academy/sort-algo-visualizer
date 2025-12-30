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
# Help text
################################################################################

show_help() {
    echo "╔════════════════════════════════════════╗"
    echo "║  SORTING VISUALIZER RUNNER (RPi)       ║"
    echo "╚════════════════════════════════════════╝"
    echo ""
    echo "Usage:"
    echo "  $0 <algorithm> [options]              # Run both (default)"
    echo "  $0 --both <algorithm> [options]       # Run both explicitly"
    echo "  $0 --cpp <algorithm> [options]        # Run C++ only"
    echo "  $0 --rust <algorithm> [options]       # Run Rust only"
    echo ""
    echo "Available algorithms:"
    echo "  - bubble      Bubble Sort (O(n²))"
    echo "  - selection   Selection Sort (O(n²))"
    echo ""
    echo "Options:"
    echo "  --size N      Array size (1-10000, default: 100)"
    echo "  --delay MS    Delay in milliseconds (0-1000, default: 10)"
    echo "  --help, -h    Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 bubble                           # Run both with defaults"
    echo "  $0 bubble --size 500 --delay 5      # Custom size and delay"
    echo "  $0 --cpp selection --size 1000      # C++ only, 1000 elements"
    echo "  $0 --rust bubble --delay 1          # Rust only, 1ms delay"
    echo ""
}

################################################################################
# Parse arguments
################################################################################

MODE="both"  # Default to running both
ALGORITHM=""
ARRAY_SIZE=""
DELAY_MS=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            show_help
            exit 0
            ;;
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
        --size=*)
            ARRAY_SIZE="${1#*=}"
            shift
            ;;
        --size)
            ARRAY_SIZE="$2"
            shift 2
            ;;
        --delay=*)
            DELAY_MS="${1#*=}"
            shift
            ;;
        --delay)
            DELAY_MS="$2"
            shift 2
            ;;
        *)
            echo -e "${RED}Error: Unknown argument '$1'${NC}"
            echo ""
            show_help
            exit 1
            ;;
    esac
done

# Check if algorithm was provided
if [ -z "$ALGORITHM" ]; then
    echo -e "${RED}Error: No algorithm specified${NC}"
    echo ""
    show_help
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
        show_help
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

        # Build argument list
        ARGS=("$ALGORITHM")
        [ -n "$ARRAY_SIZE" ] && ARGS+=("--size" "$ARRAY_SIZE")
        [ -n "$DELAY_MS" ] && ARGS+=("--delay" "$DELAY_MS")

        cd cpp
        ./run-rpi.sh "${ARGS[@]}"
        ;;

    rust)
        echo "Mode: Rust only"
        echo ""

        # Delegate to rust/run-rpi.sh
        if [ ! -f "rust/run-rpi.sh" ]; then
            echo -e "${RED}Error: rust/run-rpi.sh not found${NC}"
            exit 1
        fi

        # Build argument list
        ARGS=("$ALGORITHM")
        [ -n "$ARRAY_SIZE" ] && ARGS+=("--size" "$ARRAY_SIZE")
        [ -n "$DELAY_MS" ] && ARGS+=("--delay" "$DELAY_MS")

        cd rust
        ./run-rpi.sh "${ARGS[@]}"
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
        (cd cpp && mkdir -p cmake-build-debug && cd cmake-build-debug && cmake .. > /dev/null && cmake --build . 2>&1 | grep -E '(Building|error|warning|\[)' || true) || {
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

        (cd rust && $CARGO_CMD build --release 2>&1 | grep -E '(Compiling|Finished|error|warning)' || true) || {
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

        # Build argument list for binaries
        BIN_ARGS=("$ALGORITHM")
        [ -n "$ARRAY_SIZE" ] && BIN_ARGS+=("--size" "$ARRAY_SIZE")
        [ -n "$DELAY_MS" ] && BIN_ARGS+=("--delay" "$DELAY_MS")

        # Run both implementations in parallel
        echo -e "${BLUE}Starting C++ implementation (left side)...${NC}"
        $CPP_BIN "${BIN_ARGS[@]}" > /dev/null 2>&1 &
        CPP_PID=$!

        # Small delay to let C++ window initialize
        sleep 0.5

        echo -e "${BLUE}Starting Rust implementation (right side)...${NC}"
        $RUST_BIN "${BIN_ARGS[@]}" > /dev/null 2>&1 &
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
