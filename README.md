# Sorting Algorithm Visualizer

A visual and interactive sorting algorithm demonstration built for The Pi Academy's Raspberry Pi Youth Coding Camp. This project helps students ages 11-14 learn about sorting algorithms through colorful visualizations and sound, comparing implementations in both C++ and Rust.

## What This Project Does

Watch sorting algorithms come to life! Each algorithm is visualized as colorful bars that move and swap in real-time, with sounds that correspond to the values being sorted. Students can:

- See how different sorting algorithms work step-by-step
- Compare the same algorithm written in C++ and Rust
- Understand algorithm efficiency through visual speed differences
- Modify array sizes and speeds to experiment

## Algorithms Included

Currently implemented in both C++ and Rust:

1. **Bubble Sort** - "Bubble" large values to the top (easiest to understand)
2. **Selection Sort** - Find the smallest value and put it in place

Coming soon:
3. **Insertion Sort** - Like sorting playing cards in your hand
4. **Quicksort** - Divide and conquer with recursion
5. **Merge Sort** - Another divide and conquer approach

## Project Structure

```
sort-algo-visualizer/
├── cpp/
│   ├── src/                # C++ source files
│   │   ├── main.cpp        # Main program entry point
│   │   ├── visualizer.h    # Shared visualization code (graphics, audio)
│   │   ├── bubble.cpp      # Bubble sort implementation
│   │   ├── selection.cpp   # Selection sort implementation (planned)
│   │   └── insertion.cpp   # Insertion sort implementation (planned)
│   └── CMakeLists.txt      # Build configuration
└── rust/
    ├── src/                # Rust source files
    │   ├── main.rs         # Main program entry point
    │   ├── visualizer.rs   # Shared visualization code
    │   ├── bubble.rs       # Bubble sort implementation
    │   └── ...             # Other algorithms
    └── Cargo.toml          # Build configuration
```

## Visual Features

- **Bars**: Each element in the array is represented as a vertical bar
- **Colors**: Rainbow gradient based on value (low values = red/orange, high values = blue/purple)
- **Highlighting**:
  - Red bars = currently being compared
  - Green bars = in their final sorted position
- **Sound**: Each value has a unique frequency (200Hz-2000Hz) generated programmatically - higher values = higher pitch
- **Speed Control**: Adjustable delay to see algorithms in slow motion
- **Window Positioning**:
  - C++ automatically positions on the left 50% of the screen
  - Rust automatically positions on the right 50% of the screen (macOS)
  - Both use the full height of your display for maximum visibility
- **Statistics**: Both implementations show real-time comparisons, swaps, and timing information

## Getting Started on Raspberry Pi

### Prerequisites

**For C++ (SDL2):**
```bash
sudo apt-get update
sudo apt-get install libsdl2-dev libsdl2-mixer-dev libsdl2-ttf-dev cmake build-essential
```

**For Rust (Macroquad):**
```bash
# Install Rust (if not already installed)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env

# Install ALSA development libraries for audio
sudo apt-get install libasound2-dev
```

### Building and Running

**C++ Version (Left 50% of screen):**
```bash
cd cpp
mkdir -p cmake-build-debug
cd cmake-build-debug
cmake ..
make
./sort_visualizer [algorithm]
```

Available algorithms: `bubble` (default), `selection`

**Rust Version (Right 50% of screen):**
```bash
cd rust
cargo run --release -- [algorithm]
```

Available algorithms: `bubble` (default), `selection`

**Side-by-Side Comparison:**
```bash
# Run both implementations simultaneously
./run_comparison.sh <algorithm>
```

This script will automatically build and launch both C++ and Rust versions at the same time, with C++ on the left half of the screen and Rust on the right half. Perfect for comparing implementations!

## Using the Comparison Script

The `run_comparison.sh` script is the easiest way to run both implementations side-by-side.

### Quick Start

```bash
# Show available algorithms
./run_comparison.sh

# Compare bubble sort implementations
./run_comparison.sh bubble

# Compare selection sort implementations
./run_comparison.sh selection
```

### What the Script Does

1. **Validates** your algorithm choice
2. **Builds** both C++ and Rust projects (always rebuilds to ensure changes are reflected)
3. **Launches** both visualizers simultaneously
4. **Positions** windows side-by-side (C++ on left, Rust on right)

### Things to Keep in Mind

**Automatic Building:**
- The script always rebuilds both projects before running
- This ensures your code changes are immediately reflected
- Build systems (Make/Ninja and Cargo) only recompile what changed, so rebuilds are fast

**Visual Comparison:**
- Both implementations use the same `ARRAY_SIZE` and `DELAY_MS` constants
- You're comparing algorithm behavior, code structure, and implementation differences
- The visualizations should look identical if the algorithms are implemented correctly

**Stopping the Programs:**
- Press `Ctrl+C` to stop both programs
- Both processes will terminate together

### Performance Benchmarking

**Important:** The comparison script is designed for **visual comparison**, not performance benchmarking. The visualizations are throttled by delays, rendering, and audio playback.

If you want to benchmark pure sorting performance (1:1 comparison):

**Option 1: Disable Visualization Overhead**

Modify both implementations to remove delays:
```rust
// In visualizer.rs (Rust) and visualizer.h (C++)
pub const DELAY_MS: u64 = 0;  // Remove delay between comparisons
```

