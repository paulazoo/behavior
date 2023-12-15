

def get_movement_thresholds(params, respMTX):
    """
    Calculates the movement baseline, movement threshold, and no
    movement threshold based on the given parameters and response matrix.
    
    :param params: The `params` parameter is a nested list or array containing various parameters. It is
    accessed using indexing, such as `params[7][0][0][0][0][0]`
    :param respMTX: The `respMTX` parameter is a matrix that contains response data. It is a 2D
    matrix with shape (n_trials, n_columns), where each row represents a trial and each column
    represents a different measurement or response
    :return: three values: movement_baseline, movement_threshold, and no_movement_threshold.
    """
    movement_baseline = respMTX[0, 4] * -1 /0.0049 *5 /1023 - 0.1
    print("movement_baseline for all trials should be the same: ", movement_baseline)
    movement_threshold = params[7][0][0][0][0][0] /0.0049 *5 /1023 # VBP's conversion rate is not exact
    print("mvt threshold: ", movement_threshold, "+ movement_baseline = ", movement_baseline + movement_threshold)
    no_movement_threshold = params[7][0][0][1][0][0] /0.0049 *5 /1023
    print("nomvt threshold: ", no_movement_threshold, "+ movement_baseline = ", movement_baseline + no_movement_threshold)
    
    return movement_baseline, movement_threshold, no_movement_threshold