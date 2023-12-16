import numpy as np

def get_velocity_movingavgs(window_duration, binaries_folder, num_trials, output_folder):
    """
    The function calculates the moving average of velocity for selected trials using lever data and
    sample times.
    
    :param selected_trials: The selected_trials parameter is a list of trial indices that you want to
    process. These indices represent the trials for which you have leverdata and sample_times files
    :param window_duration: The window_duration parameter represents the duration of the moving average
    window in seconds. It determines the size of the window used to calculate the moving average of the
    instantaneous velocity
    :param binaries_folder: The `binaries_folder` parameter is the folder where the binary files
    containing the lever data and sample times are stored
    :param output_folder: The output_folder parameter is the directory where the output files will be
    saved
    :return: The function does not return anything.
    """
    for trial_index in range(0, num_trials):
        leverdata = np.fromfile(binaries_folder+"processed_trial"+str(trial_index)+".bin", dtype=np.double)
        sample_times = np.fromfile(binaries_folder+"sample_times_trial"+str(trial_index)+".bin", dtype=np.double)
        instantaneous_velocity = np.diff(leverdata) / np.diff(sample_times)
        num_window_samples = int(window_duration / np.median(np.diff(sample_times)))
        print("calculated samples per window of size", window_duration, "s:", num_window_samples)

        velocity_movingavg = np.convolve(instantaneous_velocity, np.ones(num_window_samples), mode='same')

        np.save(output_folder+"velocity_trial"+str(trial_index), velocity_movingavg)
    return
