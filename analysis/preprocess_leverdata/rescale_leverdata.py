import numpy as np

def rescale_leverdata(binaries_folder, num_trials):
    """
    Rescales the lever data from 0-1023 analogRead values to 0-5V and saves the processed
    data as binary files.
    
    :param binaries_folder: The `binaries_folder` parameter is the path to the folder where the binary
    files are stored. This folder should contain the binary files named "filtered_trial0.bin",
    "filtered_trial1.bin", and so on
    :param num_trials: The parameter "num_trials" represents the number of trials or iterations that
    need to be processed. It is used in the for loop to iterate over the range from 0 to num_trials
    """
    for i in range(0, num_trials):

        # Read the binary file created by the C++ program which is saved as double
        filtered_leverdata = np.fromfile(binaries_folder+"filtered_trial"+str(i)+".bin", dtype=np.double)

        # Rescale to 0-5V from 0-1023 analogRead values
        processed_leverdata = filtered_leverdata * 5/1023

        # use numpy to same trial_frequencies into a .bin (not pickle because just in case need to reopen in C++)
        processed_leverdata.astype('double').tofile(binaries_folder+"processed_trial"+str(i)+".bin")