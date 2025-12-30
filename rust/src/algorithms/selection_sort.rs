use macroquad::prelude::*;
use std::thread;
use std::time::{Duration, Instant};

use crate::algorithms::SortAlgorithm;
use crate::visualizer::{AudioSystem, draw_array};

// Selection Sort with visualization
// Time Complexity: O(n^2) - quadratic
// Space Complexity: O(1) - constant
//
// How it works:
// 1. Find the smallest element in the unsorted part
// 2. Swap it with the first unsorted element
// 3. Move the boundary between sorted and unsorted
pub async fn selection_sort(array: &mut [usize], algorithm: SortAlgorithm, audio: &AudioSystem, array_size: usize, delay_ms: u64) {
    let n = array.len();
    let mut sorted = vec![false; n];
    let mut total_comparisons = 0;
    let mut total_swaps = 0;
    let start_time = Instant::now();

    println!("\n========================================");
    println!("Starting Selection Sort");
    println!("========================================");
    println!("Array size: {}", n);
    println!("Worst case: O(n^2) = {} comparisons", n * n);
    println!("Best case: O(n^2) = {} comparisons", n * n);
    println!("========================================\n");

    for i in 0..n - 1 {
        let mut min_index = i;
        let mut pass_comparisons = 0;

        print!("Pass {}/{} - Finding smallest in unsorted part... ", i + 1, n - 1);

        // Find the minimum element in unsorted part
        for j in i + 1..n {
            total_comparisons += 1;
            pass_comparisons += 1;

            // Visualize comparison
            draw_array(array, Some(min_index), Some(j), &sorted, algorithm, array_size, delay_ms);
            next_frame().await;

            // Play tone for current element being checked
            audio.play_tone(array[j], array_size);

            if array[j] < array[min_index] {
                min_index = j;
            }

            // Delay so we can see the visualization
            thread::sleep(Duration::from_millis(delay_ms));
        }

        // Swap the found minimum element with the first element
        if min_index != i {
            array.swap(i, min_index);
            total_swaps += 1;
            println!("{} comparisons, 1 swap", pass_comparisons);
        } else {
            println!("{} comparisons, 0 swaps (already in place)", pass_comparisons);
        }

        // Mark this position as sorted
        sorted[i] = true;

        // Show the swap
        draw_array(array, Some(i), Some(min_index), &sorted, algorithm, array_size, delay_ms);
        next_frame().await;
        thread::sleep(Duration::from_millis(delay_ms * 3));
    }

    // Mark last element as sorted
    sorted[n - 1] = true;

    let duration = start_time.elapsed();

    println!("\n========================================");
    println!("Selection Sort Complete!");
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
