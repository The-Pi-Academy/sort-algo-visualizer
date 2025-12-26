#!/bin/bash

# Raspberry Pi Build and Run Script for Sort Visualizer
# This script installs dependencies, builds, and runs the sorting visualizer

set -e  # Exit on any error

echo "========================================="
echo "Sort Visualizer - Raspberry Pi Setup"
echo "========================================="

# Check if running as root for package installation
if [ "$EUID" -ne 0 ]; then
    echo "Installing dependencies (requires sudo)..."
    sudo apt-get update
    sudo apt-get install -y cmake build-essential libsdl2-dev libsdl2-mixer-dev libsdl2-ttf-dev
else
    echo "Installing dependencies..."
    apt-get update
    apt-get install -y cmake build-essential libsdl2-dev libsdl2-mixer-dev libsdl2-ttf-dev
fi

echo ""
echo "Dependencies installed successfully!"
echo ""

# Create build directory
echo "Creating build directory..."
mkdir -p build
cd build

# Run CMake
echo "Configuring with CMake..."
cmake ..

# Build
echo "Building sort_visualizer..."
make

echo ""
echo "========================================="
echo "Build complete!"
echo "========================================="
echo ""
echo "Running sort_visualizer..."
echo ""

# Run the program
./sort_visualizer
