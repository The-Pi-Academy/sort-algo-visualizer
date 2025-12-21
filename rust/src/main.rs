use macroquad::prelude::*;
use rand::seq::SliceRandom;
use std::thread;
use std::time::Duration;

// Configuration - Students can change these!
const ARRAY_SIZE: usize = 100;
const WINDOW_WIDTH: f32 = 800.0;
const WINDOW_HEIGHT: f32 = 600.0;
const DELAY_MS: u64 = 10;  // Milliseconds between each comparison

// Convert HSV to RGB for rainbow colors
fn hsv_to_rgb(h: f32, s: f32, v: f32) -> Color {
    let c = v * s;
    let x = c * (1.0 - ((h / 60.0) % 2.0 - 1.0).abs());
    let m = v - c;

    let (r, g, b) = if h < 60.0 {
        (c, x, 0.0)
    } else if h < 120.0 {
        (x, c, 0.0)
    } else if h < 180.0 {
        (0.0, c, x)
    } else if h < 240.0 {
        (0.0, x, c)
    } else if h < 300.0 {
        (x, 0.0, c)
    } else {
        (c, 0.0, x)
    };

    Color::new(r + m, g + m, b + m, 1.0)
}

// Get color for a bar based on its value
fn get_bar_color(value: usize, max_value: usize) -> Color {
    // Map value to hue (0-360 degrees)
    // Low values = red/orange (0-60), high values = blue/purple (240-300)
    let hue = (value as f32 * 280.0) / max_value as f32;
    hsv_to_rgb(hue, 0.8, 0.9)
}

// Draw the array with optional highlighting
fn draw_array(
    array: &[usize],
    compare_idx1: Option<usize>,
    compare_idx2: Option<usize>,
    sorted: &[bool],
) {
    // Clear screen with dark background
    clear_background(Color::new(0.08, 0.08, 0.12, 1.0));

    let bar_width = WINDOW_WIDTH / ARRAY_SIZE as f32;

    // Draw each bar
    for (i, &value) in array.iter().enumerate() {
        let bar_height = (value as f32 * WINDOW_HEIGHT) / ARRAY_SIZE as f32;
        let x = i as f32 * bar_width;
        let y = WINDOW_HEIGHT - bar_height;

        let color = if sorted[i] {
            // Green for sorted positions
            Color::new(0.0, 1.0, 0.0, 1.0)
        } else if Some(i) == compare_idx1 || Some(i) == compare_idx2 {
            // Red for elements being compared
            Color::new(1.0, 0.2, 0.2, 1.0)
        } else {
            // Rainbow colors based on value
            get_bar_color(value, ARRAY_SIZE)
        };

        draw_rectangle(x, y, bar_width - 1.0, bar_height, color);
    }
}

// Bubble Sort with visualization
async fn bubble_sort(array: &mut [usize]) {
    let n = array.len();
    let mut sorted = vec![false; n];

    for i in 0..n - 1 {
        let mut swapped = false;

        for j in 0..n - i - 1 {
            // Visualize comparison
            draw_array(array, Some(j), Some(j + 1), &sorted);
            next_frame().await;

            // The actual bubble sort logic
            if array[j] > array[j + 1] {
                array.swap(j, j + 1);
                swapped = true;
            }

            // Delay so we can see the visualization
            thread::sleep(Duration::from_millis(DELAY_MS));
        }

        // Mark the last element of this pass as sorted
        sorted[n - i - 1] = true;

        // If no swaps occurred, the array is sorted
        if !swapped {
            // Mark all remaining elements as sorted
            for item in sorted.iter_mut().take(n - i - 1) {
                *item = true;
            }
            break;
        }
    }

    // Final visualization showing all bars in green
    draw_array(array, None, None, &sorted);
    next_frame().await;
    thread::sleep(Duration::from_millis(1000));
}

fn window_conf() -> Conf {
    Conf {
        window_title: "Bubble Sort - Rust with Macroquad".to_owned(),
        window_width: WINDOW_WIDTH as i32,
        window_height: WINDOW_HEIGHT as i32,
        window_resizable: false,
        ..Default::default()
    }
}

#[macroquad::main(window_conf)]
async fn main() {
    // Create and shuffle array
    let mut array: Vec<usize> = (1..=ARRAY_SIZE).collect();
    let mut rng = rand::thread_rng();
    array.shuffle(&mut rng);

    // Show initial state
    let sorted = vec![false; ARRAY_SIZE];
    draw_array(&array, None, None, &sorted);
    next_frame().await;
    thread::sleep(Duration::from_millis(1000));

    // Sort and visualize
    bubble_sort(&mut array).await;

    // Wait a bit before closing
    thread::sleep(Duration::from_millis(2000));
}
