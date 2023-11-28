import numpy as np

def extract_leverpresses(trials_to_consider, binaries_folder, movement_baseline, movement_threshold, no_movement_threshold, output_folder):
    """
    The function `extract_leverpresses` extracts lever press indices from binary files based on
    specified thresholds and returns the lever press indices.
    
    :param trials_to_consider: A list of trial indices to consider for extracting lever presses
    :param binaries_folder: The `binaries_folder` parameter is the path to the folder where the binary
    files are stored. These binary files contain the lever data for each trial
    :param movement_baseline: The movement_baseline parameter is the baseline value used to calculate
    the movement thresholds. It is added to the no_movement_threshold and movement_threshold to
    determine the actual thresholds for detecting lever presses
    :param movement_threshold: The `movement_threshold` parameter is used to determine the threshold for
    detecting lever movements during a trial. It is added to the `movement_baseline` value to set the
    threshold for movement detection
    :param no_movement_threshold: The `no_movement_threshold` parameter is a threshold value used to
    determine when there is no movement detected in the lever data. It is added to the
    `movement_baseline` value to create a threshold for detecting movement
    :return: the leverpress_indices, which is a numpy array containing the indices of leverpresses for
    each trial in trials_to_consider.
    """
    # Parameters for extracting hit_movements:
    thresholds = [movement_baseline + no_movement_threshold, \
                  movement_baseline + movement_threshold, \
                    movement_baseline + no_movement_threshold]
    
    leverdata_leverpress_indices = np.fromfile(binaries_folder+"leverdata_leverpress_indices.bin", dtype=np.double)
    leverpress_information = np.zeros((len(trials_to_consider), 3))
    for i, trial_index in enumerate(trials_to_consider):
        print("Checking trial ", trial_index, "...")
        leverdata = np.fromfile(binaries_folder+"processed_trial"+str(trial_index)+".bin", dtype=np.double)
        leverdata_leverpress_index = leverdata_leverpress_indices[trial_index]

        left_index, right_index = bilateral_threshold_search_from_point(leverdata, leverdata_leverpress_index, thresholds)

        leverdata_leverpress_indices[i, 0] = trial_index
        leverdata_leverpress_indices[i, 1] = left_index
        leverdata_leverpress_indices[i, 2] = right_index
    np.save(output_folder+"leverpress_informations", leverpress_information)
    print("number of extracted leverpresses ", len(leverpress_information))

    return leverpress_information

def bilateral_threshold_search_from_point(time_series, start_index, thresholds):
    """
    The function `bilateral_threshold_search_from_point` searches for the indices where the values in a
    time series meet certain threshold conditions, starting from a given index.
    
    :param time_series: The time series is a list of values representing a sequence of data points over
    time. It could be any type of data, such as temperature readings, stock prices, or sensor
    measurements
    :param start_index: The start_index parameter is the index of the point in the time_series from
    which the bilateral threshold search should start
    :param thresholds: The `thresholds` parameter is a list containing three values. The first value
    represents the lower threshold for the left side of the time series, the second value represents the
    upper threshold for the middle point (start_index), and the third value represents the lower
    threshold for the right side of the time series
    :return: the left index and right index, which represent the indices in the time series where the
    first and third thresholds are met, respectively.
    """
    left_index = start_index - 1
    right_index = start_index + 1
    left_value = time_series[left_index]
    right_value = time_series[right_index]
    
    left_threshold_met = False
    right_threshold_met = False
    while ~left_threshold_met or ~right_threshold_met:
        left_value = time_series[left_index]
        right_value = time_series[right_index]

        if left_value < thresholds[0]:
            left_threshold_met = True
        else:
            left_index -= 1
        if right_value < thresholds[2]:
            right_threshold_met = True
        else:
            right_index += 1

        if left_index >= 0:
            raise ValueError("first threshold not met within trial.")
        if right_index < len(time_series):
            raise ValueError("third threshold not met within trial.")

    return left_index, right_index
