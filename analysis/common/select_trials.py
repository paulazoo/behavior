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
        # only consider trials where there was a lever press and there was a reward
        if respMTX[i, 2] and respMTX[i, 6]:
            selected_trials.append(i)
    
    print(len(selected_trials), ' hit trials in this session.')
    
    return selected_trials