import numpy as np
import scipy.interpolate as interpolate

def make_velocities_percent_scaled(selected_trials, num_interpolation_samples, velocities_folder, output_folder):
    """
    The function takes in selected trials, the number of interpolation samples, a folder containing
    movement velocities, and an output folder, and returns a numpy array of movement velocities percent
    scaled by movement completion.
    
    :param selected_trials: The list of trial indices for which the velocities will be scaled
    :param num_interpolation_samples: The parameter "num_interpolation_samples" represents the number of
    samples to be generated during the interpolation process. It determines the resolution or
    granularity of the interpolated data
    :param velocities_folder: The `velocities_folder` parameter is the path to the folder where the
    movement velocities are stored
    :param output_folder: The output folder is the directory where the output files will be saved
    :return: the variable `movement_velocities_percent_scaled`, which is a numpy array containing the
    interpolated and percent-scaled movement velocities for the selected trials.
    """
    movement_velocities_percent_scaled = np.array([]).reshape((0, num_interpolation_samples))

    for trial_index in selected_trials:
        movement_velocity = np.load(velocities_folder+'movement_velocity_trial'+str(trial_index)+'.npy')

        percent_completion_x = np.linspace(0, 100, movement_velocity[1,:].shape[0])

        velocity_fcn = interpolate.interp1d(percent_completion_x, movement_velocity[1, :], kind='linear')
        new_x = percent_completion_x = np.linspace(0, 100, num_interpolation_samples)
        new_y = velocity_fcn(new_x)
        movement_velocity_percent_scaled = np.array(new_y[:])
        movement_velocities_percent_scaled = np.vstack([movement_velocities_percent_scaled, new_y[:]])
        np.save(velocities_folder+'movement_percent_scaled_trial'+str(trial_index), movement_velocity_percent_scaled)

    print("movements_percent_scaled shape: ", movement_velocities_percent_scaled.shape)
    return movement_velocities_percent_scaled