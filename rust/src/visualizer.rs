use macroquad::prelude::*;
use std::sync::Arc;
use rodio::{OutputStream, Sink};

use crate::algorithms::SortAlgorithm;

// Configuration - Students can change these!
pub const ARRAY_SIZE: usize = 100;
pub const DELAY_MS: u64 = 10;  // Milliseconds between each comparison

// Audio configuration
const SAMPLE_RATE: u32 = 44100;
const TONE_DURATION_MS: u32 = 50;
const MIN_FREQUENCY: f32 = 200.0;
const MAX_FREQUENCY: f32 = 2000.0;

// Color structure for RGB values (matching C++ visualizer.h)
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

// Generate a sine wave tone at a specific frequency
fn generate_tone(frequency: f32, duration_ms: u32) -> Vec<i16> {
    let sample_rate = SAMPLE_RATE as f32;
    let samples = (sample_rate * duration_ms as f32 / 1000.0) as usize;
    let mut buffer = Vec::with_capacity(samples);

    for i in 0..samples {
        let time = i as f32 / sample_rate;
        let value = (2.0 * std::f32::consts::PI * frequency * time).sin();

        // Apply envelope for smooth fade-out (prevents clicking)
        let envelope = 1.0 - (i as f32 / samples as f32);
        let sample = (value * envelope * 8192.0) as i16; // ~25% max volume

        buffer.push(sample);
    }

    buffer
}

// Audio system to manage playback
pub struct AudioSystem {
    _stream: OutputStream,
    sink: Arc<Sink>,
    tones: Vec<Vec<i16>>,
}

impl AudioSystem {
    pub fn new() -> Result<Self, Box<dyn std::error::Error>> {
        let (stream, stream_handle) = OutputStream::try_default()?;
        let sink = Arc::new(Sink::try_new(&stream_handle)?);

        println!("Generating {} tones...", ARRAY_SIZE);

        let mut tones = Vec::new();
        for i in 0..ARRAY_SIZE {
            // Map array index to frequency
            let freq = MIN_FREQUENCY + ((i as f32 / ARRAY_SIZE as f32) * (MAX_FREQUENCY - MIN_FREQUENCY));
            let tone = generate_tone(freq, TONE_DURATION_MS);
            tones.push(tone);
        }

        println!("Done!");

        Ok(AudioSystem {
            _stream: stream,
            sink,
            tones,
        })
    }

    // Play a tone based on value (higher value = higher pitch)
    pub fn play_tone(&self, value: usize) {
        if value == 0 || value > ARRAY_SIZE {
            return;
        }

        // Map value (1-indexed) to tone (0-indexed)
        let tone_index = value - 1;
        if tone_index >= self.tones.len() {
            return;
        }

        // Get the tone samples
        let tone = &self.tones[tone_index];

        // Create a source from raw samples
        let source = rodio::buffer::SamplesBuffer::new(1, SAMPLE_RATE, tone.clone());

        // Stop previous tone and play new one
        self.sink.stop();
        self.sink.append(source);
        self.sink.play();
    }
}

// Draw the array with optional highlighting
pub fn draw_array(
    array: &[usize],
    compare_idx1: Option<usize>,
    compare_idx2: Option<usize>,
    sorted: &[bool],
    algorithm: SortAlgorithm,
) {
    // Clear screen with dark background
    clear_background(Color::new(0.08, 0.08, 0.12, 1.0));

    let window_width = screen_width();
    let window_height = screen_height();
    let bar_width = window_width / ARRAY_SIZE as f32;

    // Draw each bar
    for (i, &value) in array.iter().enumerate() {
        let bar_height = (value as f32 * window_height) / ARRAY_SIZE as f32;
        let x = i as f32 * bar_width;
        let y = window_height - bar_height;

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

    // Draw info overlay at top-left
    let text_color = WHITE;
    let font_size = 20.0;
    let y_offset = 20.0;

    draw_text(
        &format!("Algorithm: {}", crate::algorithms::algorithm_to_string(algorithm)),
        10.0,
        y_offset,
        font_size,
        text_color,
    );
    draw_text(
        &format!("Time Complexity: {}", crate::algorithms::get_time_complexity(algorithm)),
        10.0,
        y_offset + 25.0,
        font_size,
        text_color,
    );
    draw_text(
        &format!("Space Complexity: {}", crate::algorithms::get_space_complexity(algorithm)),
        10.0,
        y_offset + 50.0,
        font_size,
        text_color,
    );
    draw_text(
        &format!("Array Size: {}", ARRAY_SIZE),
        10.0,
        y_offset + 75.0,
        font_size,
        text_color,
    );
    draw_text(
        &format!("Delay: {}ms", DELAY_MS),
        10.0,
        y_offset + 100.0,
        font_size,
        text_color,
    );
}

// Get actual screen dimensions (platform-specific)
#[cfg(target_os = "macos")]
pub fn get_screen_size() -> (i32, i32) {
    use core_graphics::display::CGDisplay;
    let display = CGDisplay::main();
    let bounds = display.bounds();
    (bounds.size.width as i32, bounds.size.height as i32)
}

#[cfg(not(target_os = "macos"))]
pub fn get_screen_size() -> (i32, i32) {
    // Default to common screen size for other platforms
    (1920, 1080)
}

// Position window on macOS (right 50% of screen)
#[cfg(target_os = "macos")]
pub fn position_window_right() {
    use cocoa::appkit::{NSWindow, NSApplication};
    use cocoa::base::nil;
    use cocoa::foundation::NSPoint;
    use objc::{msg_send, sel, sel_impl};

    unsafe {
        let app = NSApplication::sharedApplication(nil);
        let window: cocoa::base::id = msg_send![app, mainWindow];

        if window != nil {
            let (screen_width, _) = get_screen_size();
            let frame = NSWindow::frame(window);

            // Position at right half of screen
            // Note: macOS uses bottom-left origin, so y stays the same
            let new_origin = NSPoint::new((screen_width / 2) as f64, frame.origin.y);
            window.setFrameOrigin_(new_origin);
        }
    }
}

#[cfg(not(target_os = "macos"))]
pub fn position_window_right() {
    // Window positioning not implemented for this platform
    // The window will appear in the default location
    eprintln!("Note: Window positioning is only supported on macOS.");
    eprintln!("Please manually position this window on the right half of your screen.");
}
