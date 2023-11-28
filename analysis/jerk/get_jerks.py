import numpy as np
import scipy.signal as signal

def get_jerks(num_trials, window_duration, velocity_folder, binaries_folder, output_folder):
    """
    The function "get_jerks" calculates the jerk of a given velocity signal using a Savitzky-Golay
    filter and saves the result in an output folder.
    
    :param num_trials: The number of trials or experiments you want to process
    :param window_duration: The window_duration parameter represents the duration of each window in
    seconds. It is used to determine the number of samples per window by dividing the window_duration by
    the median of the differences between sample times
    :param velocity_folder: The folder where the velocity data files are stored
    :param binaries_folder: The `binaries_folder` parameter is the folder where the binary files
    containing the sample times for each trial are stored
    :param output_folder: The `output_folder` parameter is the directory where the jerk data will be
    saved
    :return: nothing.
    """
    for trial_index in range(0, num_trials):
        velocity = np.load(velocity_folder+"velocity_trial"+str(trial_index)+".npy")
        sample_times = np.fromfile(binaries_folder+"sample_times_trial"+str(trial_index)+".bin", dtype=np.double)
        num_window_samples = int(window_duration / np.median(np.diff(sample_times)))
        print("calculated samples per window: ", num_window_samples)

        jerk = signal.savgol_filter(velocity, window_length=num_window_samples, polyorder=4)
        
        np.save(output_folder+'jerk_trial'+str(trial_index), jerk)
    
    return