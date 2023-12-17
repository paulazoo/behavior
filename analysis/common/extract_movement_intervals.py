import numpy as np

def extract_movement_intervals(movement_informations, file_prefix, input_folder, binaries_folder, output_folder, movement_baseline=0):
    """
    The function extracts movement intervals from given movement information and saves them in the
    specified output folder.
    
    :param movement_informations: The `movement_informations` parameter is a list of movement
    information. Each element in the list represents a movement and contains the following information:
    :param file_prefix: The file prefix is a string that is used to identify the type of data file. It
    is used to construct the file names for the input and output files
    :param input_folder: The folder where the input files are located. These input files can be either
    binary files or numpy files, depending on the value of the `file_prefix` parameter
    :param binaries_folder: The `binaries_folder` parameter is the folder where the binary files
    containing the sample times and data are located
    :param output_folder: The `output_folder` parameter is the directory where the extracted movement
    intervals will be saved
    :param movement_baseline: The `movement_baseline` parameter is the baseline value that is subtracted
    from the movement data. It is used to normalize the movement data by removing any constant offset,
    defaults to 0 (optional)
    :return: a list of movements.
    """
    movements = []
    for movement_information in movement_informations:
        trial_index = int(movement_information[0])
        sample_times = np.fromfile(binaries_folder+"sample_times_trial"+str(trial_index)+".bin", dtype=np.double)
        if file_prefix == 'processed':
            data = np.fromfile(binaries_folder+"processed_trial"+str(trial_index)+".bin", dtype=np.double)
        else:
            data = np.load(input_folder+file_prefix+"_trial"+str(trial_index)+".npy")

        movement_start_index = int(movement_information[1])
        movement_end_index = int(movement_information[2])
        movement_sample_times = sample_times[movement_start_index:movement_end_index+1]
        movement_data = data[movement_start_index:movement_end_index+1]

        movement = np.array([movement_sample_times - movement_sample_times[0],\
                            movement_data - movement_baseline])
        
        if file_prefix == 'processed':
            np.save(output_folder+"movement_trial"+str(trial_index), movement)
        else:
            np.save(output_folder+file_prefix+"movement_trial"+str(trial_index), movement)
        movements.append(movement)

    return movements