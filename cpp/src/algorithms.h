#ifndef ALGORITHMS_H
#define ALGORITHMS_H

#include <vector>
#include "visualizer.h"

// Sorting algorithm function declarations
// Each algorithm takes an array and a visualizer reference

// Bubble Sort - O(n^2) time, O(1) space
// Simple comparison-based sort that repeatedly steps through the list
void bubbleSort(std::vector<int>& array, Visualizer& viz);

// Selection Sort - O(n^2) time, O(1) space (to be implemented)
// void selectionSort(std::vector<int>& array, Visualizer& viz);

// Insertion Sort - O(n^2) time, O(1) space (to be implemented)
// void insertionSort(std::vector<int>& array, Visualizer& viz);

#endif // ALGORITHMS_H
