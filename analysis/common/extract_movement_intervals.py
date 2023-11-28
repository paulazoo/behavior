import numpy as np

def extract_movement_intervals(movement_informations, file_prefix, input_folder, binaries_folder, output_folder, movement_baseline=0):
    movements = []
    for movement_information in movement_informations:
        trial_index = movement_information[0]
        sample_times = np.fromfile(binaries_folder+"sample_times_trial"+str(trial_index)+".bin", dtype=np.double)
        if file_prefix == 'processed':
            data = np.fromfile(binaries_folder+"processed_trial"+str(trial_index)+".bin", dtype=np.double)
        else:
            data = np.load(input_folder+file_prefix+"_trial"+str(trial_index)+".npy")

        movement_sample_times = sample_times[movement_information[1]:movement_information[2]+1]
        movement_data = data[movement_information[1]:movement_information[2]+1]

        movement = np.array([movement_sample_times - movement_sample_times[0],\
                            movement_data - movement_baseline])
        
        if file_prefix == 'processed':
            np.save(output_folder+"movement_trial"+str(trial_index), movement)
        else:
            np.save(output_folder+file_prefix+"movement_trial"+str(trial_index), movement)
        movements.append(movement)

    return movements