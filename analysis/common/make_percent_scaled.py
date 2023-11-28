import numpy as np
import scipy.interpolate as interpolate

def make_percent_scaled(selected_trials, num_interpolation_samples, file_prefix, input_folder, output_folder):
    """
    The function takes in selected trials, the number of interpolation samples, a folder containing
    movement velocities, and an output folder, and returns a numpy array of movement velocities percent
    scaled by movement completion.
    
    :param selected_trials: The list of trial indices for which the velocities will be scaled
    :param num_interpolation_samples: The parameter "num_interpolation_samples" represents the number of
    samples to be generated during the interpolation process. It determines the resolution or
    granularity of the interpolated data
    :param input_folder: The `input_folder` parameter is the path to the folder where the
    movement velocities are stored
    :param output_folder: The output folder is the directory where the output files will be saved
    :return: the variable `datas_percent_scaled`, which is a numpy array containing the
    interpolated and percent-scaled movement velocities for the selected trials.
    """
    datas_percent_scaled = np.array([]).reshape((0, num_interpolation_samples))

    for trial_index in selected_trials:
        data = np.load(input_folder+file_prefix+'_trial'+str(trial_index)+'.npy')

        percent_completion_x = np.linspace(0, 100, data[1,:].shape[0])

        data_function = interpolate.interp1d(percent_completion_x, data[1, :], kind='linear')
        new_x = percent_completion_x = np.linspace(0, 100, num_interpolation_samples)
        new_y = data_function(new_x)
        data_percent_scaled = np.array(new_y[:])
        datas_percent_scaled = np.vstack([datas_percent_scaled, new_y[:]])
        np.save(output_folder+'movement_percent_scaled_trial'+str(trial_index), data_percent_scaled)

    print("percent scaled shape: ", datas_percent_scaled.shape)
    return datas_percent_scaled