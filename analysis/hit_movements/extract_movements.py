import numpy as np

def extract_movements(movement_informations, binaries_folder, movement_baseline, output_folder):
    """
    The function `extract_movements` takes in movement information, lever data, sample times, and a
    movement baseline, and extracts the relevant movement data for each trial, saving it to an output
    folder and returning a list of the extracted movements.
    
    :param movement_informations: The `movement_informations` parameter is a list of movement
    information for each trial. Each element in the list is a tuple containing the trial index, start
    index, and end index of the movement in the lever data
    :param binaries_folder: The `binaries_folder` parameter is the folder where the binary files
    containing the lever data and sample times are stored
    :param movement_baseline: The movement_baseline parameter represents the baseline value for the
    lever data. It is subtracted from the lever data during the movement extraction process to obtain
    the relative movement values
    :param output_folder: The `output_folder` parameter is the directory where the extracted movement
    data will be saved
    :return: a list of movements.
    """
    movements = []
    for movement_information in movement_informations:
        trial_index = movement_information[0]
        leverdata = np.fromfile(binaries_folder+"processed_trial"+str(trial_index)+".bin", dtype=np.double)
        sample_times = np.fromfile(binaries_folder+"sample_times_trial"+str(trial_index)+".bin", dtype=np.double)

        movement_leverdata = leverdata[movement_information[1]:movement_information[2]+1]
        movement_sample_times = sample_times[movement_information[1]:movement_information[2]+1]

        movement = np.array([movement_sample_times - movement_sample_times[0],\
                             movement_leverdata - movement_baseline])
        
        np.save(output_folder+"movement_trial"+str(trial_index), movement)
        movements.append(movement)

    return movements