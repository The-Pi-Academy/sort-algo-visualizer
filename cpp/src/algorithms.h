#ifndef ALGORITHMS_H
#define ALGORITHMS_H

#include <vector>
#include <string>
#include "visualizer.h"

// Enum for available sorting algorithms
enum class SortAlgorithm {
    BUBBLE,
    SELECTION,
    // INSERTION,  // Coming soon!
    // QUICK,      // Coming soon!
    // MERGE       // Coming soon!
};

// Helper function to convert algorithm enum to display name
inline std::string algorithmToString(SortAlgorithm algo) {
    switch (algo) {
        case SortAlgorithm::BUBBLE:    return "Bubble Sort";
        case SortAlgorithm::SELECTION: return "Selection Sort";
        // case SortAlgorithm::INSERTION: return "Insertion Sort";
        // case SortAlgorithm::QUICK:     return "Quick Sort";
        // case SortAlgorithm::MERGE:     return "Merge Sort";
        default: return "Unknown Sort";
    }
}

// Helper function to parse algorithm from string (for command line)
inline SortAlgorithm stringToAlgorithm(const std::string& str) {
    if (str == "selection") return SortAlgorithm::SELECTION;
    // if (str == "insertion") return SortAlgorithm::INSERTION;
    // if (str == "quick")     return SortAlgorithm::QUICK;
    // if (str == "merge")     return SortAlgorithm::MERGE;
    return SortAlgorithm::BUBBLE;  // Default
}

// Helper function to get time complexity for an algorithm
inline std::string getTimeComplexity(SortAlgorithm algo) {
    switch (algo) {
        case SortAlgorithm::BUBBLE:    return "O(n^2)";
        case SortAlgorithm::SELECTION: return "O(n^2)";
        // case SortAlgorithm::INSERTION: return "O(n^2)";
        // case SortAlgorithm::QUICK:     return "O(n log n)";
        // case SortAlgorithm::MERGE:     return "O(n log n)";
        default: return "O(?)";
    }
}

// Helper function to get space complexity for an algorithm
inline std::string getSpaceComplexity(SortAlgorithm algo) {
    switch (algo) {
        case SortAlgorithm::BUBBLE:    return "O(1)";
        case SortAlgorithm::SELECTION: return "O(1)";
        // case SortAlgorithm::INSERTION: return "O(1)";
        // case SortAlgorithm::QUICK:     return "O(log n)";
        // case SortAlgorithm::MERGE:     return "O(n)";
        default: return "O(?)";
    }
}

// Sorting algorithm function declarations
// Each algorithm takes an array and a visualizer reference

// Bubble Sort - O(n^2) time, O(1) space
// Simple comparison-based sort that repeatedly steps through the list
void bubbleSort(std::vector<int>& array, Visualizer& viz);

// Selection Sort - O(n^2) time, O(1) space
// Finds the smallest element and puts it in the correct position
void selectionSort(std::vector<int>& array, Visualizer& viz);

// Insertion Sort - O(n^2) time, O(1) space (to be implemented)
// void insertionSort(std::vector<int>& array, Visualizer& viz);

#endif // ALGORITHMS_H
