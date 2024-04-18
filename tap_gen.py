import numpy as np
from scipy import signal as sig
from matplotlib import pyplot as plt
import scipy.io.wavfile as wav
import pandas as pd

def main():

    # Read in audio data from .wav file
    samplerate, data = wav.read('RIR_1.wav')
    RIR = np.zeros(len(data))
    right = RIR

    # Seperate audio data into seperate channels
    for i in range(len(data)):
         RIR[i] = data[i][0]
         right[i] = data[i][1]

    # Remove audio data before the start of the RIR recording
    RIR = RIR[np.where(RIR == np.amax(RIR))[0][0]:]
    # Normalize the RIR
    RIR = RIR/np.amax(np.abs(RIR))

    numtaps = 2048*8

    # # Used to generate LPF for system accuracy test
    # h = sig.firwin(numtaps, 3000, fs=48000)
    # h[2048:2048+2048] = 0
    
    # Code to write n .coe files
    numfilters = 8
    for i in range(numfilters):
        count = 0
        with open(f"filter{i+1}_full.coe", "w") as f:
            f.write("radix=10;\n")
            f.write("coefdata=\n")
            while count < numtaps/numfilters:
                f.write("{:.6f},\n".format(RIR[i*int(numtaps/numfilters)+count]))
                count += 1

    # Code to generate simulated frequency response
    w, h = sig.freqz(h)

    # Code to generate measured vs. simulated frequency response plots
    df = pd.read_csv("hcope_0.csv")
    mag = df.Gain
    freq = df.Freq
    phase = df.Phase

    plt.plot(w * (24000 / np.pi), 20*np.log10(np.abs(h)), label="simulated")
    plt.plot(freq, mag, label="measured")
    plt.title("LPF Frequency Response Magnitude")
    plt.xlabel("Frequency (Hz)")
    plt.ylabel("Gain (dB)")
    plt.semilogx()
    plt.legend()
    plt.show()

    plt.plot(w * (24000 / np.pi), np.angle(h), label="simulated")
    plt.plot(freq, phase, label="measured")
    plt.title("LPF Frequency Response Phase")
    plt.xlabel("Frequency (Hz)")
    plt.ylabel("Phase (degrees)")
    plt.semilogx()
    plt.legend()
    plt.show()

if __name__ == "__main__":
    main()