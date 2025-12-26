#include "visualizer.h"
#include "algorithms.h"
#include <vector>
#include <random>
#include <algorithm>
#include <thread>
#include <chrono>
#include <iostream>
#include <string>

// STUDENTS: Change this to pick which algorithm to use!
// Options: SortAlgorithm::BUBBLE or SortAlgorithm::SELECTION
const SortAlgorithm ALGORITHM = SortAlgorithm::BUBBLE;

int main(int argc, char* argv[]) {
    try {
        // Figure out which algorithm to use
        // Can be changed above, or pass as command line argument
        SortAlgorithm algorithm = ALGORITHM;
        if (argc > 1) {
            algorithm = stringToAlgorithm(argv[1]);
        }

        std::cout << "\n";
        std::cout << "╔════════════════════════════════════════╗\n";
        std::cout << "║   SORTING VISUALIZER - C++ SDL2        ║\n";
        std::cout << "╚════════════════════════════════════════╝\n";
        std::cout << "\nAlgorithm: " << algorithmToString(algorithm) << "\n";
        std::cout << "Initializing...\n";

        // Create and shuffle array
        std::vector<int> array(ARRAY_SIZE);
        for (int i = 0; i < ARRAY_SIZE; i++) {
            array[i] = i + 1;
        }

        std::random_device rd;
        std::mt19937 gen(rd());
        std::shuffle(array.begin(), array.end(), gen);

        std::cout << "Created array with " << ARRAY_SIZE << " elements\n";
        std::cout << "Array shuffled randomly\n";

        // Create visualizer with algorithm info
        Visualizer viz(
            algorithmToString(algorithm),
            getTimeComplexity(algorithm),
            getSpaceComplexity(algorithm)
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
