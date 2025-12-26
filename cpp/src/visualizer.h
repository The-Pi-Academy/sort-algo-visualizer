#ifndef VISUALIZER_H
#define VISUALIZER_H

#include <SDL2/SDL.h>
#include <SDL2/SDL_mixer.h>
#include <SDL2/SDL_ttf.h>
#include <vector>
#include <string>
#include <sstream>
#include <iostream>
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
inline Color hsvToRgb(float h, float s, float v) {
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
inline Color getBarColor(int value, int maxValue) {
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
    std::vector<Mix_Chunk*> tones;
    std::vector<Uint8*> toneBuffers;  // Track buffers for cleanup
    TTF_Font* font;
    int barWidth;
    int windowWidth;
    int windowHeight;

    // Generate a sine wave tone at a specific frequency
    Mix_Chunk* generateTone(float frequency, int durationMs) {
        int sampleRate = 44100;
        int samples = (sampleRate * durationMs) / 1000;

        // Allocate audio buffer (2 bytes per sample for 16-bit audio)
        Uint8* buffer = new Uint8[samples * 2];
        toneBuffers.push_back(buffer);  // Track for cleanup
        Sint16* samples16 = (Sint16*)buffer;

        // Generate sine wave with fade-out envelope
        for (int i = 0; i < samples; i++) {
            float time = (float)i / sampleRate;
            float value = std::sin(2.0f * M_PI * frequency * time);

            // Apply envelope for smooth fade-out (prevents clicking)
            float envelope = 1.0f - ((float)i / samples);
            samples16[i] = (Sint16)(value * envelope * 8192);  // ~25% max volume
        }

        // Create Mix_Chunk from raw audio data
        Mix_Chunk* chunk = Mix_QuickLoad_RAW(buffer, samples * 2);
        return chunk;
    }

    // Helper function to render text
    void renderText(const std::string& text, int x, int y, SDL_Color color) {
        SDL_Surface* surface = TTF_RenderText_Blended(font, text.c_str(), color);
        if (!surface) return;

        SDL_Texture* texture = SDL_CreateTextureFromSurface(renderer, surface);
        if (!texture) {
            SDL_FreeSurface(surface);
            return;
        }

        SDL_Rect rect = {x, y, surface->w, surface->h};
        SDL_RenderCopy(renderer, texture, nullptr, &rect);

        SDL_DestroyTexture(texture);
        SDL_FreeSurface(surface);
    }

public:
    Visualizer() : window(nullptr), renderer(nullptr), font(nullptr) {
        if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO) < 0) {
            throw std::runtime_error("SDL initialization failed");
        }

        if (TTF_Init() < 0) {
            throw std::runtime_error("SDL_ttf initialization failed");
        }

        if (Mix_OpenAudio(44100, MIX_DEFAULT_FORMAT, 2, 2048) < 0) {
            throw std::runtime_error("SDL_mixer initialization failed");
        }

        // Generate tones programmatically for each array value
        // Frequency range: 200Hz (low) to 2000Hz (high)
        std::cout << "Generating " << ARRAY_SIZE << " tones..." << std::flush;
        float minFreq = 200.0f;
        float maxFreq = 2000.0f;

        for (int i = 0; i < ARRAY_SIZE; i++) {
            // Map array index to frequency
            float freq = minFreq + ((float)i / ARRAY_SIZE) * (maxFreq - minFreq);
            Mix_Chunk* tone = generateTone(freq, 50);  // 50ms duration
            if (tone) {
                tones.push_back(tone);
            }
        }
        std::cout << " Done!\n";

        // Get display bounds to calculate window size
        SDL_Rect displayBounds;
        if (SDL_GetDisplayBounds(0, &displayBounds) != 0) {
            throw std::runtime_error("Failed to get display bounds");
        }

        // Calculate left 50% of screen
        windowWidth = displayBounds.w / 2;
        windowHeight = displayBounds.h;

        window = SDL_CreateWindow(
            "Bubble Sort - C++ with SDL2",
            0,  // Left edge of screen
            0,  // Top edge of screen
            windowWidth,
            windowHeight,
            SDL_WINDOW_SHOWN
        );

        if (!window) {
            throw std::runtime_error("Window creation failed");
        }

        renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
        if (!renderer) {
            throw std::runtime_error("Renderer creation failed");
        }

        // Load font - try multiple common paths for cross-platform support
        const char* fontPaths[] = {
            "/System/Library/Fonts/Helvetica.ttc",  // macOS
            "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",  // Linux/Raspberry Pi
            "/usr/share/fonts/TTF/DejaVuSans.ttf"  // Alternative Linux path
        };

        for (const char* path : fontPaths) {
            font = TTF_OpenFont(path, 20);
            if (font) break;
        }

        if (!font) {
            throw std::runtime_error("Failed to load font");
        }

        barWidth = windowWidth / ARRAY_SIZE;
    }

    ~Visualizer() {
        for (Mix_Chunk* chunk : tones) {
            if (chunk) {
                chunk->abuf = nullptr;  // Don't let Mix_FreeChunk free our buffer
                Mix_FreeChunk(chunk);
            }
        }
        // Free the tone buffers we allocated
        for (Uint8* buffer : toneBuffers) {
            delete[] buffer;
        }
        if (font) TTF_CloseFont(font);
        if (renderer) SDL_DestroyRenderer(renderer);
        if (window) SDL_DestroyWindow(window);
        Mix_CloseAudio();
        TTF_Quit();
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
            int barHeight = (array[i] * windowHeight) / ARRAY_SIZE;
            int x = i * barWidth;
            int y = windowHeight - barHeight;

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

        // Render info overlay at top-left
        SDL_Color textColor = {255, 255, 255, 255};  // White text
        std::stringstream ss;

        ss.str("");
        ss << "Array Size: " << ARRAY_SIZE;
        renderText(ss.str(), 10, 10, textColor);

        ss.str("");
        ss << "Window: " << windowWidth << "x" << windowHeight;
        renderText(ss.str(), 10, 35, textColor);

        ss.str("");
        ss << "Delay: " << DELAY_MS << "ms";
        renderText(ss.str(), 10, 60, textColor);

        ss.str("");
        ss << "Algorithm: Bubble Sort (O(n^2))";
        renderText(ss.str(), 10, 85, textColor);

        SDL_RenderPresent(renderer);
    }

    // Play a tone based on value (higher value = higher pitch)
    void playTone(int value) {
        if (tones.empty() || value < 1) return;

        // Each array value (1 to ARRAY_SIZE) maps directly to a tone
        int toneIndex = value - 1;  // Arrays are 0-indexed, values are 1-indexed
        if (toneIndex >= tones.size()) toneIndex = tones.size() - 1;

        // Play the tone on dedicated channel (no overlap)
        // No need for Mix_PlayChannelTimed since our generated tones are already 50ms
        Mix_HaltChannel(0);  // Stop previous sound
        Mix_PlayChannel(0, tones[toneIndex], 0);
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

#endif // VISUALIZER_H
