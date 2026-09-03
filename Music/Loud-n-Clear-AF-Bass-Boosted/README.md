# Loud-n-Clear AF Bass Boosted

An [EasyEffects](https://github.com/wwmm/easyeffects) preset designed to make inexpensive or weak speakers sound **louder, fuller, and bassier** without excessively boosting the treble.

The preset focuses on improving the **perceived bass and overall loudness** while keeping the upper frequencies controlled. This helps avoid the thin, harsh, or hiss-heavy sound that can result from simply increasing treble or applying aggressive EQ.

## Features

* 🔊 Increased perceived loudness
* 🥁 Enhanced bass with harmonic generation
* 🎚️ Controlled low and mid frequencies
* 🧹 Reduced muddiness through multiband compression
* ✨ No aggressive treble enhancement
* 🛡️ Limiting to control excessive peaks
* 🎧 Tuned for inexpensive speakers and systems with weak bass

## Processing Chain

The preset uses the following EasyEffects plugins, in this order:

```text
High-pass Filter
      ↓
Bass Enhancer
      ↓
Multiband Compressor
      ↓
Limiter
      ↓
Loudness
```

### 1. High-pass Filter

A **130 Hz high-pass filter** removes very low frequencies that inexpensive speakers generally cannot reproduce effectively.

This prevents wasting amplifier/speaker excursion on sub-bass that may only produce distortion or rattling.

### 2. Bass Enhancer

The Bass Enhancer is the main source of the increased bass perception.

| Setting     |  Value |
| ----------- | -----: |
| Amount      |     16 |
| Scope       | 180 Hz |
| Harmonics   |     10 |
| Floor       |     10 |
| Input Gain  |  -6 dB |
| Output Gain |  -6 dB |

Rather than relying purely on raw low-frequency amplification, harmonic enhancement helps create the **perception of stronger bass** from speakers with limited low-frequency reproduction.

### 3. Multiband Compressor

The multiband compressor controls the dynamics of the low and mid frequencies.

The active bands are:

* **250–1000 Hz**
* **1000–2000 Hz**
* **2000–5000 Hz**

The higher-frequency bands are disabled.

This is intentional: the preset aims to increase fullness without making the high end unnecessarily aggressive.

### 4. Limiter

The limiter sits after the compressor to catch peaks created by the preceding processing.

This helps keep the heavily processed signal under control when the source material becomes loud.

### 5. Loudness

The Loudness plugin provides the final perceived-volume enhancement.

Current settings include:

* FFT mode
* ISO 226:2023 standard
* +3 dB input gain
* +6 dB output gain
* Volume: 3 dB

## Intended Sound

The target sound is:

> **Loud + bass-heavy + full + controlled**

rather than:

> Loud + excessively bright + harsh

It is particularly intended for speakers that sound thin when used without processing and become unpleasant when their treble is simply boosted to compensate for weak bass.

## Installation

1. Install **EasyEffects**.
2. Open EasyEffects.
3. Import:

   `Loud-n-Clear-AF-Bass-Boosted.json`
4. Select the imported preset for your output device.
5. Enable the required EasyEffects output effects.

The preset is intended for **EasyEffects Output** processing.

## Notes

This is a **speaker-oriented preset**, not a neutral or audiophile reference preset.

The settings are deliberately tuned toward a more energetic presentation. Results will vary depending on the speaker, amplifier, audio device, listening volume, and source material.

If your speaker produces distortion or rattling at high volume, reduce the system/output volume rather than continuing to increase the processing gain.

## Preset

**File:** `Loud-n-Clear-AF-Bass-Boosted.json`

**Type:** EasyEffects Output Preset

**Primary goal:** Bass enhancement and loudness for inexpensive speakers

**Status:** Tuned / Working
