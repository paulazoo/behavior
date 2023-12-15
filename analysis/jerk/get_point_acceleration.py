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
    fit_data, poly_fit = fit_polynomial_around_index(sample_times, velocity, sample_index, num_window_samples)

    # Find the acceleration as the first derivative
    point_acceleration = derivative_at_index(poly_fit, sample_index)

    return point_acceleration


def fit_polynomial_around_index(time, data, center_index, window_size):
    """
    Fit a polynomial of specified order around a given center_index in a time series.

    Parameters:
    - time: array-like, time values
    - data: array-like, corresponding data values
    - center_index: int, the center_index around which to fit the polynomial
    - window_size: int, size of the window for local fitting
    - order: int, order of the polynomial (default is 4)

    Returns:
    - fit_data: array, the fitted data values
    - poly_fit: numpy.poly1d object representing the fitted polynomial
    """

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
    fit_data = poly_fit(time)

    # Plot the original data points
    plt.scatter(local_time, local_data, label='Original Data')

    # Plot the polynomial fit
    plt.plot(local_time, fit_data[start_index:end_index], label='Polynomial Fit', color='red')

    # Add labels and legend
    plt.xlabel('X-axis')
    plt.ylabel('Y-axis')
    plt.legend()

    # Show the plot
    plt.show()
    print(poly_fit)
    return fit_data, poly_fit

def derivative_at_index(poly_fit, index):
    """
    Calculate the first derivative of a polynomial at a specific index.

    Parameters:
    - poly_fit: numpy.poly1d object representing the fitted polynomial
    - index: int, the index at which to calculate the derivative

    Returns:
    - derivative: float, the value of the first derivative at the specified index
    """
    derivative = np.polyder(poly_fit)
    

    # Evaluate the derivative at the specified point
    derivative_at_point = np.polyval(derivative, index)

    return derivative_at_point