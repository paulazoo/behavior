import numpy as np

def extract_leverpresses(trials_to_consider, binaries_folder, movement_baseline, movement_threshold, no_movement_threshold, output_folder):
    """
    The function `extract_leverpresses` extracts lever press information from binary files based on
    specified thresholds and saves the results in an output folder.
    
    :param trials_to_consider: The list of trial indices to consider for extracting lever presses
    :param binaries_folder: The folder where the binary files containing leverpress and tone indices are
    stored
    :param movement_baseline: The movement_baseline parameter is the baseline value used to determine
    the movement threshold. It is added to the movement_threshold and no_movement_threshold to calculate
    the actual thresholds
    :param movement_threshold: The `movement_threshold` is a value that is added to the
    `movement_baseline` to determine the threshold for detecting lever presses
    :param no_movement_threshold: The `no_movement_threshold` parameter is the threshold value used to
    determine if there is no movement detected during a lever press. If the lever data falls below this
    threshold, it is considered as no movement
    :param output_folder: The output folder is the directory where the extracted leverpress information
    and threshold indices will be saved
    :return: the leverpress_information, which is a numpy array containing information about the
    leverpresses extracted from the trials.
    """
    thresholds = [movement_baseline + no_movement_threshold, \
                  movement_baseline + movement_threshold, \
                    movement_baseline + no_movement_threshold]
    
    leverpress_indices = np.fromfile(binaries_folder+"leverpress_indices.bin", dtype=np.double)
    tone_indices = np.fromfile(binaries_folder+"tone_indices.bin", dtype=np.double)
    leverpress_information = np.zeros((len(trials_to_consider), 3))
    i = 0
    first_threshold_indices = np.full(1000, np.nan)
    second_threshold_indices = np.full(1000, np.nan)
    third_threshold_indices = np.full(1000, np.nan)
    for trial_index in trials_to_consider:
        print("Checking trial ", trial_index, "...")

        leverdata = np.fromfile(binaries_folder+"processed_trial"+str(trial_index)+".bin", dtype=np.double)
        leverpress_index = int(leverpress_indices[trial_index])
        tone_index = int(tone_indices[trial_index])

        if np.isnan(leverpress_index):
            raise ValueError("leverpress index is nan.")
        elif leverdata[leverpress_index] < thresholds[1]:
            print("leverpress detection was at below first threshold, try moving leverpress index up...")
            leverpress_index = move_index_up_then_down_until_reaches_threshold(leverdata, leverpress_index, thresholds[1], tone_index)
            print("new leverpress index value: ", leverdata[leverpress_index])

        left_index, right_index = bilateral_threshold_search_from_point(leverdata, leverpress_index, thresholds)

        leverpress_information[i, 0] = trial_index
        leverpress_information[i, 1] = left_index
        leverpress_information[i, 2] = right_index

        second_threshold_index = leverpress_index
        second_threshold_indices[trial_index] = second_threshold_index
        first_threshold_indices[trial_index] = left_index
        third_threshold_indices[trial_index] = right_index

        i += 1

    first_threshold_indices.astype('double').tofile(output_folder+"first_threshold_indices.bin")
    second_threshold_indices.astype('double').tofile(output_folder+"second_threshold_indices.bin")
    third_threshold_indices.astype('double').tofile(output_folder+"third_threshold_indices.bin")
    np.save(output_folder+"leverpress_informations", leverpress_information)
    print("number of extracted leverpresses ", len(leverpress_information))

    return leverpress_information


def move_index_up_then_down_until_reaches_threshold(time_series, start_index, threshold_to_reach, tone_index):
    """
    The function moves the index up in a time series until it reaches a threshold, and if it fails, it
    moves the index down until it reaches the threshold or the tone index.
    
    :param time_series: The time series is a list of values representing a sequence of measurements or
    observations over time. Each value in the time series corresponds to a specific time point
    :param start_index: The starting index is the index from which you want to start moving up or down
    in the time series
    :param threshold_to_reach: The threshold value that the time series needs to reach in order to
    consider it a lever press
    :param tone_index: The tone_index is the index in the time_series where the tone is played
    :return: the index at which the value in the time series first reaches or exceeds the threshold to
    reach.
    """
    try_moving_up = False
    
    # first try moving index down
    index = start_index
    value = time_series[index]
    if try_moving_up == False:
        while value < threshold_to_reach:
            index -= 1
            if index <= tone_index:
                print("went back all the way back to tone, did not have leverpress at all.")
                try_moving_up = True
                break
            else:
                value = time_series[index]
        # while value > threshold_to_reach: # now move index up until the earliest point it pressed lever
        #     index -= 1
        #     value = time_series[index]

    # now try moving index up
    if try_moving_up == True:
        index = start_index
        value = time_series[index]
        while value < threshold_to_reach:
            index += 1
            if index >= len(time_series):
                raise ValueError("end of trial, did not have leverpress.")
            else:
                value = time_series[index]

    return index



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
    left_index = start_index
    right_index = start_index
    
    
    print("finding right threshold...")
    right_threshold_met = False
    while right_threshold_met == False:
        right_value = time_series[right_index]

        if right_value <= thresholds[2]:
            right_threshold_met = True
            print('met')
        else:
            right_index += 1

        if right_index >= len(time_series):
            print("threshold: ", thresholds[2], "value at trial edge: ", right_value)
            raise ValueError("third threshold not met within trial.")

    print("finding left threshold...")
    left_threshold_met = False
    while left_threshold_met == False:
        left_value = time_series[left_index]
        if left_value <= thresholds[0]:
            left_threshold_met = True
            print('met')
        else:
            left_index -= 1

        if left_index < 0:
            print("threshold: ", thresholds[0], "value at trial edge: ", left_value)
            #raise ValueError("first threshold not met within trial.")
            # TODO: put back valueerror in extract_leverpresses.py and make it impossible to not be below first threshold within a trial
        
            print("first threshold not met within trial.")
            left_index = 0
            left_threshold_met = True
        
    return left_index, right_index

