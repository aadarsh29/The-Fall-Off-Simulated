# 🏟️ J. Cole: Live at Wrigley Field (A DSP Simulation)

> *"After The Fall Off, I promise I'm comin' and sellin' out Wrigley's"*  
> — **J. Cole**, *m y . l i f e* (2021)

--- 

### 🎙️ The Inspiration
One of my favorite J. Cole tracks of all time is "m y . l i f e," and in it, Cole promises the fans a Wrigley's concert after the culmination of his discography with the long-awaited "Fall Off" which came out on Feb 6th, 2026 and consisted of some of his most reflective work. One of my favorite songs from the album was Bombs in the Ville, and I wanted to see if I could use the principles of signal processing to recreate what it would sound like if it was played at Wrigleys! So, I built a **Digital Signal Processing (DSP)** pipeline to manifest the concert myself.

### ⚾ The Impulse: A Baseball Bat
To recreate the acoustics of a stadium, you need a characteristic **Impulse Response (IR)**. While most people use a generic "click" or a starter pistol, I decided to be more practical and find a clip of a baseball crack when the Chicago Cubs played the Pirates at Wrigley Field in 2024, a historic game in its own right with the Cubs throwing the first no-hitter at Wrigley Field since  1972. 

By convolving J. Cole’s studio track with the reverberation profile of that bat hit, I was able to model the reflections, decay, and atmospheric "smear" of an outdoor stadium environment.

---

### 🛠️ How I Saw It Through
I approached this project with a "sprint" mindset—focusing on turning a creative idea into a mathematically validated reality.

1.  **Cleaning the Impulse:** The raw bat recording was "dirty," the low-end mechanical "thump" from the baseball hit itself. I implemented a **4th-order Butterworth high-pass filter ($f_c = 500$ Hz)** to isolate the sharp, high-frequency "crack" essential for a clean convolution.
2.  **Optimized Computation:** To handle full-length songs, I moved away from standard time-domain convolution ($O(N^2)$) and built a **Frequency-Domain engine**. By utilizing **Radix-2 FFTs** and proper **Zero-Padding** (comes in handy since the FFT is a divide and conquer algorithm, so the nearest power of 2 allows us to implement the FFT efficiently), I achieved the computational efficiency needed for high-resolution audio processing.
3.  **The Mix:** I balanced the dry studio vocals with the "wet" stadium reflections to ensure the lyrics remained intelligible while sitting deep within the Wrigley Field "bloom."

---

### 📊 The Results: Proof of Environment
I used signal metrics to verify that the audio wasn't just "louder," but was actually transformed by the environment:

<img width="1920" height="1073" alt="Before vs After Amplitude vs Time" src="https://github.com/user-attachments/assets/1eda30f2-d02c-4db0-9c74-9a5bef6140e1" /> </img>
Comparison of the audio signals waveforms between the original J. Cole track and the one with the Wrigley's effect (Notice how the modified track is softer as a byproduct of normalization)

<img width="1920" height="1073" alt="Before vs After Spectrogram" src="https://github.com/user-attachments/assets/a3da70b9-8d6c-460c-a2b9-682c50e4ced1" /> </img>
Comparison of the spectrograms between the original J. Cole track and the one with the Wrigley's effect (Notice how the bass sounds are more boosted in the stadium, and the stadium shows a lot more smearing in the spectrogram, due to the stadium reflections and reverb)

| Metric | Original (Studio) | Wrigley Mix (Wet) | Engineering Takeaway |
| :--- | :--- | :--- | :--- |
| **PAPR** | 12.96 dB | 17.37 dB | **+4.41 dB** delta; successfully modeled high-dynamic-range transients within the mix. |
| **Spectral Centroid** | 2,458.27 Hz | 2,189.91 Hz | **-268.36 Hz** shift; quantifies the warmth and low-mid resonance characteristic of Wrigley Field. |

---
## 🎧 Demo
Click below to listen and compare the two tracks side by side:

👉 **[Listen to the Audio Demo](https://aadarsh29.github.io/The-Fall-Off-Simulated/)**

---

### 📂 Technical Stack & Concepts
*   **Engine:** MATLAB
*   **DSP Fundamentals:** 
    *   Frequency-Domain (FFT-based) Fast Convolution
    *   Butterworth Filter Design (IIR)
    *   Spectral Centroid Analysis
    *   Peak-to-Average Power Ratio (PAPR) Characterization

### 🎧 How to Run
1. Download the `playing_at_wrigleys.m` file and the `wrigleys_ir.mp3`.
2. Place your source audio in the same folder.
3. Run `playing_at_wrigeys.m`.
4. Check the same folder for your processed `.wav`.

