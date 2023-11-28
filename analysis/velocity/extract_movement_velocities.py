import numpy as np

def extract_movement_velocities(movement_informations, binaries_folder, output_folder):
    """
    The function `extract_movement_velocities` takes in movement information, binary files, and an
    output folder, and extracts movement velocities from the given data.
    
    :param movement_informations: The `movement_informations` parameter is a list of movement
    information. Each element in the list represents a specific movement and contains the following
    information:
    :param binaries_folder: The `binaries_folder` parameter is the folder where the binary files
    containing the sample times for each trial are stored. These binary files are named
    "sample_times_trialX.bin", where X is the trial index
    :param output_folder: The `output_folder` parameter is the directory where the extracted movement
    velocities will be saved as numpy arrays
    :return: a list of movement velocities.
    """
    movement_velocities = []
    for movement_information in movement_informations:
        trial_index = movement_information[0]
        velocity_movingavg = np.load(output_folder+"velocity_trial"+str(trial_index)+".npy")
        sample_times = np.fromfile(binaries_folder+"sample_times_trial"+str(trial_index)+".bin", dtype=np.double)

        movement_velocity_movingavg = velocity_movingavg[movement_information[1]+1:movement_information[2]+1+1]
        movement_velocity_sample_times = sample_times[movement_information[1]:movement_information[2]+1]

        movement_velocity = np.array([movement_velocity_sample_times - movement_velocity_sample_times[0],\
                                movement_velocity_movingavg])
        
        np.save(output_folder+"movement_velocity_trial"+str(trial_index), movement_velocity)
        movement_velocities.append(movement_velocity)
            
    return movement_velocities