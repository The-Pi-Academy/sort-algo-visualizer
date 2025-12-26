#include "visualizer.h"
#include "algorithms.h"
#include <vector>
#include <random>
#include <algorithm>
#include <thread>
#include <chrono>
#include <iostream>

int main(int argc, char* argv[]) {
    try {
        std::cout << "\n";
        std::cout << "╔════════════════════════════════════════╗\n";
        std::cout << "║   BUBBLE SORT VISUALIZER - C++ SDL2    ║\n";
        std::cout << "╚════════════════════════════════════════╝\n";
        std::cout << "\nInitializing...\n";

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

        // Create visualizer
        Visualizer viz;
        std::cout << "Window created successfully\n";
        std::cout << "Press ESC to quit anytime\n";

        // Show initial state
        viz.draw(array);
        std::this_thread::sleep_for(std::chrono::milliseconds(1000));

        // Sort and visualize
        bubbleSort(array, viz);

        // Wait a bit before closing
        std::this_thread::sleep_for(std::chrono::milliseconds(2000));

    } catch (const std::exception& e) {
        SDL_ShowSimpleMessageBox(SDL_MESSAGEBOX_ERROR, "Error", e.what(), nullptr);
        return 1;
    }

    return 0;
}
