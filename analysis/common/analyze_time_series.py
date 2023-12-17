import numpy as np
import scipy.interpolate as interpolate
from scipy.interpolate import interp1d

def average_time_series(data_time_series, common_resolution):
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

    # Define a common time vector with a common frequency (e.g., 0.005 seconds)
    common_time = np.arange(min_time, max_time, common_resolution)

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