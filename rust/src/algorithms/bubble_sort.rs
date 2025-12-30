use macroquad::prelude::*;
use std::thread;
use std::time::{Duration, Instant};

use crate::algorithms::SortAlgorithm;
use crate::visualizer::{AudioSystem, draw_array};

// Bubble Sort with visualization
// Time Complexity: O(n^2) - quadratic
// Space Complexity: O(1) - constant
//
// How it works:
// 1. Compare adjacent elements
// 2. Swap if they're in wrong order
// 3. Repeat until no more swaps needed
pub async fn bubble_sort(array: &mut [usize], algorithm: SortAlgorithm, audio: &AudioSystem, array_size: usize, delay_ms: u64) {
    let n = array.len();
    let mut sorted = vec![false; n];
    let mut total_comparisons = 0;
    let mut total_swaps = 0;
    let start_time = Instant::now();

    println!("\n========================================");
    println!("Starting Bubble Sort");
    println!("========================================");
    println!("Array size: {}", n);
    println!("Worst case: O(n^2) = {} comparisons", n * n);
    println!("Best case: O(n) = {} comparisons", n);
    println!("========================================\n");

    for i in 0..n - 1 {
        let mut swapped = false;
        let mut pass_comparisons = 0;
        let mut pass_swaps = 0;

        print!("Pass {}/{}... ", i + 1, n - 1);

        for j in 0..n - i - 1 {
            total_comparisons += 1;
            pass_comparisons += 1;

            // Visualize comparison
            draw_array(array, Some(j), Some(j + 1), &sorted, algorithm, array_size, delay_ms);
            next_frame().await;

            // Play tone for current element
            audio.play_tone(array[j], array_size);

            // The actual bubble sort logic
            if array[j] > array[j + 1] {
                array.swap(j, j + 1);
                swapped = true;
                total_swaps += 1;
                pass_swaps += 1;
            }

            // Delay so we can see the visualization
            thread::sleep(Duration::from_millis(delay_ms));
        }

        // Mark the last element of this pass as sorted
        sorted[n - i - 1] = true;

        println!("{} comparisons, {} swaps", pass_comparisons, pass_swaps);

        // If no swaps occurred, the array is sorted
        if !swapped {
            println!("\nArray is sorted! Early termination at pass {}", i + 1);
            // Mark all remaining elements as sorted
            for item in sorted.iter_mut().take(n - i - 1) {
                *item = true;
            }
            break;
        }
    }

    let duration = start_time.elapsed();

    println!("\n========================================");
    println!("Bubble Sort Complete!");
    println!("========================================");
    println!("Total comparisons: {}", total_comparisons);
    println!("Total swaps: {}", total_swaps);
    println!("Time elapsed: {}ms", duration.as_millis());
    println!("Time complexity: O(n^2)");
    println!("Space complexity: O(1)");
    println!("========================================");

    // Final visualization showing all bars in green
    draw_array(array, None, None, &sorted, algorithm, array_size, delay_ms);
    next_frame().await;
    thread::sleep(Duration::from_millis(1000));
}
