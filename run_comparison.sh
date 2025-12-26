#!/bin/bash

# Sorting Visualizer Comparison Script
# Runs both C++ and Rust implementations side-by-side
#
# Usage:
#   ./run_comparison.sh <algorithm>
#
# Available algorithms: bubble, selection

# Check if algorithm argument is provided
if [ -z "$1" ]; then
    echo "╔════════════════════════════════════════╗"
    echo "║  SORTING ALGORITHM COMPARISON RUNNER   ║"
    echo "╚════════════════════════════════════════╝"
    echo ""
    echo "Usage: ./run_comparison.sh <algorithm>"
    echo ""
    echo "Available algorithms:"
    echo "  - bubble      Bubble Sort (O(n²))"
    echo "  - selection   Selection Sort (O(n²))"
    echo ""
    echo "Example:"
    echo "  ./run_comparison.sh bubble"
    echo "  ./run_comparison.sh selection"
    echo ""
    exit 1
fi

ALGORITHM=$1

# Validate algorithm choice
case "$ALGORITHM" in
    bubble|selection)
        # Valid algorithm
        ;;
    *)
        echo "Error: Unknown algorithm '$ALGORITHM'"
        echo ""
        echo "Available algorithms:"
        echo "  - bubble"
        echo "  - selection"
        echo ""
        exit 1
        ;;
esac

echo "╔════════════════════════════════════════╗"
echo "║  SORTING ALGORITHM COMPARISON RUNNER   ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo "Algorithm: $ALGORITHM"
echo "C++ (left) vs Rust (right)"
echo ""

# Always build both projects to ensure changes are reflected
# Use release builds for fair performance comparison
CPP_BIN="./cpp/cmake-build-debug/sort_visualizer"
RUST_BIN="./rust/target/release/sort_visualizer"

echo "Building projects..."
echo ""

# Build C++ project
echo "→ Building C++ project..."
cd cpp || exit 1

# Create build directory if it doesn't exist
if [ ! -d "cmake-build-debug" ]; then
    mkdir -p cmake-build-debug
fi

cd cmake-build-debug || exit 1

# Run CMake to generate build files (always, in case CMakeLists.txt changed)
echo "  Running CMake..."
cmake .. || {
    echo "Error: CMake configuration failed"
    echo "Make sure you have CMake and SDL2 installed"
    exit 1
}

# Build using cmake --build (works with Make, Ninja, or any build system)
echo "  Compiling..."
cmake --build . || {
    echo "Error: C++ build failed"
    exit 1
}

cd ../.. || exit 1
echo "  ✓ C++ build complete"
echo ""

# Build Rust project
echo "→ Building Rust project (release mode)..."
cd rust || exit 1

# Use full path to cargo or find it
if command -v cargo &> /dev/null; then
    CARGO_CMD="cargo"
elif [ -f "$HOME/.cargo/bin/cargo" ]; then
    CARGO_CMD="$HOME/.cargo/bin/cargo"
else
    echo "Error: cargo not found. Please install Rust first:"
    echo "  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
    exit 1
fi

$CARGO_CMD build --release || {
    echo "Error: Rust build failed"
    exit 1
}

cd .. || exit 1
echo "  ✓ Rust build complete"
echo ""

# Verify both binaries exist
if [ ! -f "$CPP_BIN" ]; then
    echo "Error: C++ binary not found at $CPP_BIN"
    exit 1
fi

if [ ! -f "$RUST_BIN" ]; then
    echo "Error: Rust binary not found at $RUST_BIN"
    exit 1
fi

echo "Both builds successful!"
echo ""

echo "Starting C++ implementation (left side)..."
$CPP_BIN $ALGORITHM &
CPP_PID=$!

# Wait a moment for the C++ window to appear
sleep 1

echo "Starting Rust implementation (right side)..."
$RUST_BIN $ALGORITHM &
RUST_PID=$!

echo ""
echo "Both visualizers are running!"
echo "Press Ctrl+C to stop both programs"
echo ""
echo "Process IDs:"
echo "  C++:  $CPP_PID"
echo "  Rust: $RUST_PID"

# Wait for both processes
wait $CPP_PID $RUST_PID

echo ""
echo "Comparison complete!"
