%% --- STAGE 0: INITIALIZATION ---
clear; clc; close all;

% Filenames
song_file = 'J_Cole_Bombs_in_the_Ville.mp3';
ir_file = 'wrigleys_ir.mp3';

%% --- STAGE 1: LOAD & RESAMPLE ---

% fs_s and fs_ir are 44.1 kHz as expected  
% song_raw and ir_raw are basically vector arrays representing their 
% respective audio ie the Bombs in the Ville track and the Impulse Reponse
% Both tracks are stereo so we end up with a N x 2 array for each
% song_raw is an array with N = 44.1 kHz * ~247 seconds = 10,874,352 points
% ir_raw is an array with N = 44.1 kHz * ~1 second = 49,008 points
[song_raw, fs_s] = audioread(song_file); 
[ir_raw, fs_ir] = audioread(ir_file);

% Convert to Mono for the math (standard DSP practice)
% basically takes the mean to ensure arrays are of size N x 1
song = mean(song_raw, 2);
ir = mean(ir_raw, 2);

% Match Sample Rates (safety feature only, fs_s = fs_r = 44.1 kHz)
if fs_s ~= fs_ir
    ir = resample(ir, fs_s, fs_ir);
end
fs = fs_s;

%% --- STAGE 2: IR CONDITIONING (The "Wrigley" Prep) ---
% 1. Crop to the crack: Find the peak of the bat hit

% stores the index of the peak of the impulse and 
% keeps everything after to avoid anything that isn't the bat hit that
% gets captured by the microphone
[~, start_idx] = max(abs(ir)); 
ir = ir(start_idx:end); 

% 2. High-Pass Filter: Remove the wooden thump (keep > 500Hz)

% used a 4-stage butterworth high pass filter to filter out 
% the low frequency sound to ensure that just the response of the 
% bat (high frequency) hit is retained and the thump (low frequency)
[b, a] = butter(4, 500/(fs/2), 'high');
ir_clean = filter(b, a, ir);

% 3. Windowing: Ensure the 1s clip fades smoothly to zero
% we want to fade the impulse response for about 0.1 seconds or 
% 4,410 samples of the ~1 second clip ie fade_len is 4,410
% the window is made such that the first bit of the clip is unchanged
% the last 0.1 seconds is faded linearly over 4,410 samples
% this helps us create our impulse response function h
fade_len = round(0.1 * fs); 
window = [ones(length(ir_clean)-fade_len, 1); linspace(1, 0, fade_len)'];
h = ir_clean .* window;

%% --- STAGE 3: THE CONVOLUTION ENGINE ---
Lx = length(song);
Lh = length(h);
Ly = Lx + Lh - 1;

% Find the next power of 2 for FFT efficiency
% FFT is more efficient than the DFT because of the log_2(N) property that
% arises because of its recursive divide and conquer nature so rounding
% off to the nearest power of 2 makes O(N^2) O(Nlog_2(N))
Nfft = 2^nextpow2(Ly);

% The Math: Y(f) = X(f) * H(f) 
% (convolution in the frequency domain is just multiplication)
X_freq = fft(song, Nfft);
H_freq = fft(h, Nfft);
Y_freq = X_freq .* H_freq;

% Back to Time Domain
% wet audio with extra zeros between Ly and Nfft is trimmed to remove 
% unnecessary zeros at the end, we include only the real part to avoid
% floating point rounding errors due to imaginary remainders from the ifft
y_wet = real(ifft(Y_freq)); 
y_wet = y_wet(1:Ly); % Trim to correct length

%% --- STAGE 4: THE PROFESSIONAL MIX ---
% Normalize the wet signal so it doesn't overpower the dry
y_wet = y_wet / max(abs(y_wet));

% Pad the original song to match the output length
song_padded = [song; zeros(Ly - Lx, 1)];

% Mix: 70% Dry (direct sound), 30% Wet (Wrigley acoustics)
final_mix = 0.5 * song_padded + 0.5 * y_wet;

% Final Normalization to avoid clipping at 0dB
final_mix = final_mix / max(abs(final_mix));

%% --- STAGE 5: EXPORT & VISUALIZE ---
audiowrite('J_Cole_Live_At_Wrigleys.wav', final_mix, fs);

subplot(2,1,1);
plot(h); title('The Wrigley Impulse Response (Bat Hit)');
subplot(2,1,2);
plot(final_mix); title('Final "Live at Wrigleys" Output');

fprintf('Success! Your track is ready.\n');