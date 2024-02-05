import numpy as np
import matplotlib.pyplot as plt


def get_trial_frequencies(num_trials, respMTX, binaries_folder, show_histogram=False):
    '''
    For each trial, get the MATLAB time duration from `respMTX` (index 0 is the trial start time) and get `leverdata` from the 
    created binary .bin file. Divide the number of samples by the MATLAB time duration to get the estimated frequency and check that it's consistent.

    A lever movement can be less than 50 ms.
    '''
    dts = []
    trial_frequencies = []
    for i in range(0, num_trials-1):
        print("Trial ",i)
        # from the .mat file's respMTX, index 1 is the tone time
        trial_start_time = respMTX[i][1]
        next_trial_start_time = respMTX[i+1][1]
        print("Duration in MATLAB seconds from respMTX: ", next_trial_start_time - trial_start_time)

        # Read the binary file created by the C++ program which is saved as double
        trial_leverdata = np.fromfile(binaries_folder+"trial"+str(i)+".bin", dtype=np.double)
        print("Number of leverdata samples: ", trial_leverdata.shape[0])

        frequency = trial_leverdata.shape[0] / (next_trial_start_time - trial_start_time)
        print("Estimated freq: ", frequency)
        trial_frequencies.append(frequency)
        intersample_duration = 1 / frequency

        # check intersample durations
        for i in range(0, trial_leverdata.shape[0]):
            dts.append(intersample_duration)

    #... last trial got cut off I'm pretty sure, so assume trial_frequency didn't change much between second to last to last trial
    trial_frequencies.append(frequency)

    # use numpy to same trial_frequencies into a .bin (not pickle because just in case need to reopen in C++)
    trial_frequencies_np = np.array(trial_frequencies)
    trial_frequencies_np.astype('double').tofile(binaries_folder+"trial_frequencies.bin")

    # print out mean and std of sampling rate
    print("mean: ", 1 / (sum(dts) / len(dts)), " Hz")
    print("std: ", np.std(np.array(dts)**(-1)), " Hz")
    print("min: ", 1 / max(dts), " Hz")
    print("max: ", 1 / min(dts), " Hz")
    print("1st fastest percentile", 1 / np.percentile(dts, 1))
    print("50th percentile", 1 / np.percentile(dts, 50))
    print("99th slowest percentile", 1 / np.percentile(dts, 99))

    if show_histogram:
        # make histogram
        plt.hist(dts, bins=500, edgecolor='black')
        plt.xlabel('inter-sample duration')
        plt.ylabel('count')
        plt.title("leverdata sampling rate distribution")
        plt.show()

    return dts, trial_frequencies