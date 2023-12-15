import numpy as np
import matplotlib.pyplot as plt

def get_second_threshold_aligned_movements(before_duration, after_duration, PreprocessLeverData_folder, HitMovements_folder):
    leverdata_second_threshold_indices = np.fromfile(PreprocessLeverData_folder+"second_threshold_indices.bin", dtype=np.double)
    movement_informations = np.load(HitMovements_folder+"leverpress_informations.npy")
    trial_frequencies = np.fromfile(PreprocessLeverData_folder+"trial_frequencies.bin", dtype=np.double)

    second_threshold_aligned_movements = []

    for movement_information in movement_informations:
        trial_index = int(movement_information[0])
        leverdata = np.fromfile(PreprocessLeverData_folder+"processed_trial"+str(trial_index)+".bin", dtype=np.double)

        sample_times = np.fromfile(PreprocessLeverData_folder+"sample_times_trial"+str(trial_index)+".bin", dtype=np.double)
        second_threshold_index = int(leverdata_second_threshold_indices[trial_index])
        
        left_index, right_index = movement_information[1:]
        left_index = int(left_index)
        right_index = int(right_index)

        sampling_frequency = trial_frequencies[trial_index]

        num_samples_after = int(after_duration // (1/sampling_frequency))
        num_samples_before = int(before_duration // (1/sampling_frequency))
        
        second_threshold_aligned_movement_times = np.linspace(-1*before_duration, after_duration, len(sample_times[second_threshold_index-num_samples_before:second_threshold_index+num_samples_after]))
        second_threshold_aligned_movement_leverdata = leverdata[second_threshold_index-num_samples_before:second_threshold_index+num_samples_after]
        
        if len(second_threshold_aligned_movement_times) > 0:
            second_threshold_aligned_movements.append((second_threshold_aligned_movement_leverdata, second_threshold_aligned_movement_times))

    return second_threshold_aligned_movements


def get_tone_aligned_movements(before_duration, after_duration, PreprocessLeverData_folder, HitMovements_folder):
    leverdata_tone_indices = np.fromfile(PreprocessLeverData_folder+"tone_indices.bin", dtype=np.double)
    movement_informations = np.load(HitMovements_folder+"leverpress_informations.npy")
    trial_frequencies = np.fromfile(PreprocessLeverData_folder+"trial_frequencies.bin", dtype=np.double)

    tone_aligned_movements = []

    for movement_information in movement_informations:
        trial_index = int(movement_information[0])
        leverdata = np.fromfile(PreprocessLeverData_folder+"processed_trial"+str(trial_index)+".bin", dtype=np.double)

        sample_times = np.fromfile(PreprocessLeverData_folder+"sample_times_trial"+str(trial_index)+".bin", dtype=np.double)
        tone_index = int(leverdata_tone_indices[trial_index])
        
        left_index, right_index = movement_information[1:]
        left_index = int(left_index)
        right_index = int(right_index)

        sampling_frequency = trial_frequencies[trial_index]

        num_samples_after = int(after_duration // (1/sampling_frequency))
        num_samples_before = int(before_duration // (1/sampling_frequency))
        
        tone_aligned_movement_times = np.linspace(-1*before_duration, after_duration, len(sample_times[tone_index-num_samples_before:tone_index+num_samples_after]))
        tone_aligned_movement_leverdata = leverdata[tone_index-num_samples_before:tone_index+num_samples_after]
 
        if len(tone_aligned_movement_times) > 0:
            tone_aligned_movements.append((tone_aligned_movement_leverdata, tone_aligned_movement_times))
    
    return tone_aligned_movements