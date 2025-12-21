#include <SDL2/SDL.h>
#include <SDL2/SDL_mixer.h>
#include <vector>
#include <random>
#include <algorithm>
#include <thread>
#include <chrono>
#include <cmath>

// Configuration - Students can change these!
const int ARRAY_SIZE = 100;
const int WINDOW_WIDTH = 800;
const int WINDOW_HEIGHT = 600;
const int DELAY_MS = 10;  // Milliseconds between each comparison

// Color structure for RGB values
struct Color {
    uint8_t r, g, b;
};

// Convert HSV to RGB for rainbow colors
Color hsvToRgb(float h, float s, float v) {
    float c = v * s;
    float x = c * (1 - std::abs(fmod(h / 60.0, 2) - 1));
    float m = v - c;

    float r, g, b;
    if (h < 60) { r = c; g = x; b = 0; }
    else if (h < 120) { r = x; g = c; b = 0; }
    else if (h < 180) { r = 0; g = c; b = x; }
    else if (h < 240) { r = 0; g = x; b = c; }
    else if (h < 300) { r = x; g = 0; b = c; }
    else { r = c; g = 0; b = x; }

    return {
        static_cast<uint8_t>((r + m) * 255),
        static_cast<uint8_t>((g + m) * 255),
        static_cast<uint8_t>((b + m) * 255)
    };
}

// Get color for a bar based on its value
Color getBarColor(int value, int maxValue) {
    // Map value to hue (0-360 degrees)
    // Low values = red/orange (0-60), high values = blue/purple (240-300)
    float hue = (value * 280.0f) / maxValue;
    return hsvToRgb(hue, 0.8f, 0.9f);
}

// Visualization class to handle drawing
class Visualizer {
private:
    SDL_Window* window;
    SDL_Renderer* renderer;
    Mix_Chunk* beep;
    int barWidth;

public:
    Visualizer() : window(nullptr), renderer(nullptr), beep(nullptr) {
        if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO) < 0) {
            throw std::runtime_error("SDL initialization failed");
        }

        if (Mix_OpenAudio(44100, MIX_DEFAULT_FORMAT, 2, 2048) < 0) {
            throw std::runtime_error("SDL_mixer initialization failed");
        }

        window = SDL_CreateWindow(
            "Bubble Sort - C++ with SDL2",
            SDL_WINDOWPOS_CENTERED,
            SDL_WINDOWPOS_CENTERED,
            WINDOW_WIDTH,
            WINDOW_HEIGHT,
            SDL_WINDOW_SHOWN
        );

        if (!window) {
            throw std::runtime_error("Window creation failed");
        }

        renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
        if (!renderer) {
            throw std::runtime_error("Renderer creation failed");
        }

        barWidth = WINDOW_WIDTH / ARRAY_SIZE;
    }

    ~Visualizer() {
        if (beep) Mix_FreeChunk(beep);
        if (renderer) SDL_DestroyRenderer(renderer);
        if (window) SDL_DestroyWindow(window);
        Mix_CloseAudio();
        SDL_Quit();
    }

    // Draw the array with optional highlighting
    void draw(const std::vector<int>& array, int compareIdx1 = -1, int compareIdx2 = -1,
              const std::vector<bool>& sorted = {}) {
        // Clear screen with dark background
        SDL_SetRenderDrawColor(renderer, 20, 20, 30, 255);
        SDL_RenderClear(renderer);

        // Draw each bar
        for (size_t i = 0; i < array.size(); i++) {
            int barHeight = (array[i] * WINDOW_HEIGHT) / ARRAY_SIZE;
            int x = i * barWidth;
            int y = WINDOW_HEIGHT - barHeight;

            Color color;

            // Highlight sorted positions in green
            if (!sorted.empty() && sorted[i]) {
                color = {0, 255, 0};
            }
            // Highlight compared elements in red
            else if (i == compareIdx1 || i == compareIdx2) {
                color = {255, 50, 50};
            }
            // Normal rainbow colors
            else {
                color = getBarColor(array[i], ARRAY_SIZE);
            }

            SDL_Rect bar = {x, y, barWidth - 1, barHeight};
            SDL_SetRenderDrawColor(renderer, color.r, color.g, color.b, 255);
            SDL_RenderFillRect(renderer, &bar);
        }

        SDL_RenderPresent(renderer);
    }

    // Play a tone based on value (higher value = higher pitch)
    void playTone(int value) {
        // Simple beep - in a full implementation, you'd generate tones
        // For now, this is a placeholder for when audio files are added
    }

    // Check for quit events
    bool shouldQuit() {
        SDL_Event event;
        while (SDL_PollEvent(&event)) {
            if (event.type == SDL_QUIT) {
                return true;
            }
            if (event.type == SDL_KEYDOWN && event.key.keysym.sym == SDLK_ESCAPE) {
                return true;
            }
        }
        return false;
    }
};

// Bubble Sort with visualization
void bubbleSort(std::vector<int>& array, Visualizer& viz) {
    int n = array.size();
    std::vector<bool> sorted(n, false);

    for (int i = 0; i < n - 1; i++) {
        bool swapped = false;

        for (int j = 0; j < n - i - 1; j++) {
            // Check for quit
            if (viz.shouldQuit()) return;

            // Visualize comparison
            viz.draw(array, j, j + 1, sorted);
            viz.playTone(array[j]);

            // The actual bubble sort logic
            if (array[j] > array[j + 1]) {
                std::swap(array[j], array[j + 1]);
                swapped = true;
            }

            // Delay so we can see the visualization
            std::this_thread::sleep_for(std::chrono::milliseconds(DELAY_MS));
        }

        // Mark the last element of this pass as sorted
        sorted[n - i - 1] = true;

        // If no swaps occurred, the array is sorted
        if (!swapped) {
            // Mark all remaining elements as sorted
            for (int k = 0; k < n - i - 1; k++) {
                sorted[k] = true;
            }
            break;
        }
    }

    // Final visualization showing all bars in green
    viz.draw(array, -1, -1, sorted);
    std::this_thread::sleep_for(std::chrono::milliseconds(1000));
}

int main(int argc, char* argv[]) {
    try {
        // Create and shuffle array
        std::vector<int> array(ARRAY_SIZE);
        for (int i = 0; i < ARRAY_SIZE; i++) {
            array[i] = i + 1;
        }

        std::random_device rd;
        std::mt19937 gen(rd());
        std::shuffle(array.begin(), array.end(), gen);

        // Create visualizer
        Visualizer viz;

        // Show initial state
        viz.draw(array);
        std::this_thread::sleep_for(std::chrono::milliseconds(1000));

        // Sort and visualize
        bubbleSort(array, viz);

        // Wait a bit before closing
        std::this_thread::sleep_for(std::chrono::milliseconds(2000));

    } catch (const std::exception& e) {
        SDL_ShowSimpleMessageBox(SDL_MESSAGEBOX_ERROR, "Error", e.what(), nullptr);
        return 1;
    }

    return 0;
}
