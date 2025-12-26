// Module declarations for sorting algorithms
// Each algorithm is in its own file
pub mod bubble_sort;
pub mod selection_sort;

// Enum for available sorting algorithms
#[derive(Debug, Clone, Copy)]
pub enum SortAlgorithm {
    Bubble,
    Selection,
    // Insertion,  // Coming soon!
    // Quick,      // Coming soon!
    // Merge       // Coming soon!
}

// Helper function to convert algorithm enum to display name
pub fn algorithm_to_string(algo: SortAlgorithm) -> &'static str {
    match algo {
        SortAlgorithm::Bubble => "Bubble Sort",
        SortAlgorithm::Selection => "Selection Sort",
        // SortAlgorithm::Insertion => "Insertion Sort",
        // SortAlgorithm::Quick => "Quick Sort",
        // SortAlgorithm::Merge => "Merge Sort",
    }
}

// Helper function to parse algorithm from string (for command line)
pub fn string_to_algorithm(s: &str) -> SortAlgorithm {
    match s.to_lowercase().as_str() {
        "selection" => SortAlgorithm::Selection,
        // "insertion" => SortAlgorithm::Insertion,
        // "quick" => SortAlgorithm::Quick,
        // "merge" => SortAlgorithm::Merge,
        _ => SortAlgorithm::Bubble, // Default
    }
}

// Helper function to get time complexity for an algorithm
pub fn get_time_complexity(algo: SortAlgorithm) -> &'static str {
    match algo {
        SortAlgorithm::Bubble => "O(n^2)",
        SortAlgorithm::Selection => "O(n^2)",
        // SortAlgorithm::Insertion => "O(n^2)",
        // SortAlgorithm::Quick => "O(n log n)",
        // SortAlgorithm::Merge => "O(n log n)",
    }
}

// Helper function to get space complexity for an algorithm
pub fn get_space_complexity(algo: SortAlgorithm) -> &'static str {
    match algo {
        SortAlgorithm::Bubble => "O(1)",
        SortAlgorithm::Selection => "O(1)",
        // SortAlgorithm::Insertion => "O(1)",
        // SortAlgorithm::Quick => "O(log n)",
        // SortAlgorithm::Merge => "O(n)",
    }
}
