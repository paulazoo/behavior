import numpy as np
import scipy.signal as signal

def butterworth_filter_leverdata(binaries_folder, num_trials, cutoff_frequency):
    """
    Applies a Butterworth filter to lever data stored in
    binary files, with the specified cutoff frequency, and saves the filtered data in new binary files.
    
    :param binaries_folder: The folder where the binary files are stored. These binary files contain the
    lever data for each trial
    :param num_trials: The parameter "num_trials" represents the number of trials or datasets that need
    to be filtered. It determines how many times the filtering process will be repeated
    :param cutoff_frequency: The cutoff frequency is the frequency at which the filter starts
    attenuating the signal. It determines the range of frequencies that will be allowed to pass through
    the filter
    :return: The function does not return anything.
    """
    for i in range(0, num_trials):
        trial_leverdata = np.fromfile(binaries_folder+"trial"+str(i)+".bin", dtype=np.double)
        trial_frequencies = np.fromfile(binaries_folder+"trial_frequencies.bin", dtype=np.double)

        # Butterworth filter parameters:
        sampling_frequency = trial_frequencies[i]
        wn = cutoff_frequency / (sampling_frequency / 2) # Normalize the frequency
        butterworth_order = 6

        # Run Butterworth Filter
        b, a = signal.butter(butterworth_order, wn, 'lowpass')
        filtered_leverdata = signal.filtfilt(b, a, trial_leverdata)

        # use numpy to same trial_frequencies into a .bin (not pickle because just in case need to reopen in C++)
        filtered_leverdata.astype('double').tofile(binaries_folder+"filtered_trial"+str(i)+".bin")
    return