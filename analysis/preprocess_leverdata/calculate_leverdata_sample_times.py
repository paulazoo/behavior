import numpy as np

def calculate_leverdata_sample_times(binaries_folder, respMTX, num_trials):
        """
        The function `calculate_leverdata_sample_times` reads binary files containing lever data and trial
        frequencies, calculates sample times based on the sampling frequency and trial start time, and saves
        the sample times as binary files.
        
        :param binaries_folder: The `binaries_folder` parameter is the path to the folder where the binary
        files are stored
        :param respMTX: The parameter `respMTX` is a numpy array that contains the response matrix. It has
        shape `(num_trials, num_columns)` where `num_trials` is the number of trials and `num_columns` is
        the number of columns in the response matrix
        :param num_trials: The parameter "num_trials" represents the number of trials for which you want to
        calculate the leverdata sample times
        :return: The function does not return anything.
        """
        for i in range(0, num_trials):
                # Read the binary file created by the C++ program which is saved as double for both trial_frequencies and leverdata
                leverdata = np.fromfile(binaries_folder+"processed_trial"+str(i)+".bin", dtype=np.double)
                trial_frequencies = np.fromfile(binaries_folder+"trial_frequencies.bin", dtype=np.double)
                sampling_frequency = trial_frequencies[i]
                trial_start_time = respMTX[i, 0]

                leverdata_sample_times = calculate_sample_times(leverdata, sampling_frequency, trial_start_time)
                
                leverdata_sample_times.astype('double').tofile(binaries_folder+"sample_times_trial"+str(i)+".bin")
        return

def calculate_sample_times(data, sampling_frequency, start_time):
        """
        The function calculates the sample times for a given data set, sampling frequency, and start time.
        
        :param data: The `data` parameter is a numpy array that contains the samples of a signal. Each
        element of the array represents a sample of the signal
        :param sampling_frequency: The sampling frequency is the number of samples taken per second. It
        represents the rate at which the data is collected
        :param start_time: The start time is the time at which the first sample was taken. It is a scalar
        value representing the starting point of the time axis
        :return: an array of sample times.
        """
        num_samples = data.shape[0]
        sample_times = np.linspace(start_time, start_time + ((1/sampling_frequency)*num_samples), num=num_samples)
        return sample_times
