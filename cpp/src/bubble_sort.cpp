#include "algorithms.h"
#include <thread>
#include <chrono>
#include <iostream>

// Bubble Sort with visualization
// Time Complexity: O(n^2) - quadratic
// Space Complexity: O(1) - constant
//
// How it works:
// 1. Compare adjacent elements
// 2. Swap if they're in wrong order
// 3. Repeat until no more swaps needed
void bubbleSort(std::vector<int>& array, Visualizer& viz) {
    int n = array.size();
    std::vector<bool> sorted(n, false);
    int totalComparisons = 0;
    int totalSwaps = 0;
    auto startTime = std::chrono::high_resolution_clock::now();

    std::cout << "\n========================================\n";
    std::cout << "Starting Bubble Sort\n";
    std::cout << "========================================\n";
    std::cout << "Array size: " << n << "\n";
    std::cout << "Worst case: O(n^2) = " << (n * n) << " comparisons\n";
    std::cout << "Best case: O(n) = " << n << " comparisons\n";
    std::cout << "========================================\n\n";

    for (int i = 0; i < n - 1; i++) {
        bool swapped = false;
        int passComparisons = 0;
        int passSwaps = 0;

        std::cout << "Pass " << (i + 1) << "/" << (n - 1) << "... ";

        for (int j = 0; j < n - i - 1; j++) {
            totalComparisons++;
            passComparisons++;
            // Check for quit
            if (viz.shouldQuit()) return;

            // Visualize comparison
            viz.draw(array, j, j + 1, sorted);
            viz.playTone(array[j]);

            // The actual bubble sort logic
            if (array[j] > array[j + 1]) {
                std::swap(array[j], array[j + 1]);
                swapped = true;
                totalSwaps++;
                passSwaps++;
            }

            // Delay so we can see the visualization
            std::this_thread::sleep_for(std::chrono::milliseconds(viz.getDelayMs()));
        }

        // Mark the last element of this pass as sorted
        sorted[n - i - 1] = true;

        std::cout << passComparisons << " comparisons, " << passSwaps << " swaps\n";

        // If no swaps occurred, the array is sorted
        if (!swapped) {
            std::cout << "\nArray is sorted! Early termination at pass " << (i + 1) << "\n";
            // Mark all remaining elements as sorted
            for (int k = 0; k < n - i - 1; k++) {
                sorted[k] = true;
            }
            break;
        }
    }

    auto endTime = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(endTime - startTime);

    std::cout << "\n========================================\n";
    std::cout << "Bubble Sort Complete!\n";
    std::cout << "========================================\n";
    std::cout << "Total comparisons: " << totalComparisons << "\n";
    std::cout << "Total swaps: " << totalSwaps << "\n";
    std::cout << "Time elapsed: " << duration.count() << "ms\n";
    std::cout << "Time complexity: O(n^2)\n";
    std::cout << "Space complexity: O(1)\n";
    std::cout << "========================================\n";

    // Final visualization showing all bars in green
    viz.draw(array, -1, -1, sorted);
    std::this_thread::sleep_for(std::chrono::milliseconds(1000));
}
