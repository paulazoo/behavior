# Namespace `analysis` {#id}




    
## Sub-modules

* [analysis.common](#analysis.common)
* [analysis.hit_movements](#analysis.hit_movements)
* [analysis.path](#analysis.path)
* [analysis.preprocess_leverdata](#analysis.preprocess_leverdata)
* [analysis.velocity](#analysis.velocity)






    
# Namespace `analysis.common` {#id}




    
## Sub-modules

* [analysis.common.align_times](#analysis.common.align_times)
* [analysis.common.load_tonedisc_matfile](#analysis.common.load_tonedisc_matfile)
* [analysis.common.select_trials](#analysis.common.select_trials)
* [analysis.common.set_matplotlib_settings](#analysis.common.set_matplotlib_settings)
* [analysis.common.sort_folders](#analysis.common.sort_folders)






    
# Module `analysis.common.align_times` {#id}






    
## Functions


    
### Function `get_leverdata_indices` {#id}




>     def get_leverdata_indices(
>         binaries_folder,
>         respMTX,
>         num_trials
>     )


The function takes in a folder path, a matrix, and a number of trials as
input, and returns two binary files containing indices related to tone and lever press times.

:param binaries_folder: The <code>binaries\_folder</code> parameter is the path to the folder where the binary
files are stored
:param respMTX: The <code>respMTX</code> parameter is a matrix that contains the response times for each trial.
It has dimensions <code>num\_trials</code> x 4, where each row represents a trial and each column represents a
different response time. The columns are as follows:
:param num_trials: The parameter <code>num\_trials</code> represents the number of trials in the experiment
:return: The function does not return anything.

    
### Function `tonedisc_time2leverdata_index` {#id}




>     def tonedisc_time2leverdata_index(
>         tonedisc_time,
>         leverdata_sample_times
>     )







    
# Module `analysis.common.load_tonedisc_matfile` {#id}






    
## Functions


    
### Function `load_tonedisc_matfile` {#id}




>     def load_tonedisc_matfile(
>         tone_discriminiation_matfile
>     )


Loads a ToneDisc .mat file and returns params, data, 
respMTX, MTXTrialType, and num_trials from the file.

:param tone_discriminiation_matfile: The parameter "tone_discriminiation_matfile" is the file path
to the ToneDisc .mat file that you want to load
:return: the following variables:
- params: a numpy array containing the parameters of the loaded .mat file
- response: a numpy array containing the response data of the loaded .mat file
- respMTX: a numpy array containing the response matrix from the response data
- MTXTrialType: a numpy array containing the trial types from the parameters
- num_trials: int number of trials




    
# Module `analysis.common.select_trials` {#id}






    
## Functions


    
### Function `select_hit_trials` {#id}




>     def select_hit_trials(
>         respMTX,
>         num_trials
>     )


The function <code>[select\_hit\_trials()](#analysis.common.select\_trials.select\_hit\_trials "analysis.common.select\_trials.select\_hit\_trials")</code> selects trials where there was a lever press and a reward from a
given response matrix.

:param respMTX: The parameter <code>respMTX</code> is a matrix that represents the response data for each
trial. It has dimensions (num_trials, num_columns), where each row represents a trial and each
column represents a different aspect of the response
:param num_trials: The <code>num\_trials</code> parameter represents the total number of trials in the <code>respMTX</code>
matrix
:return: a list of selected trials.




    
# Module `analysis.common.set_matplotlib_settings` {#id}






    
## Functions


    
### Function `set_matplotlib_settings` {#id}




>     def set_matplotlib_settings()


The function sets various settings for matplotlib to customize the appearance of plots.
:return: nothing (None).




    
# Module `analysis.common.sort_folders` {#id}






    
## Functions


    
### Function `sort_folders_by_day` {#id}




>     def sort_folders_by_day(
>         unsorted_folders_pattern
>     )


The function sorts a list of folder names based on the day number (d#) in the folder name.

:param unsorted_folders_key: The parameter <code>unsorted\_folders\_pattern</code> is a string that represents a file
path or a pattern to match multiple file paths. It is used as an argument for the <code>glob.glob()</code>
function to retrieve a list of file paths that match the pattern
:return: a list of folders sorted by the day number extracted from their names.




    
# Namespace `analysis.hit_movements` {#id}




    
## Sub-modules

* [analysis.hit_movements.extract_leverpresses](#analysis.hit_movements.extract_leverpresses)
* [analysis.hit_movements.extract_movements](#analysis.hit_movements.extract_movements)
* [analysis.hit_movements.get_movement_thresholds](#analysis.hit_movements.get_movement_thresholds)






    
# Module `analysis.hit_movements.extract_leverpresses` {#id}






    
## Functions


    
### Function `bilateral_threshold_search_from_point` {#id}




>     def bilateral_threshold_search_from_point(
>         time_series,
>         start_index,
>         thresholds
>     )


The function <code>[bilateral\_threshold\_search\_from\_point()](#analysis.hit\_movements.extract\_leverpresses.bilateral\_threshold\_search\_from\_point "analysis.hit\_movements.extract\_leverpresses.bilateral\_threshold\_search\_from\_point")</code> searches for the indices where the values in a
time series meet certain threshold conditions, starting from a given index.

:param time_series: The time series is a list of values representing a sequence of data points over
time. It could be any type of data, such as temperature readings, stock prices, or sensor
measurements
:param start_index: The start_index parameter is the index of the point in the time_series from
which the bilateral threshold search should start
:param thresholds: The <code>thresholds</code> parameter is a list containing three values. The first value
represents the lower threshold for the left side of the time series, the second value represents the
upper threshold for the middle point (start_index), and the third value represents the lower
threshold for the right side of the time series
:return: the left index and right index, which represent the indices in the time series where the
first and third thresholds are met, respectively.

    
### Function `extract_leverpresses` {#id}




>     def extract_leverpresses(
>         trials_to_consider,
>         binaries_folder,
>         movement_baseline,
>         movement_threshold,
>         no_movement_threshold,
>         output_folder
>     )


The function <code>[extract\_leverpresses()](#analysis.hit\_movements.extract\_leverpresses.extract\_leverpresses "analysis.hit\_movements.extract\_leverpresses.extract\_leverpresses")</code> extracts lever press indices from binary files based on
specified thresholds and returns the lever press indices.

:param trials_to_consider: A list of trial indices to consider for extracting lever presses
:param binaries_folder: The <code>binaries\_folder</code> parameter is the path to the folder where the binary
files are stored. These binary files contain the lever data for each trial
:param movement_baseline: The movement_baseline parameter is the baseline value used to calculate
the movement thresholds. It is added to the no_movement_threshold and movement_threshold to
determine the actual thresholds for detecting lever presses
:param movement_threshold: The <code>movement\_threshold</code> parameter is used to determine the threshold for
detecting lever movements during a trial. It is added to the <code>movement\_baseline</code> value to set the
threshold for movement detection
:param no_movement_threshold: The <code>no\_movement\_threshold</code> parameter is a threshold value used to
determine when there is no movement detected in the lever data. It is added to the
<code>movement\_baseline</code> value to create a threshold for detecting movement
:return: the leverpress_indices, which is a numpy array containing the indices of leverpresses for
each trial in trials_to_consider.




    
# Module `analysis.hit_movements.extract_movements` {#id}






    
## Functions


    
### Function `extract_movements` {#id}




>     def extract_movements(
>         movement_informations,
>         binaries_folder,
>         movement_baseline,
>         output_folder
>     )


The function <code>[extract\_movements()](#analysis.hit\_movements.extract\_movements.extract\_movements "analysis.hit\_movements.extract\_movements.extract\_movements")</code> takes in movement information, lever data, sample times, and a
movement baseline, and extracts the relevant movement data for each trial, saving it to an output
folder and returning a list of the extracted movements.

:param movement_informations: The <code>movement\_informations</code> parameter is a list of movement
information for each trial. Each element in the list is a tuple containing the trial index, start
index, and end index of the movement in the lever data
:param binaries_folder: The <code>binaries\_folder</code> parameter is the folder where the binary files
containing the lever data and sample times are stored
:param movement_baseline: The movement_baseline parameter represents the baseline value for the
lever data. It is subtracted from the lever data during the movement extraction process to obtain
the relative movement values
:param output_folder: The <code>output\_folder</code> parameter is the directory where the extracted movement
data will be saved
:return: a list of movements.




    
# Module `analysis.hit_movements.get_movement_thresholds` {#id}






    
## Functions


    
### Function `get_movement_thresholds` {#id}




>     def get_movement_thresholds(
>         params,
>         respMTX
>     )


Calculates the movement baseline, movement threshold, and no
movement threshold based on the given parameters and response matrix.

:param params: The <code>params</code> parameter is a nested list or array containing various parameters. It is
accessed using indexing, such as <code>params\[7]\[0]\[0]\[0]\[0]\[0]</code>
:param respMTX: The <code>respMTX</code> parameter is a matrix that contains response data. It is a 2D
matrix with shape (n_trials, n_columns), where each row represents a trial and each column
represents a different measurement or response
:return: three values: movement_baseline, movement_threshold, and no_movement_threshold.




    
# Namespace `analysis.path` {#id}




    
## Sub-modules

* [analysis.path.make_movements_percent_scaled](#analysis.path.make_movements_percent_scaled)






    
# Module `analysis.path.make_movements_percent_scaled` {#id}






    
## Functions


    
### Function `make_movements_percent_scaled` {#id}




>     def make_movements_percent_scaled(
>         selected_trials,
>         num_interpolation_samples,
>         movements_folder,
>         output_folder
>     )


The function takes selected trials, interpolates the movements data, scales it to movement completion,
saves the scaled data, and returns the scaled movements data.

:param selected_trials: A list of trial indices that you want to process
:param num_interpolation_samples: The parameter "num_interpolation_samples" represents the number of
samples to be generated during the interpolation process. It determines the resolution or
granularity of the interpolated movement data
:param movements_folder: The <code>movements\_folder</code> parameter is the path to the folder where the
movement data files are stored
:param output_folder: The output folder is the directory where the scaled movements will be saved
:return: the numpy array <code>movements\_percent\_scaled</code>.




    
# Namespace `analysis.preprocess_leverdata` {#id}




    
## Sub-modules

* [analysis.preprocess_leverdata.leverData2binary.cpp](#analysis.preprocess_leverdata.leverData2binary.cpp)
* [analysis.preprocess_leverdata.butterworth_filter_leverdata](#analysis.preprocess_leverdata.butterworth_filter_leverdata)
* [analysis.preprocess_leverdata.calculate_leverdata_sample_times](#analysis.preprocess_leverdata.calculate_leverdata_sample_times)
* [analysis.preprocess_leverdata.get_trial_frequencies](#analysis.preprocess_leverdata.get_trial_frequencies)
* [analysis.preprocess_leverdata.rescale_leverdata](#analysis.preprocess_leverdata.rescale_leverdata)
* [analysis.preprocess_leverdata.view_processed_trial_FFT](#analysis.preprocess_leverdata.view_processed_trial_FFT)





# Module `leverData2binary.cpp`
Make binary files for each trial from the LeverData matfile
- opens and reads in the corresponding .mat file
- extracts the `leverdata` variable and puts into a C++ vector<double>
- remove unused empty rows of zeroes (`leverdata` is initialized in ../behavior/leverIN_to_matlab.m to hold up to 2 hours worth of data, but the unused values are just 0s)
- extracts each individual trial+subsequent ITI of the `leverdata` and re-lowers the ITI values back down to 0-1023 instead of 2000-2023
- save each trial+ITI chunk of `leverdata` to its own .bin file

arguments:
- char* output_folder = the output folder where the binaries will be saved e.g. ./Data/AnB1/B1_20231030/
- char* matlab_filename = the lever data .mat filename e.g. ./Data/AnB1/B1_20231030.mat
- int beginning_samples_to_skip = number of beginning samples to skip

To compile on Mac M1 with libmatio installed via homebrew: `!g++ -I/opt/homebrew/opt/libmatio/include/ -L/opt/homebrew/Cellar/libmatio/1.5.24/lib/ -o leverData2binary leverData2binary.cpp -lmatio`

Example syntax: `./leverData2binary ./Data/AnB1/B1_20231030/ ./Data/AnB1/B1_20231030.mat 15460`


    
# Module `analysis.preprocess_leverdata.butterworth_filter_leverdata` {#id}






    
## Functions


    
### Function `butterworth_filter_leverdata` {#id}




>     def butterworth_filter_leverdata(
>         binaries_folder,
>         num_trials,
>         cutoff_frequency
>     )


Applies a Butterworth filter to lever data stored in
binary files, with the specified cutoff frequency, and saves the filtered data in new binary files.

:param binaries_folder: The folder where the binary files are stored. These binary files contain the
lever data for each trial
:param num_trials: The parameter "num_trials" represents the number of trials or datasets that need
to be filtered. It determines how many times the filtering process will be repeated
:param cutoff_frequency: The cutoff frequency is the frequency at which the filter starts
attenuating the signal. It determines the range of frequencies that will be allowed to pass through
the filter
:return: The function does not return anything.




    
# Module `analysis.preprocess_leverdata.calculate_leverdata_sample_times` {#id}






    
## Functions


    
### Function `calculate_leverdata_sample_times` {#id}




>     def calculate_leverdata_sample_times(
>         binaries_folder,
>         respMTX,
>         num_trials
>     )


The function <code>[calculate\_leverdata\_sample\_times()](#analysis.preprocess\_leverdata.calculate\_leverdata\_sample\_times.calculate\_leverdata\_sample\_times "analysis.preprocess\_leverdata.calculate\_leverdata\_sample\_times.calculate\_leverdata\_sample\_times")</code> reads binary files containing lever data and trial
frequencies, calculates sample times based on the sampling frequency and trial start time, and saves
the sample times as binary files.

:param binaries_folder: The <code>binaries\_folder</code> parameter is the path to the folder where the binary
files are stored
:param respMTX: The parameter <code>respMTX</code> is a numpy array that contains the response matrix. It has
shape <code>(num\_trials, num\_columns)</code> where <code>num\_trials</code> is the number of trials and <code>num\_columns</code> is
the number of columns in the response matrix
:param num_trials: The parameter "num_trials" represents the number of trials for which you want to
calculate the leverdata sample times
:return: The function does not return anything.

    
### Function `calculate_sample_times` {#id}




>     def calculate_sample_times(
>         data,
>         sampling_frequency,
>         start_time
>     )


The function calculates the sample times for a given data set, sampling frequency, and start time.

:param data: The <code>data</code> parameter is a numpy array that contains the samples of a signal. Each
element of the array represents a sample of the signal
:param sampling_frequency: The sampling frequency is the number of samples taken per second. It
represents the rate at which the data is collected
:param start_time: The start time is the time at which the first sample was taken. It is a scalar
value representing the starting point of the time axis
:return: an array of sample times.




    
# Module `analysis.preprocess_leverdata.get_trial_frequencies` {#id}






    
## Functions


    
### Function `get_trial_frequencies` {#id}




>     def get_trial_frequencies(
>         num_trials,
>         respMTX,
>         binaries_folder
>     )


For each trial, get the MATLAB time duration from <code>respMTX</code> (index 0 is the trial start time) and get <code>leverdata</code> from the 
created binary .bin file. Divide the number of samples by the MATLAB time duration to get the estimated frequency and check that it's consistent.

A lever movement can be less than 50 ms.




    
# Module `analysis.preprocess_leverdata.rescale_leverdata` {#id}






    
## Functions


    
### Function `rescale_leverdata` {#id}




>     def rescale_leverdata(
>         binaries_folder,
>         num_trials
>     )


Rescales the lever data from 0-1023 analogRead values to 0-5V and saves the processed
data as binary files.

:param binaries_folder: The <code>binaries\_folder</code> parameter is the path to the folder where the binary
files are stored. This folder should contain the binary files named "filtered_trial0.bin",
"filtered_trial1.bin", and so on
:param num_trials: The parameter "num_trials" represents the number of trials or iterations that
need to be processed. It is used in the for loop to iterate over the range from 0 to num_trials




    
# Module `analysis.preprocess_leverdata.view_processed_trial_FFT` {#id}






    
## Functions


    
### Function `view_processed_trial_FFT` {#id}




>     def view_processed_trial_FFT(
>         trial_i,
>         binaries_folder
>     )


The function <code>[view\_processed\_trial\_FFT()](#analysis.preprocess\_leverdata.view\_processed\_trial\_FFT.view\_processed\_trial\_FFT "analysis.preprocess\_leverdata.view\_processed\_trial\_FFT.view\_processed\_trial\_FFT")</code> reads binary files created by a C++ program, computes the
power spectrum of the processed data, and plots it.

:param trial_i: trial_i is the index of the trial you want to view the processed data for. It is
used to load the corresponding binary file containing the processed lever data
:param binaries_folder: The <code>binaries\_folder</code> parameter is the path to the folder where the binary
files are stored. It should be a string representing the directory path




    
# Namespace `analysis.velocity` {#id}




    
## Sub-modules

* [analysis.velocity.extract_movement_velocities](#analysis.velocity.extract_movement_velocities)
* [analysis.velocity.get_velocity_movingavgs](#analysis.velocity.get_velocity_movingavgs)
* [analysis.velocity.make_velocities_percent_scaled](#analysis.velocity.make_velocities_percent_scaled)






    
# Module `analysis.velocity.extract_movement_velocities` {#id}






    
## Functions


    
### Function `extract_movement_velocities` {#id}




>     def extract_movement_velocities(
>         movement_informations,
>         binaries_folder,
>         output_folder
>     )


The function <code>[extract\_movement\_velocities()](#analysis.velocity.extract\_movement\_velocities.extract\_movement\_velocities "analysis.velocity.extract\_movement\_velocities.extract\_movement\_velocities")</code> takes in movement information, binary files, and an
output folder, and extracts movement velocities from the given data.

:param movement_informations: The <code>movement\_informations</code> parameter is a list of movement
information. Each element in the list represents a specific movement and contains the following
information:
:param binaries_folder: The <code>binaries\_folder</code> parameter is the folder where the binary files
containing the sample times for each trial are stored. These binary files are named
"sample_times_trialX.bin", where X is the trial index
:param output_folder: The <code>output\_folder</code> parameter is the directory where the extracted movement
velocities will be saved as numpy arrays
:return: a list of movement velocities.




    
# Module `analysis.velocity.get_velocity_movingavgs` {#id}






    
## Functions


    
### Function `get_velocity_movingavgs` {#id}




>     def get_velocity_movingavgs(
>         selected_trials,
>         window_duration,
>         binaries_folder,
>         output_folder
>     )


The function calculates the moving average of velocity for selected trials using lever data and
sample times.

:param selected_trials: The selected_trials parameter is a list of trial indices that you want to
process. These indices represent the trials for which you have leverdata and sample_times files
:param window_duration: The window_duration parameter represents the duration of the moving average
window in seconds. It determines the size of the window used to calculate the moving average of the
instantaneous velocity
:param binaries_folder: The <code>binaries\_folder</code> parameter is the folder where the binary files
containing the lever data and sample times are stored
:param output_folder: The output_folder parameter is the directory where the output files will be
saved
:return: The function does not return anything.




    
# Module `analysis.velocity.make_velocities_percent_scaled` {#id}






    
## Functions


    
### Function `make_velocities_percent_scaled` {#id}




>     def make_velocities_percent_scaled(
>         selected_trials,
>         num_interpolation_samples,
>         velocities_folder,
>         output_folder
>     )


The function takes in selected trials, the number of interpolation samples, a folder containing
movement velocities, and an output folder, and returns a numpy array of movement velocities percent
scaled by movement completion.

:param selected_trials: The list of trial indices for which the velocities will be scaled
:param num_interpolation_samples: The parameter "num_interpolation_samples" represents the number of
samples to be generated during the interpolation process. It determines the resolution or
granularity of the interpolated data
:param velocities_folder: The <code>velocities\_folder</code> parameter is the path to the folder where the
movement velocities are stored
:param output_folder: The output folder is the directory where the output files will be saved
:return: the variable <code>movement\_velocities\_percent\_scaled</code>, which is a numpy array containing the
interpolated and percent-scaled movement velocities for the selected trials.