And comment out visualization/audio calls in the sorting functions:
```rust
// draw_array(...);      // Comment out
// audio.play_tone(...); // Comment out
```

**Option 2: Use Larger Datasets**

Increase the array size to make sorting time dominate:
```rust
pub const ARRAY_SIZE: usize = 10000;  // Much larger dataset
```

**Option 3: Dedicated Benchmark Tools**

For rigorous performance testing:

**Rust:**
```bash
cd rust
cargo bench  # Requires adding benchmark configuration
```

**C++:**
```bash
# Use Google Benchmark or similar tools
# Compile with optimizations: -O3 or -DCMAKE_BUILD_TYPE=Release
```

**Key factors affecting performance:**
- Build configuration (Debug vs Release)
- Compiler optimizations (-O0, -O2, -O3)
- Graphics library overhead (SDL2 vs Macroquad)
- Audio system latency
- Operating system scheduling
- Background processes

For educational purposes, the visual comparison is perfect! For scientific benchmarking, you'll want to isolate the sorting algorithm from all other factors.

## For Students: Experimenting with the Code

### Changing Array Size

Both versions have a configurable array size at the top of the main file:

**C++** (cpp/src/main.cpp):
```cpp
const int ARRAY_SIZE = 100;  // Change this number!
```

**Rust** (rust/src/main.rs):
```rust
const ARRAY_SIZE: usize = 100;  // Change this number!
```

### Changing Speed

Look for the delay/sleep values in the sorting functions:

**C++**:
```cpp
std::this_thread::sleep_for(std::chrono::milliseconds(10));  // 10ms delay
```

**Rust**:
```rust
std::thread::sleep(Duration::from_millis(10));  // 10ms delay
```

Try values between 1ms (very fast) and 100ms (slow motion)!

### Adding Your Own Algorithm

The code is structured to make adding new algorithms easy:

1. **Shared visualization code** (`visualizer.h`) handles all graphics and sound
2. **Algorithm files** only contain the sorting logic
3. Each algorithm is clean and focused

**To add a new algorithm:**
1. Create a new file (e.g., `selection.cpp` or `selection.rs`)
2. Import the visualizer
3. Write your sorting function that calls `viz.draw()` and `viz.playTone()`
4. Update `main.cpp` to call your new algorithm

**Example structure:**
```cpp
void selectionSort(std::vector<int>& array, Visualizer& viz) {
    // Your sorting logic here
    viz.draw(array, compareIdx1, compareIdx2);
    viz.playTone(array[i]);
}
```

## Educational Goals

This project teaches:

- **Algorithm Basics**: Understanding how sorting works
- **Complexity**: Why some algorithms are faster than others
- **Language Comparison**: Seeing similarities and differences between C++ and Rust
- **Visual Programming**: Connecting code to visual output
- **Audio Feedback**: Making programs interactive and engaging

## For Instructors

### Quick Development Iteration

The default array size is 100 elements, which provides good visualization without taking too long. You can:

- Run multiple algorithms back-to-back during demos
- Have students race C++ vs Rust implementations
- Modify the delay to speed up or slow down for different teaching moments

### Comparison Points: C++ vs Rust

Both implementations are intentionally similar to highlight:

1. **Safety**: Rust's automatic bounds checking vs C++'s manual index management
2. **Syntax**: Nearly identical loop structures, different memory handling
3. **Performance**: Both leverage GPU acceleration (SDL2 and Macroquad)
4. **Build Systems**: CMake vs Cargo

### Running Side-by-Side

The Pi 4b has 4 cores, so you can run both versions simultaneously:

1. Open two terminal windows
2. Run the C++ version in one, Rust in the other
3. Students can literally see them "race" on screen

## Technical Details

### C++: SDL2 (Simple DirectMedia Layer)

- Industry-standard 2D graphics library
- Hardware-accelerated rendering on Pi
- Direct access to GPU via OpenGL ES
- Simple, readable API for students

### Rust: Macroquad

- Lightweight game framework
- Educational-friendly API
- Quick compilation even on Pi 4
- Cross-platform (can develop on laptop, run on Pi)

## Troubleshooting

**Display Issues on Pi:**
- Make sure you're running in desktop mode (not headless)
- SDL2 requires X11 display server

**Audio Not Working:**
- Check volume: `alsamixer`
- Verify audio device: `aplay -l`

**Compilation Errors:**
- Ensure all dependencies are installed
- Try updating: `sudo apt-get update && sudo apt-get upgrade`

## Contributing

This is an educational project for The Pi Academy. Suggestions for improvements or additional algorithms are welcome! Please keep in mind the target audience is middle school students (ages 11-14).

## License

Created for The Pi Academy, a 501(c)(3) nonprofit organization empowering underrepresented youth through hands-on technology education.

## About The Pi Academy

The Pi Academy is a nonprofit founded by Bravo LT to empower underrepresented youth through hands-on technology education. Our Raspberry Pi Youth Coding Camps introduce students ages 11-14 to coding, robotics, and electronics, led by professional software developers. Students leave with their own Raspberry Pi computer and the foundation to continue learning independently.

Learn more at [The Pi Academy](https://github.com/The-Pi-Academy)
