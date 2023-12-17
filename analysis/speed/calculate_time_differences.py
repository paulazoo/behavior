import numpy as np

def calculate_time_differences(indices_a, indices_b, movement_informations, trial_frequencies):
    """
    The function calculates the time differences between two sets of indices based on movement
    information, trial frequencies, and sampling frequencies.
    
    :param indices_a: The indices of the starting points of the movements in the first set of data
    :param indices_b: The indices_b parameter is a list of indices representing the end points of a
    movement in a time series data. Each index corresponds to a specific trial
    :param movement_informations: The parameter "movement_informations" is a list of movement
    information. Each element in the list represents a movement and contains the following information:
    :param trial_frequencies: The `trial_frequencies` parameter is a list that contains the sampling
    frequency for each trial. Each trial has a corresponding index in the list, and the value at that
    index represents the sampling frequency for that trial
    :return: an array of time differences.
    """
    time_differences = []

    for movement_information in movement_informations:
        trial_index = int(movement_information[0])
        sample_index_difference = indices_b[trial_index] - indices_a[trial_index]

        sampling_frequency = trial_frequencies[trial_index]
        time_difference = sample_index_difference / sampling_frequency

        time_differences.append(time_difference)

    return np.array(time_differences)