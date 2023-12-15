import numpy as np

def extract_leverpresses(trials_to_consider, binaries_folder, movement_baseline, movement_threshold, no_movement_threshold, output_folder):
    thresholds = [movement_baseline + no_movement_threshold, \
                  movement_baseline + movement_threshold, \
                    movement_baseline + no_movement_threshold]
    
    leverpress_indices = np.fromfile(binaries_folder+"leverpress_indices.bin", dtype=np.double)
    tone_indices = np.fromfile(binaries_folder+"tone_indices.bin", dtype=np.double)
    leverpress_information = np.zeros((len(trials_to_consider), 3))
    i = 0
    second_threshold_indices = np.full(1000, np.nan)
    for trial_index in trials_to_consider:
        print("Checking trial ", trial_index, "...")

        leverdata = np.fromfile(binaries_folder+"processed_trial"+str(trial_index)+".bin", dtype=np.double)
        leverpress_index = int(leverpress_indices[trial_index])
        tone_index = int(tone_indices[trial_index])

        if np.isnan(leverpress_index):
            raise ValueError("leverpress index is nan.")
        elif leverdata[leverpress_index] < thresholds[0]:
            print("leverpress detection was at below first threshold, try moving leverpress index up...")
            leverpress_index = move_index_up_then_down_until_reaches_threshold(leverdata, leverpress_index, thresholds[1], tone_index)
            print("new leverpress index value: ", leverdata[leverpress_index])

        left_index, right_index = bilateral_threshold_search_from_point(leverdata, leverpress_index, thresholds)

        leverpress_information[i, 0] = trial_index
        leverpress_information[i, 1] = left_index
        leverpress_information[i, 2] = right_index

        second_threshold_index = leverpress_index
        second_threshold_indices[trial_index] = second_threshold_index

        i += 1

    second_threshold_indices.astype('double').tofile(binaries_folder+"second_threshold_indices.bin")
    np.save(output_folder+"leverpress_informations", leverpress_information)
    print("number of extracted leverpresses ", len(leverpress_information))

    return leverpress_information


def move_index_up_then_down_until_reaches_threshold(time_series, start_index, threshold_to_reach, tone_index):
    try_moving_down = False
    
    # first try moving index up
    index = start_index
    value = time_series[index]
    while value < threshold_to_reach:
        index += 1
        if index >= len(time_series):
            print("end of trial, did not have leverpress.")
            try_moving_down = True
            break
        else:
            value = time_series[index]

    # now try moving index down
    if try_moving_down == True:
        index = start_index
        value = time_series[index]
        while value < threshold_to_reach:
            index -= 1
            if index <= tone_index:
                raise ValueError("went back all the way back to tone, did not have leverpress at all.")
            else:
                value = time_series[index]
        # okay, but now go ahead and set index to earliest one that's still above threshold
        while value > threshold_to_reach:
            index -= 1
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

