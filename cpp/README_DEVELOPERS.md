# Developer Setup (macOS)

This file is for curriculum developers working on macOS. Students and instructors use the default Raspberry Pi configuration.

## Quick Setup for macOS Development

### 1. Install Dependencies

```bash
brew install sdl2 sdl2_mixer cmake
```

### 2. Use the macOS CMakeLists

Replace the default CMakeLists.txt with the macOS version:

```bash
cd cpp
cp CMakeLists.txt.macos CMakeLists.txt
```

Or if using CLion, you can keep both files and manually select which to use by renaming when needed.

### 3. Build with CLion

1. Open CLion
2. `File` → `Open` → Select the `cpp` folder
3. CLion will reload the CMakeLists.txt
4. Click the green play button to build and run

### 4. Build with Terminal

```bash
cd cpp
mkdir build
cd build
cmake ..
make
./sort_visualizer
```

## Switching Back to Raspberry Pi Config

Before committing changes, restore the Raspberry Pi config:

```bash
cd cpp
git checkout CMakeLists.txt
```

Or keep a copy:
```bash
cp CMakeLists.txt CMakeLists.txt.backup
cp CMakeLists.txt.macos CMakeLists.txt
# ... do your development ...
cp CMakeLists.txt.backup CMakeLists.txt
```

## Why Separate Files?

- **CMakeLists.txt** (default): Simple Raspberry Pi config that students will read and learn from
- **CMakeLists.txt.macos**: Developer-specific config with Homebrew/pkg-config setup

Students ask questions about build files, so we keep the default clean and educational!
