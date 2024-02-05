import numpy as np
import matplotlib.pyplot as plt
import scipy.signal as signal

def view_processed_trial_FFT(trial_i, binaries_folder):
    """
    The function `view_processed_trial_FFT` reads binary files created by a C++ program, computes the
    power spectrum of the processed data, and plots it.
    
    :param trial_i: trial_i is the index of the trial you want to view the processed data for. It is
    used to load the corresponding binary file containing the processed lever data
    :param binaries_folder: The `binaries_folder` parameter is the path to the folder where the binary
    files are stored. It should be a string representing the directory path
    """

    # Read the binary file created by the C++ program which is saved as double
    trial_frequencies = np.fromfile(binaries_folder+"trial_frequencies.bin", dtype=np.double)
    processed_leverdata = np.fromfile(binaries_folder+"processed_trial"+str(trial_i)+".bin", dtype=np.double)

    fs = trial_frequencies[trial_i]
    freq, spectra = signal.periodogram(processed_leverdata, fs=fs)

    fig, ax = plt.subplots()
    ax.semilogy(freq, spectra)
    ax.set_title('Power Spectrum of '+'processed_leverdata')
    ax.set_ylabel('Power Spectral Density')
    ax.set_xlabel('Frequency [Hz]')
    plt.xlim([0, 100])
    plt.show()