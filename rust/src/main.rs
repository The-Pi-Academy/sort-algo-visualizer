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
    // Parse command line arguments
    let args: Vec<String> = std::env::args().collect();
    let mut algorithm = ALGORITHM;
    let mut array_size = ARRAY_SIZE;
    let mut delay_ms = DELAY_MS;

    let mut i = 1;
    while i < args.len() {
        match args[i].as_str() {
            "bubble" | "selection" => {
                algorithm = string_to_algorithm(&args[i]);
                i += 1;
            }
            arg if arg.starts_with("--size=") => {
                array_size = arg[7..].parse().unwrap_or(ARRAY_SIZE).min(10000).max(1);
                i += 1;
            }
            "--size" if i + 1 < args.len() => {
                array_size = args[i + 1].parse().unwrap_or(ARRAY_SIZE).min(10000).max(1);
                i += 2;
            }
            arg if arg.starts_with("--delay=") => {
                delay_ms = arg[8..].parse().unwrap_or(DELAY_MS).min(1000).max(0);
                i += 1;
            }
            "--delay" if i + 1 < args.len() => {
                delay_ms = args[i + 1].parse().unwrap_or(DELAY_MS).min(1000).max(0);
                i += 2;
            }
            _ => i += 1,
        }
    }

    println!("\n╔════════════════════════════════════════╗");
    println!("║   SORTING VISUALIZER - Rust Macroquad  ║");
    println!("╚════════════════════════════════════════╝");
    println!("\nAlgorithm: {}", algorithm_to_string(algorithm));
    println!("Array Size: {} elements", array_size);
    println!("Delay: {} ms", delay_ms);
    println!("Initializing...");

    // Position the window on the right side of the screen
    // Wait a frame for the window to be created
    next_frame().await;
    position_window_right();

    // Initialize audio system
    let audio = match AudioSystem::new(array_size) {
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
    let mut array: Vec<usize> = (1..=array_size).collect();
    array.shuffle();

    println!("Created array with {} elements", array_size);
    println!("Array shuffled randomly");
    println!("Window created successfully");
    println!("Press ESC to quit anytime");

    // Show initial state
    let sorted = vec![false; array_size];
    draw_array(&array, None, None, &sorted, algorithm, array_size, delay_ms);
    next_frame().await;
    thread::sleep(Duration::from_millis(1000));

    // Sort and visualize - pick the right algorithm
    match algorithm {
        SortAlgorithm::Bubble => bubble_sort(&mut array, algorithm, &audio, array_size, delay_ms).await,
        SortAlgorithm::Selection => selection_sort(&mut array, algorithm, &audio, array_size, delay_ms).await,
        // SortAlgorithm::Insertion => insertion_sort(&mut array, algorithm, &audio, array_size, delay_ms).await,
        // Add more algorithms here as they're implemented!
    }

    // Wait a bit before closing
    thread::sleep(Duration::from_millis(2000));
}
