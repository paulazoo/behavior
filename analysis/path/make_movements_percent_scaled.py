import numpy as np
import scipy.interpolate as interpolate

def make_movements_percent_scaled(selected_trials, num_interpolation_samples, movements_folder, output_folder):
    """
    The function takes selected trials, interpolates the movements data, scales it to movement completion,
    saves the scaled data, and returns the scaled movements data.
    
    :param selected_trials: A list of trial indices that you want to process
    :param num_interpolation_samples: The parameter "num_interpolation_samples" represents the number of
    samples to be generated during the interpolation process. It determines the resolution or
    granularity of the interpolated movement data
    :param movements_folder: The `movements_folder` parameter is the path to the folder where the
    movement data files are stored
    :param output_folder: The output folder is the directory where the scaled movements will be saved
    :return: the numpy array `movements_percent_scaled`.
    """
    movements_percent_scaled = np.array([]).reshape((0, num_interpolation_samples))

    for trial_index in selected_trials:
        movement = np.load(movements_folder+'movement_trial'+str(trial_index)+'.npy')

        percent_completion_x = np.linspace(0, 100, movement[1,:].shape[0])

        movement_fcn = interpolate.interp1d(percent_completion_x, movement[1, :], kind='linear')
        new_x = percent_completion_x = np.linspace(0, 100, num_interpolation_samples)
        new_y = movement_fcn(new_x)
        movement_percent_scaled = np.array(new_y[:])
        movements_percent_scaled = np.vstack([movements_percent_scaled, new_y[:]])
        np.save(movements_folder+'movement_percent_scaled_trial'+str(trial_index), movement_percent_scaled)

    print("movements_percent_scaled shape: ", movements_percent_scaled.shape)
    return movements_percent_scaled