# Audio Assets

This directory is for audio files that can be played during sorting visualization.

## What Goes Here

You can add `.wav` sound files that will play when bars are compared or moved. The visualizers map values to different pitches, so you could add:

- `tone_low.wav` - Low pitch sound
- `tone_medium.wav` - Medium pitch sound
- `tone_high.wav` - High pitch sound

Or create 10-20 different tone files for more granular pitch mapping.

## How to Create Simple Tones

### Using Audacity (Free and Cross-Platform)

1. Download Audacity from https://www.audacityteam.org/
2. Generate → Tone
3. Choose sine wave
4. Set frequency (e.g., 220Hz for A, 440Hz for A an octave higher)
5. Set duration to 0.1 seconds
6. Export as WAV file

### Using Online Tools

- https://www.szynalski.com/tone-generator/ - Generate and download tones
- https://onlinetonegenerator.com/ - Another simple tone generator

### Frequencies to Try

For a musical scale across your array:
- C4: 261.63 Hz
- D4: 293.66 Hz
- E4: 329.63 Hz
- F4: 349.23 Hz
- G4: 392.00 Hz
- A4: 440.00 Hz
- B4: 493.88 Hz
- C5: 523.25 Hz

## For Students

This is optional! The visualizers work great with just the visual colors. But adding sound makes it even more engaging. Try:

1. Creating 3-5 different tones
2. Running your visualizer
3. Listening to how different algorithms create different "songs"

## Implementation Notes

The current code has placeholder audio functions. To fully integrate audio:

**C++**: Use `Mix_LoadWAV()` to load files and `Mix_PlayChannel()` to play them
**Rust**: Use the `macroquad::audio` module to load and play sounds

This can be a great extension project for advanced students!
