import numpy as np

def calculate_time_differences(indices_a, indices_b, movement_informations, trial_frequencies):
    time_differences = []

    for movement_information in movement_informations:
        trial_index = int(movement_information[0])
        sample_index_difference = indices_b[trial_index] - indices_a[trial_index]

        sampling_frequency = trial_frequencies[trial_index]
        time_difference = sample_index_difference / sampling_frequency

        time_differences.append(time_difference)

    return np.array(time_differences)