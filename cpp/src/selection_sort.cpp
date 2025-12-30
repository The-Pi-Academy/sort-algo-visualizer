#include "algorithms.h"
#include <thread>
#include <chrono>
#include <iostream>

// Selection Sort with visualization
// Time Complexity: O(n^2) - quadratic
// Space Complexity: O(1) - constant
//
// How it works:
// 1. Find the smallest element in the unsorted part
// 2. Swap it with the first unsorted element
// 3. Move the boundary between sorted and unsorted
void selectionSort(std::vector<int>& array, Visualizer& viz) {
    int n = array.size();
    std::vector<bool> sorted(n, false);
    int totalComparisons = 0;
    int totalSwaps = 0;
    auto startTime = std::chrono::high_resolution_clock::now();

    std::cout << "\n========================================\n";
    std::cout << "Starting Selection Sort\n";
    std::cout << "========================================\n";
    std::cout << "Array size: " << n << "\n";
    std::cout << "Worst case: O(n^2) = " << (n * n) << " comparisons\n";
    std::cout << "Best case: O(n^2) = " << (n * n) << " comparisons\n";
    std::cout << "========================================\n\n";

    for (int i = 0; i < n - 1; i++) {
        int minIndex = i;
        int passComparisons = 0;

        std::cout << "Pass " << (i + 1) << "/" << (n - 1) << " - Finding smallest in unsorted part... ";

        // Find the minimum element in unsorted part
        for (int j = i + 1; j < n; j++) {
            totalComparisons++;
            passComparisons++;

            // Check for quit
            if (viz.shouldQuit()) return;

            // Visualize comparison
            viz.draw(array, minIndex, j, sorted);
            viz.playTone(array[j]);

            if (array[j] < array[minIndex]) {
                minIndex = j;
            }

            // Delay so we can see the visualization
            std::this_thread::sleep_for(std::chrono::milliseconds(viz.getDelayMs()));
        }

        // Swap the found minimum element with the first element
        if (minIndex != i) {
            std::swap(array[i], array[minIndex]);
            totalSwaps++;
            std::cout << passComparisons << " comparisons, 1 swap\n";
        } else {
            std::cout << passComparisons << " comparisons, 0 swaps (already in place)\n";
        }

        // Mark this position as sorted
        sorted[i] = true;

        // Show the swap
        viz.draw(array, i, minIndex, sorted);
        std::this_thread::sleep_for(std::chrono::milliseconds(viz.getDelayMs() * 3));
    }

    // Mark last element as sorted
    sorted[n - 1] = true;

    auto endTime = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(endTime - startTime);

    std::cout << "\n========================================\n";
    std::cout << "Selection Sort Complete!\n";
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
