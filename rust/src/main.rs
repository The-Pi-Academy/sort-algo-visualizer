mod visualizer;
mod algorithms;

use macroquad::prelude::*;
use macroquad::rand::ChooseRandom;
use std::thread;
use std::time::Duration;

use visualizer::{AudioSystem, draw_array, position_window_right, get_screen_size, ARRAY_SIZE};
use algorithms::{SortAlgorithm, algorithm_to_string, string_to_algorithm};
use algorithms::bubble_sort::bubble_sort;
use algorithms::selection_sort::selection_sort;

// STUDENTS: Change this to pick which algorithm to use!
// Options: SortAlgorithm::Bubble or SortAlgorithm::Selection
const ALGORITHM: SortAlgorithm = SortAlgorithm::Bubble;

fn window_conf() -> Conf {
    // Get actual screen dimensions
    let (screen_width, screen_height) = get_screen_size();

    let window_width = screen_width / 2;
    let window_height = screen_height;

    Conf {
        window_title: format!("{} - Rust with Macroquad", algorithm_to_string(ALGORITHM)),
        window_width,
        window_height,
        window_resizable: false,
        ..Default::default()
    }
}

#[macroquad::main(window_conf)]
async fn main() {
    // Parse command line arguments for algorithm selection
    let args: Vec<String> = std::env::args().collect();
    let algorithm = if args.len() > 1 {
        string_to_algorithm(&args[1])
    } else {
        ALGORITHM
    };

    println!("\n╔════════════════════════════════════════╗");
    println!("║   SORTING VISUALIZER - Rust Macroquad  ║");
    println!("╚════════════════════════════════════════╝");
    println!("\nAlgorithm: {}", algorithm_to_string(algorithm));
    println!("Initializing...");

    // Position the window on the right side of the screen
    // Wait a frame for the window to be created
    next_frame().await;
    position_window_right();

    // Initialize audio system
    let audio = match AudioSystem::new() {
        Ok(audio) => audio,
        Err(e) => {
            eprintln!("Warning: Failed to initialize audio: {}", e);
            eprintln!("Continuing without sound...");
            // For now, we'll just panic if audio fails
            // In a real app, you might want to continue without audio
            panic!("Audio initialization failed");
        }
    };

    // Create and shuffle array
    let mut array: Vec<usize> = (1..=ARRAY_SIZE).collect();
    array.shuffle();

    println!("Created array with {} elements", ARRAY_SIZE);
    println!("Array shuffled randomly");
    println!("Window created successfully");
    println!("Press ESC to quit anytime");

    // Show initial state
    let sorted = vec![false; ARRAY_SIZE];
    draw_array(&array, None, None, &sorted, algorithm);
    next_frame().await;
    thread::sleep(Duration::from_millis(1000));

    // Sort and visualize - pick the right algorithm
    match algorithm {
        SortAlgorithm::Bubble => bubble_sort(&mut array, algorithm, &audio).await,
        SortAlgorithm::Selection => selection_sort(&mut array, algorithm, &audio).await,
        // SortAlgorithm::Insertion => insertion_sort(&mut array, algorithm, &audio).await,
        // Add more algorithms here as they're implemented!
    }

    // Wait a bit before closing
    thread::sleep(Duration::from_millis(2000));
}
