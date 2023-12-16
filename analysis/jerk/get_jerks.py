import numpy as np
import scipy.signal as signal
import sympy as sp
import matplotlib.pyplot as plt
import numpy as np
import scipy.signal as signal
import sympy as sp
import matplotlib.pyplot as plt

def get_point_acceleration(trial_index, sample_index, window_duration, velocity_folder, binaries_folder):
    velocity = np.load(velocity_folder+"velocity_trial"+str(trial_index)+".npy")
    sample_times = np.fromfile(binaries_folder+"sample_times_trial"+str(trial_index)+".bin", dtype=np.double)
    num_window_samples = int(window_duration / np.median(np.diff(sample_times)))
    print("calculated samples per window: ", num_window_samples)

    # Fit a fourth-order polynomial around the specified center_index
    local_time, fit_data, poly_fit, start_index, end_index = fit_polynomial_around_index(sample_times, velocity, sample_index, num_window_samples)

    # Find the acceleration as the first derivative
    point_acceleration = derivative_at_index(local_time, fit_data)

    return point_acceleration


def fit_polynomial_around_index(time, data, center_index, window_size):
    # Define the range for the local fitting
    start_index = max(0, center_index - window_size // 2)
    end_index = min(len(time), center_index + window_size // 2 + 1)

    # Extract the local data
    local_time = time[start_index:end_index]
    local_data = data[start_index:end_index]

    # Fit a polynomial to the local data
    coefficients = np.polyfit(local_time, local_data, 4)
    poly_fit = np.poly1d(coefficients)

    # Evaluate the polynomial at all time values
    fit_data = poly_fit(local_time)

    # # Plot the original data points
    # plt.scatter(local_time, local_data, label='Original Data')
    # # Plot the polynomial fit
    # plt.plot(local_time, fit_data, label='Polynomial Fit', color='red')
    # # Add labels and legend
    # plt.xlabel('X-axis')
    # plt.ylabel('Y-axis')
    # plt.legend()
    # # Show the plot
    # plt.show()

    return local_time, fit_data, poly_fit, start_index, end_index

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