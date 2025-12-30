#include "visualizer.h"
#include "algorithms.h"
#include <vector>
#include <random>
#include <algorithm>
#include <thread>
#include <chrono>
#include <iostream>
#include <string>
#include <cstring>

// STUDENTS: Change this to pick which algorithm to use!
// Options: SortAlgorithm::BUBBLE or SortAlgorithm::SELECTION
const SortAlgorithm ALGORITHM = SortAlgorithm::BUBBLE;

int main(int argc, char* argv[]) {
    try {
        // Default values
        SortAlgorithm algorithm = ALGORITHM;
        int arraySize = ARRAY_SIZE;
        int delayMs = DELAY_MS;

        // Parse command line arguments
        for (int i = 1; i < argc; i++) {
            std::string arg = argv[i];

            // Algorithm name (no dashes)
            if (arg == "bubble" || arg == "selection") {
                algorithm = stringToAlgorithm(arg.c_str());
            }
            // --size argument
            else if (arg.find("--size=") == 0) {
                arraySize = std::stoi(arg.substr(7));
                if (arraySize <= 0 || arraySize > 10000) {
                    std::cerr << "Error: Array size must be between 1 and 10000\n";
                    return 1;
                }
            }
            else if (arg == "--size" && i + 1 < argc) {
                arraySize = std::stoi(argv[++i]);
                if (arraySize <= 0 || arraySize > 10000) {
                    std::cerr << "Error: Array size must be between 1 and 10000\n";
                    return 1;
                }
            }
            // --delay argument
            else if (arg.find("--delay=") == 0) {
                delayMs = std::stoi(arg.substr(8));
                if (delayMs < 0 || delayMs > 1000) {
                    std::cerr << "Error: Delay must be between 0 and 1000 ms\n";
                    return 1;
                }
            }
            else if (arg == "--delay" && i + 1 < argc) {
                delayMs = std::stoi(argv[++i]);
                if (delayMs < 0 || delayMs > 1000) {
                    std::cerr << "Error: Delay must be between 0 and 1000 ms\n";
                    return 1;
                }
            }
        }

        std::cout << "\n";
        std::cout << "╔════════════════════════════════════════╗\n";
        std::cout << "║   SORTING VISUALIZER - C++ SDL2        ║\n";
        std::cout << "╚════════════════════════════════════════╝\n";
        std::cout << "\nAlgorithm: " << algorithmToString(algorithm) << "\n";
        std::cout << "Array Size: " << arraySize << " elements\n";
        std::cout << "Delay: " << delayMs << " ms\n";
        std::cout << "Initializing...\n";

        // Create and shuffle array
        std::vector<int> array(arraySize);
        for (int i = 0; i < arraySize; i++) {
            array[i] = i + 1;
        }

        std::random_device rd;
        std::mt19937 gen(rd());
        std::shuffle(array.begin(), array.end(), gen);

        std::cout << "Created array with " << arraySize << " elements\n";
        std::cout << "Array shuffled randomly\n";

        // Create visualizer with algorithm info
        Visualizer viz(
            algorithmToString(algorithm),
            getTimeComplexity(algorithm),
            getSpaceComplexity(algorithm),
            arraySize,
            delayMs
        );
        std::cout << "Window created successfully\n";
        std::cout << "Press ESC to quit anytime\n";

        // Show initial state
        viz.draw(array);
        std::this_thread::sleep_for(std::chrono::milliseconds(1000));

        // Sort and visualize - pick the right algorithm
        switch (algorithm) {
            case SortAlgorithm::BUBBLE:
                bubbleSort(array, viz);
                break;
            case SortAlgorithm::SELECTION:
                selectionSort(array, viz);
                break;
            // case SortAlgorithm::INSERTION:
            //     insertionSort(array, viz);
            //     break;
            // Add more algorithms here as they're implemented!
        }

        // Wait a bit before closing
        std::this_thread::sleep_for(std::chrono::milliseconds(2000));

    } catch (const std::exception& e) {
        SDL_ShowSimpleMessageBox(SDL_MESSAGEBOX_ERROR, "Error", e.what(), nullptr);
        return 1;
    }

    return 0;
}
