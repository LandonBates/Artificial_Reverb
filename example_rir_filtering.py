##############################################################################
# File: example_rir_filtering.py
# Author: Landon Bates
# Description: Reads in a RIR file and an audio input and filters the right
# channel of the audio input with the right channel of the RIR. Saves the
# resulting audio into a new .wav file and plays it.
###############################################################################
import numpy as np
import scipy.io.wavfile as wav
import sounddevice as sd

# Read in RIR audio data
samplerate, RIR = wav.read('RIR_1.wav')
# Trim off data that comes before the impulse
RIR = RIR[np.where(RIR == np.amax(RIR))[0][0]:]
# Normalize the RIR to the tap with the max value
RIR = RIR/np.amax(RIR)

# Read in audio input data
samplerate1, audio_in = wav.read("wav1.wav")
# Normalize the audio input to the sample with the max value
audio_in = audio_in/np.amax(audio_in)

# Pad the RIR with zeros so it is the same length as the input
RIRpad = np.zeros(len(audio_in[:,0]))
RIRpad[:len(RIR[:,0])] = RIR[:,0]

# Convolve the audio input with the RIR
RIR_conv = (np.fft.ifft(np.fft.fft(RIRpad)*np.fft.fft(audio_in[:,0]))).real

# Normalize the convolved audio the sample with the max value
RIR_conv = RIR_conv/(np.amax(RIR_conv))

# Reshape the convolved audio into a format that wav and sd like
RIR_conv = np.reshape(RIR_conv, (len(RIR_conv),1))

# Save convolved audio into a .wav file
wav.write("filtered_audio.wav", samplerate, RIR_conv)

# Play the convolved audio through the speakers
sd.play(RIR_conv , samplerate)
sd.wait()
sd.stop()