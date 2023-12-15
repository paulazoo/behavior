import numpy as np
import scipy.interpolate as interpolate
from scipy.interpolate import interp1d

def make_percent_scaled(selected_trials, num_interpolation_samples, file_prefix, input_folder, output_folder):
    """
    The function takes in selected trials, the number of interpolation samples, a folder containing
    movement velocities, and an output folder, and returns a numpy array of movement velocities percent
    scaled by movement completion.
    
    :param selected_trials: The list of trial indices for which the velocities will be scaled
    :param num_interpolation_samples: The parameter "num_interpolation_samples" represents the number of
    samples to be generated during the interpolation process. It determines the resolution or
    granularity of the interpolated data
    :param input_folder: The `input_folder` parameter is the path to the folder where the
    movement velocities are stored
    :param output_folder: The output folder is the directory where the output files will be saved
    :return: the variable `datas_percent_scaled`, which is a numpy array containing the
    interpolated and percent-scaled movement velocities for the selected trials.
    """
    datas_percent_scaled = np.array([]).reshape((0, num_interpolation_samples))

    for trial_index in selected_trials:
        data = np.load(input_folder+file_prefix+'_trial'+str(trial_index)+'.npy')

        percent_completion_x = np.linspace(0, 100, data[1,:].shape[0])

        data_function = interpolate.interp1d(percent_completion_x, data[1, :], kind='linear')
        new_x = np.linspace(0, 100, num_interpolation_samples)
        new_y = data_function(new_x)
        data_percent_scaled = np.array(new_y[:])
        datas_percent_scaled = np.vstack([datas_percent_scaled, new_y[:]])
        np.save(output_folder+file_prefix+'_percent_scaled_trial'+str(trial_index), data_percent_scaled)

    print("percent scaled shape: ", datas_percent_scaled.shape)
    return datas_percent_scaled

def average_time_series(data_time_series):
    """
    Compute the average of n different time series data with different sampling frequencies,
    where each time series has separate lists for data values and time values.

    Parameters:
    data_time_series: list of tuples
        n different time series data, each represented as a tuple (data_values_list, time_values_list).

    Returns:
    average_data: array
        The average of the resampled data values.
    common_time: array
        The common time vector after resampling.
    """

    # Convert lists to arrays for easier manipulation
    data_time_series = [(np.array(data_values), np.array(time_values)) for data_values, time_values in data_time_series]

    # Find the maximum time index among all time series
    max_time = max(time_values.max() for _, time_values in data_time_series)
    min_time = min(time_values.min() for _, time_values in data_time_series)

    # Define a common time vector with a common frequency (e.g., 1 Hz)
    common_time = np.arange(min_time, max_time, 0.005)

    # Initialize arrays to store the resampled data values for each time series
    resampled_data_series = []

    # Interpolate each time series data to the common time vector
    for data_values, time_values in data_time_series:
        # bounds_error=False: interp1d sets out-of-range values with fill_value, which is nan by default.
        interp_func = interp1d(time_values, data_values, kind='linear', bounds_error=False)
        resampled_data = interp_func(common_time)
        resampled_data_series.append(resampled_data)

    # Compute the average of resampled data values
    average_data = np.nanmean(resampled_data_series, axis=0)
    std_data = np.nanstd(resampled_data_series, axis=0)
    sem_data = std_data / np.sqrt(len(resampled_data_series))
    var_data = np.nanvar(resampled_data_series, axis=0)

    return average_data, common_time, std_data, sem_data, var_data