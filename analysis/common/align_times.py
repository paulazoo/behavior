import numpy as np

def get_leverdata_indices(binaries_folder, respMTX, num_trials):
    """
    The function takes in a folder path, a matrix, and a number of trials as
    input, and returns two binary files containing indices related to tone and lever press times.
    
    :param binaries_folder: The `binaries_folder` parameter is the path to the folder where the binary
    files are stored
    :param respMTX: The `respMTX` parameter is a matrix that contains the response times for each trial.
    It has dimensions `num_trials` x 4, where each row represents a trial and each column represents a
    different response time. The columns are as follows:
    :param num_trials: The parameter `num_trials` represents the number of trials in the experiment
    :return: The function does not return anything.
    """
    leverdata_tone_indices = []
    leverdata_leverpress_indices = []
    for i in range(0, num_trials):
        leverdata_sample_times = np.fromfile(binaries_folder+"sample_times_trial"+str(i)+".bin", dtype=np.double)

        tone_time = respMTX(i, 1)
        leverdata_tone_indices.append(tonedisc_time2leverdata_index(tone_time, leverdata_sample_times))

        leverpress_time = respMTX(i, 3)
        if leverpress_time:
            leverdata_leverpress_indices.append(tonedisc_time2leverdata_index(leverpress_time, leverdata_sample_times))

    leverdata_tone_indices.astype('double').tofile(binaries_folder+"tone_indices.bin")
    leverdata_leverpress_indices.astype('double').tofile(binaries_folder+"leverpress_indices.bin")

    return


def tonedisc_time2leverdata_index(tonedisc_time, leverdata_sample_times):

    for leverdata_index, leverdata_time in enumerate(leverdata_sample_times):
        if leverdata_time >= tonedisc_time:
            tonedisc_leverdata_index = leverdata_index
            return tonedisc_leverdata_index
    
    raise ValueError("None of the sample times were greater than the tonedisc time")