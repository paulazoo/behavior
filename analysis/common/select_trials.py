import numpy as np

def select_hit_trials(respMTX, num_trials):
    """
    The function `select_hit_trials` selects trials where there was a lever press and a reward from a
    given response matrix.
    
    :param respMTX: The parameter `respMTX` is a matrix that represents the response data for each
    trial. It has dimensions (num_trials, num_columns), where each row represents a trial and each
    column represents a different aspect of the response
    :param num_trials: The `num_trials` parameter represents the total number of trials in the `respMTX`
    matrix
    :return: a list of selected trials.
    """
    selected_trials = []
    for i in range(0, num_trials):
        tone_time = respMTX[i, 1] # MATLAB indexes from 1, python from 0
        leverpress_time = respMTX[i, 3]
        leverpress_boole = respMTX[i, 2]
        reward_boole = respMTX[i, 6]

        # only consider trials where there was a lever press and there was a reward
        if ~np.isnan(tone_time) and ~np.isnan(leverpress_time) and leverpress_boole == True and reward_boole == True:
            selected_trials.append(i)
    
    print(len(selected_trials), ' hit trials in this session.')
    
    return selected_trials

def select_custom_hit_trials(HitMovements_folder):
    """
    The function "select_custom_hit_trials" loads and returns a numpy array of selected hit trials from
    a specified folder.
    
    :param HitMovements_folder: The HitMovements_folder parameter is the path to the folder where the
    hit_trials.npy file is located
    :return: the selected trials, which are stored in the variable "selected_trials".
    """
    selected_trials = np.load(HitMovements_folder+"hit_trials.npy")
    
    print(len(selected_trials), ' hit trials in this session.')
    
    return selected_trials

def save_custom_hit_trials(HitMovements_folder, hit_trials):
    """
    The function saves a numpy array of hit trials to a specified folder.
    
    :param HitMovements_folder: The folder where you want to save the hit_trials data
    :param hit_trials: The hit_trials parameter is a variable that contains the data for hit trials. It
    could be an array, a list, or any other data structure that holds the hit trial data
    :return: nothing.
    """
    np.save(HitMovements_folder+"hit_trials", hit_trials)
    return
