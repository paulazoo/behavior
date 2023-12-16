import numpy as np
import scipy.signal as signal
import sympy as sp
import matplotlib.pyplot as plt
import numpy as np
import scipy.signal as signal
import sympy as sp
import matplotlib.pyplot as plt

def derivative_at_index(local_time, fit_data):
    index = len(fit_data) // 2
    
    delta_t = local_time[index + 1] - local_time[index - 1]
    derivative = (fit_data[index + 1] - fit_data[index - 1]) / (2 * delta_t)
    return derivative
    
def get_jerks(num_trials, binaries_folder, output_folder):
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
    trial_frequencies = np.fromfile(binaries_folder+"trial_frequencies.bin", dtype=np.double)
    
    for trial_index in range(0, num_trials):
        leverdata = np.fromfile(binaries_folder+"processed_trial"+str(trial_index)+".bin", dtype=np.double)

        sampling_frequency = trial_frequencies[trial_index]
        jerk, velocity, acceleration = calculate_jerk(leverdata, sampling_frequency)

        np.save(output_folder+'jerk_trial'+str(trial_index), jerk)
        np.save(output_folder+'velocity_trial'+str(trial_index), velocity)
        np.save(output_folder+'acceleration_trial'+str(trial_index), acceleration)
    return

def calculate_jerk(displacement, sampling_frequency):
    # Calculate the time step (delta t) from the sampling frequency
    dt = 1 / sampling_frequency
   
    # Calculate velocity using central differences
    velocity = np.gradient(displacement, dt)
   
    # Calculate acceleration using central differences
    acceleration = np.gradient(velocity, dt)
   
    # Calculate jerk using central differences
    jerk = np.gradient(acceleration, dt)
   
    return jerk, velocity, acceleration