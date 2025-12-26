# macOS Setup Guide (Apple Silicon)

**Note for Developers**: This project is optimized for Raspberry Pi (students and instructors). The default CMakeLists.txt is kept simple for educational purposes. macOS developers need to swap in a different configuration file.

## Prerequisites

You already have:
- Homebrew installed
- CLion (for C++)
- RustRover (for Rust)

## Step 1: Install SDL2 for C++ Version

```bash
brew install sdl2 sdl2_mixer sdl2_ttf cmake pkg-config
```

## Step 2: Install Rust for Rust Version

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
```

## Step 3: Configure C++ for macOS (Important!)

The default `CMakeLists.txt` is for Raspberry Pi. For macOS development:

```bash
cd cpp
cp CMakeLists.txt.macos CMakeLists.txt
```

**Before committing**: Restore the Raspberry Pi version:
```bash
cd cpp
git checkout CMakeLists.txt
```

See `cpp/README_DEVELOPERS.md` for detailed developer workflow.

## Step 4: Open Projects in CLion and RustRover

### CLion (C++)
1. Open CLion
2. `File` → `Open` → Select the `cpp` folder
3. Make sure you've swapped to `CMakeLists.txt.macos` (see Step 3)
4. Click the green play button to build and run

### RustRover (Rust)
1. Open RustRover
2. `File` → `Open` → Select the `rust` folder
3. Wait for indexing
4. Click the green play button to build and run

## Quick Terminal Build

**C++:**
```bash
cd cpp
cp CMakeLists.txt.macos CMakeLists.txt  # One time setup
mkdir build
cd build
cmake ..
make
./sort_visualizer
```

**Rust:**
```bash
cd rust
cargo run --release
```

## Why the Complexity?

Students will read the CMakeLists.txt on Raspberry Pi and ask questions about it. We keep the default configuration simple and educational. Developers working on curriculum can handle swapping a file.

## Troubleshooting

**"SDL2 not found" even after swap:**
- Make sure you copied `CMakeLists.txt.macos` to `CMakeLists.txt`
- In CLion: `File` → `Reload CMake Project`

**Window doesn't appear:**
- macOS requires GUI (can't run via SSH)
- Make sure you're logged into the desktop

## Apple Silicon Notes

Both SDL2 and Rust have excellent Apple Silicon support and will compile natively for ARM64.

Verify native compilation:
```bash
file cpp/build/sort_visualizer
# Should show: Mach-O 64-bit executable arm64

file rust/target/release/sort_visualizer
# Should show: Mach-O 64-bit executable arm64
```
