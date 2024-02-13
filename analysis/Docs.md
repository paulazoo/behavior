# :fire:PreprocessLeverData
The lever data, `leverdata`, only holds the raw lever Arduino values from Arduino's `readAnalog()` function, which scales 0-5V (the voltage range going into this pin) to numbers from 0-1023. The Arduino encodes these numbers with values between 0-1023 into 2 bytes of data and sends them over to the computer via USB virtual serial port. The MATLAB program, leverIN_to_matlab.m then listens in and decodes this array of 2 bytes back into the number between 0-1023 and saves it into `leverdata`.

__Additional information on the sampling rate__: It's a more or less consistent sampling rate because the number of data bytes actually being sent through the USB virtual serial port is always exactly 2 bytes. Empirically, it varies, for the first few thousand entries it'll be a little faster ~100us, then for whatever reason it slows down to a more consistent pace of around 150-170us, probably due to hitting/overloading the serial port transfer buffer limit (in the Arduino code, there is no delay, it sends new data as soon as it has read it and reads new data as soon as it's done sending). Since it's so fast, but also empirically quite consistent after the first few thousand entries, I've decided to let go of trying to get it at an exactly even sampling rate since I believe at these several kHz frequencies, the actual animal movements will be approximated closely enough for analysis and comparisons. Plus, sending additional bytes of information (e.g. exact time) through the USB serial port will only slow it down further.

Also, anytime a trial is not currently ongoing--which is when we are in the ITI--so when tStart == LOW or 0V is at the tStart pin (pin 11), `leverdata` will be >2000. First, we will align each trial's MATLAB starting time to each first value of `leverdata` that is not >2000. Dividing the total time between trial start times by the number of entries recorded in `leverdata` between those two points will give an estimate of the sampling frequency and the change in time, `dt`, between any two entries for that trial.

The sensor itself may have some noise above a cutoff frequency, `cutoff_frequency`, of 50 Hz and all relevant attributes of the animal's movement are below 50 Hz. We'll use a sharp 6th order Butterworth filter to filter this out.

Finally, we'll rescale everything from the 0-1023 Arduino values range back to the 0-5V range: $\text{data} \times \frac{5}{1023}$, and save it as `processed_leverdata`.

All data will be saved as .bin files in case I need to go back to C++ in a folder specified by `output_folder`

## This book analyzes 1 day session.

## Requires:
- ToneDisc matfile
- LeverData matfile

## Outputs to folder:
- full.bin as the full raw `leverdata` Arduino values for the entire session
- trial#.bin files as the raw `leverdata` Arduino values
- filtered_trial#.bin files as the low-pass Butterworth filtered Arduino values
- processed_trial#.bin files as the converted voltage values of lever data
- sample_times_trial#.bin files as the aligned time values for each sample
- trial_frequencies.bin as the estimated sampling frequency for each trial
- tone_indices.bin as the sample index values for tone times for each trial from ToneDisc matfile
- leverpress_indices.bin as the sample index values for leverpress times for each trial from ToneDisc matfile


# :fire:HitMovements
TODO: put back valueerror in extract_leverpresses.py and make it impossible to not be below first threshold within a trial

I will define a `movement` as the recorded lever movement between a defined first to second threshold and back for the third threshold. This notebook is solely for detecting and saving each movement from a day.

__Note on possible movements:__

<img src="./images/path_cases.jpg" width="250" height="250" />

This image lists some of the possible cases that could occur with movement. For our analysis, all of these movements will count. The first, second, and third thresholds are marked with stars, and the beginning of the movement window and ending of the movement window are marked with vertical lines.

The folder defined by `analysis0_folder` needs contain the processed `leverdata` as processed_leverdata_trial#.bin binary files. The extracted hit movements will have MVT0 subtracted off and be temporally aligned to be comparable. They will be saved to a movement_trial#.npy file also in the folder defined by `output_folder`. From this point forward, I'm using `np.save()` to save all analysis as 2D arrays since I'm assuming I don't need to reaccess or further process the entire giant data with C++ anymore.

## This notebook analyzes 1 day session.

## Requires:
- ToneDisc matfile
- **PreprocessLeverData** output

## Outputs to folder:
- hit_trials.npy the custom hit_trials excluding `hit_trials_to_exclude` at the beginning of the notebook
- leverpress_informations.npy
- movement_trial#.npy for each extracted hit movement
- first_threshold_indices.npy as the sample index for when the movement hits the first threshold within the trial's processed leverdata
- second_threshold_indices.npy as the sample index for when the movement first hits the second threshold within the trial's processed leverdata
- third_threshold_indices.npy as the sample index for when the movement hit the third threshold within the trial's processed leverdata
- plot_movements.png as the figure of all hit movements found from first to third threshold


# :fire:Path
Here, I'll analyze the movement path variance across all __Hit__ trials that successfully have movement from the first threshold to the second threshold and back to the first threshold (this back threshold will effectively be a third threshold) from 1 day (and ignore variance in speed for now). These movements are gotten from running **HitMovements** to get leverpress_informations.npy.

I will then plot the variance of this path over the movements aligned to the _second threshold_. I also calculate the average movement path for __Hit__ trials that had movement from the first to second to third threshold for this 1 day. Finally, I will calculate the sum (cumulative) of the path variance for the session.

## This book analyzes 1 day session.

## Requires:
- ToneDisc matfile
- **PreprocessLeverData** output
- **HitMovements** outputs

## Outputs to folder:
- mean_path_data.npy of E[paths]
- var_path_data.npy of Var[paths]
- std_path_data.npy of $\sqrt{\text{Var}[\text{paths}]}$
- sem_path_data.npy of SEM[paths]
- path_times.npy of the common aligned time range
- aligned_path_movements_trial#.npy first column is actual times (not zeroed to second threshold) and second column is all the leverdata time series for each movement from before_duration before the second threshold to after_duration after the second threshold
- plot_path_analysis.png as a png of the final figure


# :fire:Jerk
__Motivation for using jerk__: So the previous notebooks analyzed variability across multiple curves throughout a day's session. The variability within a single trial, however, is impossible to calculate without making assumptions about the hidden deterministic curve. I originally wanted to try to fit some class of deterministic function to the movements (and then do, for example, a Kalman filter to figure out the exact hidden parameters/function for each movement curve and subtract this to find variability), but later realized that the entire class of target movements the mice are actually aiming for internally might still be completely different between WT and diseased models.

The smoothest movement between point A and point B will be the movement trajectory that minimizes jerk, the third derivative of position, between these two points. As it turns out, for animal movements, this minimal jerk trajectory is also the one expert animals (practiced adult WT humans) will perform for maximum motor efficiency [(Todorov and Jordan 1998)](doi.org/10.1152/jn.1998.80.2.696).

Therefore, as a measure of smoothness across a single movement curve, I want to calculate the jerk across the entire movement. Of course, the cumulative jerk squared (squared to ignore changes in sign) across an entire movement will depend on the time it takes to do the movement (speed) and initial acceleration. Therefore, I will normalize the cumulative jerk calculated by the cumulative jerk from an ideal most efficient trajectory that minimizes jerk. Specifically, I want to calculate $\frac{\int j(t)^2dt}{\int j_\text{min}(t)^2dt}$ were $j(t)$ is the jerk across the movement and $j_\text{min}(t)$ is the ideal smoothest minimal jerk. 

__On finding the ideal smoothest minimal jerk, from [Todorov and Jordan 1998](doi.org/10.1152/jn.1998.80.2.696)__: _It has been shown (Flash and Hogan 1985) that for given passage times T, positions x, velocities v, and accelerations a at the end points of one segment, the minimum-jerk trajectory is a 5th-order polynomial in t, the coefficients of which can be determined easily using the end-point constraints. It is then possible to integrate the squared jerk analytically, and sum it over all segments._

So if I'm understanding that correctly,
$x_\text{min}(t)=C_1 t^5 + C_2 t^4 + C_3 t^3 + C_4 t^2 + C_5 t + C_6$

with boundary conditions:
1) $x(0)=x_0$
2) $v(0)=v_0$
3) $a(0)=a_0$ and 
4) $x(t_f)=x_f$
5) $v(t_f)=v_f$
6) $a(t_f)=a_f$

where $t_f$ is the end/final time of the movement when point B is reached.

Then after the constants are solved for,
$j_\text{min}(t)=x_\text{min}'''(t)$

__More on calculating jerk__:
_Processed leverdata curve:_
Quick reminder that the leverdata is already Butterworth filtered above 40Hz.

_Window of analysis:_
For these analyses, I've been only analyzing from the first threshold to the peak (maximum displacement) of the movement curve.

This is because I wanted to avoid the sudden electrical signal artificially giving me crazy high (values around $10^{20}$) jerks at those points, but later on I think we should do either 1) first threshold to the peak + peak back down to the third threshold or 2) first threshold to the peak + peak back down to the second threshold.

_Actual jerk:_
Actual jerk curve is first calculated from the direct third derivative (which is calculated using central differences) of the processed leverdata curve.

The reason I didn't take moving averages is because I realized moving averages smooth out the higher derivatives too much, giving much lower (magnitudes lower) jerk values than even the idealized, minimum jerk. The possible problem with this is that calculating without further smoothing of noise may result is higher than actual jerk values from the sensor noise, but considering I was still getting occasional jerk values that were <100% (down to like 95%) of the idealized, minimum jerk, I don't think this is a problem in our case.

_Idealized, minimum jerk:_
The idealized minimum jerk is calculated based on the boundary conditions of the initial velocity, position, and acceleration at the first threshold point and then the final velocity, position, and acceleration at the peak point. Then, the smoothest movement curve with the least change in acceleration is found to get from the initial conditions to the final conditions. Then, the third derivative of this smoothest movement is the minimum jerk curve. This is calculated analytically because it turns out the smoothest movement curve is always a 5th order polynomial.

_Jerk ratio:_
The area under the curve of the absolute values from the actual jerk curve is divided by the area under the curve of the absolute values of the minimum jerk curve.

The absolute values are used to ignore sign changes in jerk.

## This notebook analyzes 1 day session.

## Requires:
- **PreprocessLeverData** output (for trial frequencies)
- **HitMovements** output

## Outputs to folder:
- velocity_trial#.npy velocities for all trials as finite differences
- acceleration_trial#.npy accelerations for all trials as finite differences
- jerk_trial#.npy jerks for all trials as finite differences
- jerk_ratios.npy number of movements x 4 numpy array 
    - with columns: `trial_index` | `jerk_ratio` | `actual_cumulative_jerk` | `minimum_cumulative_jerk`
- plot_jerk_ratios.png histogram of jerk ratio values



# :fire:Speed
Finds the time between any two markpoints of movement trials. Finds reactions times (first threshold - tone), rise times (when it initially hits second threshold - first threshold), and return times (time when returns to third threshold - when it initially hits second threshold).

## This notebook analyzes 1 day session.

## Requires:
- **PreprocessLeverData** output
- **HitMovements** outputs

## Outputs to folder:
- reaction_times.npy a 1D array of reaction times
- rise_times.npy a 1D array of rise times
- return_times.npy a 1D array of return times



# :fire:ViewSingleMovements
For plotting every single movement individually.

## This notebook analyzes 1 day session.

## Requires:
- ToneDisc matfile
- **PreprocessLeverData** output
- **HitMovements** outputs
- **Jerk** outputs

## Outputs to folder:
- plot_trial#.png every single plot made is saved as a .png.
- plot_basic_trial#.png every single plot of only leverdata made is saved as a .png.



# :fire:Python2Excel
For outputting python numpy arrays (e.g. from .npy files) to a specific excel sheet in a specific excel file



# :rainbow:Submodules (AI generated docs + `python3 -m pdoc --pdf  ./analysis`)

## C++ Modules

### Module `leverdata2binary.cpp`
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

To compile on Mac M1 with libmatio installed via homebrew: `!g++ -I/opt/homebrew/opt/libmatio/include/ -L/opt/homebrew/Cellar/libmatio/1.5.26/lib/ -o leverdata2binary leverdata2binary.cpp -lmatio`

Example syntax: `./leverData2binary ./Data/AnB1/B1_20231030/ ./Data/AnB1/B1_20231030.mat 15460`


## Namespace `analysis.common` {#id}




    
### Sub-modules

* [analysis.common.align_times](#analysis.common.align_times)
* [analysis.common.analyze_time_series](#analysis.common.analyze_time_series)
* [analysis.common.extract_movement_intervals](#analysis.common.extract_movement_intervals)
* [analysis.common.load_tonedisc_matfile](#analysis.common.load_tonedisc_matfile)
* [analysis.common.select_trials](#analysis.common.select_trials)
* [analysis.common.set_matplotlib_settings](#analysis.common.set_matplotlib_settings)
* [analysis.common.sort_folders](#analysis.common.sort_folders)






    
## Module `analysis.common.align_times` {#id}






    
### Functions


    
#### Function `get_leverdata_indices` {#id}




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

    
#### Function `tonedisc_time2leverdata_index` {#id}




>     def tonedisc_time2leverdata_index(
>         tonedisc_time,
>         leverdata_sample_times
>     )


The function <code>[tonedisc\_time2leverdata\_index()](#analysis.common.align\_times.tonedisc\_time2leverdata\_index "analysis.common.align\_times.tonedisc\_time2leverdata\_index")</code> returns the index of the lever data sample time that is
greater than or equal to the tonedisc time.

:param tonedisc_time: The tonedisc_time parameter is the time at which a tone is discovered
:param leverdata_sample_times: A list of sample times from the lever data. These sample times
represent the time at which each sample was taken during an experiment
:return: the index of the leverdata sample time that is greater than or equal to the tonedisc time.




    
## Module `analysis.common.analyze_time_series` {#id}






    
### Functions


    
#### Function `average_time_series` {#id}




>     def average_time_series(
>         data_time_series,
>         common_resolution
>     )


Compute the average of n different time series data with different sampling frequencies,
where each time series has separate lists for data values and time values.

Parameters:
data_time_series: list of tuples
    n different time series data, each represented as a tuple (data_values_list, time_values_list).

Returns:
average_data: array
    The average of the resampled data values.
common_time: array
    The common time vector after resampling.




    
## Module `analysis.common.extract_movement_intervals` {#id}






    
### Functions


    
#### Function `extract_movement_intervals` {#id}




>     def extract_movement_intervals(
>         movement_informations,
>         file_prefix,
>         input_folder,
>         binaries_folder,
>         output_folder,
>         movement_baseline=0
>     )


The function extracts movement intervals from given movement information and saves them in the
specified output folder.

:param movement_informations: The <code>movement\_informations</code> parameter is a list of movement
information. Each element in the list represents a movement and contains the following information:
:param file_prefix: The file prefix is a string that is used to identify the type of data file. It
is used to construct the file names for the input and output files
:param input_folder: The folder where the input files are located. These input files can be either
binary files or numpy files, depending on the value of the <code>file\_prefix</code> parameter
:param binaries_folder: The <code>binaries\_folder</code> parameter is the folder where the binary files
containing the sample times and data are located
:param output_folder: The <code>output\_folder</code> parameter is the directory where the extracted movement
intervals will be saved
:param movement_baseline: The <code>movement\_baseline</code> parameter is the baseline value that is subtracted
from the movement data. It is used to normalize the movement data by removing any constant offset,
defaults to 0 (optional)
:return: a list of movements.




    
## Module `analysis.common.load_tonedisc_matfile` {#id}






    
### Functions


    
#### Function `load_tonedisc_matfile` {#id}




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




    
## Module `analysis.common.select_trials` {#id}






    
### Functions


    
#### Function `save_custom_hit_trials` {#id}




>     def save_custom_hit_trials(
>         HitMovements_folder,
>         hit_trials
>     )


The function saves a numpy array of hit trials to a specified folder.

:param HitMovements_folder: The folder where you want to save the hit_trials data
:param hit_trials: The hit_trials parameter is a variable that contains the data for hit trials. It
could be an array, a list, or any other data structure that holds the hit trial data
:return: nothing.

    
#### Function `select_custom_hit_trials` {#id}




>     def select_custom_hit_trials(
>         HitMovements_folder
>     )


The function "select_custom_hit_trials" loads and returns a numpy array of selected hit trials from
a specified folder.

:param HitMovements_folder: The HitMovements_folder parameter is the path to the folder where the
hit_trials.npy file is located
:return: the selected trials, which are stored in the variable "selected_trials".

    
#### Function `select_hit_trials` {#id}




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




    
## Module `analysis.common.set_matplotlib_settings` {#id}






    
### Functions


    
#### Function `set_matplotlib_multiplot_settings` {#id}




>     def set_matplotlib_multiplot_settings()


The function sets various settings for matplotlib to customize the appearance of plots.
:return: nothing (None).

    
#### Function `set_matplotlib_multiplot_settings2` {#id}




>     def set_matplotlib_multiplot_settings2()


The function sets various settings for matplotlib to customize the appearance of plots.
:return: nothing (None).

    
#### Function `set_matplotlib_settings` {#id}




>     def set_matplotlib_settings()


The function sets various settings for matplotlib to customize the appearance of plots.
:return: nothing (None).




    
## Module `analysis.common.sort_folders` {#id}






    
### Functions


    
#### Function `sort_folders_by_day` {#id}




>     def sort_folders_by_day(
>         unsorted_folders_pattern
>     )


The function sorts a list of folder names based on the day number (d#) in the folder name.

:param unsorted_folders_key: The parameter <code>unsorted\_folders\_pattern</code> is a string that represents a file
path or a pattern to match multiple file paths. It is used as an argument for the <code>glob.glob()</code>
function to retrieve a list of file paths that match the pattern
:return: a list of folders sorted by the day number extracted from their names.




    
## Namespace `analysis.hit_movements` {#id}




    
### Sub-modules

* [analysis.hit_movements.extract_leverpresses](#analysis.hit_movements.extract_leverpresses)
* [analysis.hit_movements.get_movement_thresholds](#analysis.hit_movements.get_movement_thresholds)






    
## Module `analysis.hit_movements.extract_leverpresses` {#id}






    
### Functions


    
#### Function `bilateral_threshold_search_from_point` {#id}




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

    
#### Function `extract_leverpresses` {#id}




>     def extract_leverpresses(
>         trials_to_consider,
>         binaries_folder,
>         movement_baseline,
>         movement_threshold,
>         no_movement_threshold,
>         output_folder
>     )


The function <code>[extract\_leverpresses()](#analysis.hit\_movements.extract\_leverpresses.extract\_leverpresses "analysis.hit\_movements.extract\_leverpresses.extract\_leverpresses")</code> extracts lever press information from binary files based on
specified thresholds and saves the results in an output folder.

:param trials_to_consider: The list of trial indices to consider for extracting lever presses
:param binaries_folder: The folder where the binary files containing leverpress and tone indices are
stored
:param movement_baseline: The movement_baseline parameter is the baseline value used to determine
the movement threshold. It is added to the movement_threshold and no_movement_threshold to calculate
the actual thresholds
:param movement_threshold: The <code>movement\_threshold</code> is a value that is added to the
<code>movement\_baseline</code> to determine the threshold for detecting lever presses
:param no_movement_threshold: The <code>no\_movement\_threshold</code> parameter is the threshold value used to
determine if there is no movement detected during a lever press. If the lever data falls below this
threshold, it is considered as no movement
:param output_folder: The output folder is the directory where the extracted leverpress information
and threshold indices will be saved
:return: the leverpress_information, which is a numpy array containing information about the
leverpresses extracted from the trials.

    
#### Function `move_index_up_then_down_until_reaches_threshold` {#id}




>     def move_index_up_then_down_until_reaches_threshold(
>         time_series,
>         start_index,
>         threshold_to_reach,
>         tone_index
>     )


The function moves the index up in a time series until it reaches a threshold, and if it fails, it
moves the index down until it reaches the threshold or the tone index.

:param time_series: The time series is a list of values representing a sequence of measurements or
observations over time. Each value in the time series corresponds to a specific time point
:param start_index: The starting index is the index from which you want to start moving up or down
in the time series
:param threshold_to_reach: The threshold value that the time series needs to reach in order to
consider it a lever press
:param tone_index: The tone_index is the index in the time_series where the tone is played
:return: the index at which the value in the time series first reaches or exceeds the threshold to
reach.




    
## Module `analysis.hit_movements.get_movement_thresholds` {#id}






    
### Functions


    
#### Function `get_movement_thresholds` {#id}




>     def get_movement_thresholds(
>         params,
>         respMTX,
>         shift
>     )


Calculates the movement baseline, movement threshold, and no
movement threshold based on the given parameters and response matrix.

:param params: The <code>params</code> parameter is a nested list or array containing various parameters. It is
accessed using indexing, such as <code>params\[7]\[0]\[0]\[0]\[0]\[0]</code>
:param respMTX: The <code>respMTX</code> parameter is a matrix that contains response data. It is a 2D
matrix with shape (n_trials, n_columns), where each row represents a trial and each column
represents a different measurement or response
:return: three values: movement_baseline, movement_threshold, and no_movement_threshold.




    
## Namespace `analysis.jerk` {#id}




    
### Sub-modules

* [analysis.jerk.calculate_minimum_jerk](#analysis.jerk.calculate_minimum_jerk)
* [analysis.jerk.get_jerks](#analysis.jerk.get_jerks)






    
## Module `analysis.jerk.calculate_minimum_jerk` {#id}






    
### Functions


    
#### Function `get_boundary_conditions` {#id}




>     def get_boundary_conditions(
>         index_a,
>         index_b,
>         trial_index,
>         PreprocessLeverData_folder,
>         Jerk_folder
>     )


The function <code>[get\_boundary\_conditions()](#analysis.jerk.calculate\_minimum\_jerk.get\_boundary\_conditions "analysis.jerk.calculate\_minimum\_jerk.get\_boundary\_conditions")</code> retrieves the boundary conditions (position, velocity,
acceleration) and the time duration for a given trial from preprocessed lever data and jerk data.

:param index_a: The index of the starting point in the lever data, velocity, and acceleration arrays
:param index_b: The parameter "index_b" represents the index of the lever data, velocity, and
acceleration arrays where the final boundary condition is located. It is used to extract the final
position, velocity, and acceleration values from the arrays
:param trial_index: The trial index is an identifier for a specific trial or experiment. It is used
to load the corresponding data files for that trial
:param PreprocessLeverData_folder: The folder where the processed lever data files are stored
:param Jerk_folder: The <code>Jerk\_folder</code> parameter is the folder path where the jerk data files are
stored
:return: the initial and final positions, velocities, accelerations, and the time duration of a
trial.

    
#### Function `get_index_a_b` {#id}




>     def get_index_a_b(
>         trial_index,
>         left_index,
>         right_index,
>         PreprocessLeverData_folder
>     )


The function <code>[get\_index\_a\_b()](#analysis.jerk.calculate\_minimum\_jerk.get\_index\_a\_b "analysis.jerk.calculate\_minimum\_jerk.get\_index\_a\_b")</code> takes in a trial index, left and right indices, and a folder path, and
returns the index of the maximum value in a specific range of lever data.

:param trial_index: The trial index is the index of the trial for which you want to retrieve the
lever data. It is used to construct the file name for the lever data file
:param left_index: The left index is the starting index of the lever data that you want to search
for the maximum value
:param right_index: The <code>right\_index</code> parameter is the index of the rightmost element in the range
of leverdata that you want to consider
:param PreprocessLeverData_folder: The <code>PreprocessLeverData\_folder</code> parameter is a string that
represents the folder path where the lever data files are stored. It is used to construct the file
path for the lever data file that corresponds to the given <code>trial\_index</code>
:return: the values of index_a and index_b.

    
#### Function `minimum_jerk_function` {#id}




>     def minimum_jerk_function(
>         smoothest_x_coefficients,
>         t_input
>     )


The function calculates the minimum jerk trajectory from the smoothest position equation.

:param smoothest_x_coefficients: The smoothest_x_coefficients parameter is a list of three
coefficients [C1, C2, C3] that determine the shape of the smoothest position function.
:param t_input: The parameter <code>t\_input</code> represents the time input.
:return: the value of the minimum jerk function at a given time input.

    
#### Function `minimum_jerk_function_grad` {#id}




>     def minimum_jerk_function_grad(
>         smoothest_x,
>         t_input
>     )


Not currently used.

    
#### Function `smoothest_x_function` {#id}




>     def smoothest_x_function(
>         smoothest_x_coefficients,
>         t_input
>     )


The function smoothest_x_function calculates the value of a polynomial function with coefficients
given by smoothest_x_coefficients at a given input t_input.

:param smoothest_x_coefficients: The smoothest_x_coefficients parameter is a list of 6 coefficients
[C1, C2, C3, C4, C5, C6] that are used in the calculation of the smoothest_x_function
:param t_input: The t_input parameter represents the input value for the function. It is the
independent variable that you want to evaluate the function at
:return: the value of the polynomial function defined by the smoothest_x_coefficients at the given
t_input.

    
#### Function `solve_x_coefficients` {#id}




>     def solve_x_coefficients(
>         x_0,
>         v_0,
>         a_0,
>         x_f,
>         v_f,
>         a_f,
>         tf
>     )


The function <code>[solve\_x\_coefficients()](#analysis.jerk.calculate\_minimum\_jerk.solve\_x\_coefficients "analysis.jerk.calculate\_minimum\_jerk.solve\_x\_coefficients")</code> solves a system of equations to find the coefficients of a
polynomial function that represents the position of an object over time, given initial and final
position, velocity, acceleration, and time.

:param x_0: The initial position of the object
:param v_0: The parameter <code>v\_0</code> represents the initial velocity
:param a_0: The parameter <code>a\_0</code> represents the initial acceleration
:param x_f: The parameter <code>x\_f</code> represents the final position of the object
:param v_f: The parameter <code>v\_f</code> represents the final velocity
:param a_f: The parameter <code>a\_f</code> represents the final acceleration
:param tf: The parameter "tf" represents the final time. It is the time at which the position,
velocity, and acceleration values are specified (x_f, v_f, a_f)
:return: The function <code>[solve\_x\_coefficients()](#analysis.jerk.calculate\_minimum\_jerk.solve\_x\_coefficients "analysis.jerk.calculate\_minimum\_jerk.solve\_x\_coefficients")</code> returns a list of the smoothest x coefficients that
satisfy the given initial and final conditions.

    
#### Function `solve_x_coefficients_linearalg` {#id}




>     def solve_x_coefficients_linearalg(
>         x_0,
>         v_0,
>         a_0,
>         x_f,
>         v_f,
>         a_f,
>         tf
>     )


Not currently used.




    
## Module `analysis.jerk.get_jerks` {#id}






    
### Functions


    
#### Function `calculate_jerk` {#id}




>     def calculate_jerk(
>         displacement,
>         sampling_frequency
>     )


The function calculates jerk, velocity, and acceleration using central differences given
displacement and sampling frequency.

:param displacement: The displacement is the change in position of an object over time. It can be
measured in meters, centimeters, or any other unit of length
:param sampling_frequency: The sampling frequency is the number of samples taken per second. It
determines the time interval between each sample
:return: three values: jerk, velocity, and acceleration.

    
#### Function `get_jerks` {#id}




>     def get_jerks(
>         num_trials,
>         binaries_folder,
>         output_folder
>     )


The function "get_jerks" calculates the jerk of a given velocity signal using a Savitzky-Golay
filter and saves the result in an output folder.

:param num_trials: The number of trials or experiments you want to process
:param window_duration: The window_duration parameter represents the duration of each window in
seconds. It is used to determine the number of samples per window by dividing the window_duration by
the median of the differences between sample times
:param velocity_folder: The folder where the velocity data files are stored
:param binaries_folder: The <code>binaries\_folder</code> parameter is the folder where the binary files
containing the sample times for each trial are stored
:param output_folder: The <code>output\_folder</code> parameter is the directory where the jerk data will be
saved
:return: nothing.




    
## Namespace `analysis.path` {#id}




    
### Sub-modules

* [analysis.path.get_aligned_movements](#analysis.path.get_aligned_movements)






    
## Module `analysis.path.get_aligned_movements` {#id}






    
### Functions


    
#### Function `get_second_threshold_aligned_movements` {#id}




>     def get_second_threshold_aligned_movements(
>         before_duration,
>         after_duration,
>         PreprocessLeverData_folder,
>         HitMovements_folder,
>         output_folder
>     )




    
#### Function `get_tone_aligned_movements` {#id}




>     def get_tone_aligned_movements(
>         before_duration,
>         after_duration,
>         PreprocessLeverData_folder,
>         HitMovements_folder
>     )







    
## Namespace `analysis.preprocess_leverdata` {#id}




    
### Sub-modules

* [analysis.preprocess_leverdata.butterworth_filter_leverdata](#analysis.preprocess_leverdata.butterworth_filter_leverdata)
* [analysis.preprocess_leverdata.calculate_leverdata_sample_times](#analysis.preprocess_leverdata.calculate_leverdata_sample_times)
* [analysis.preprocess_leverdata.get_trial_frequencies](#analysis.preprocess_leverdata.get_trial_frequencies)
* [analysis.preprocess_leverdata.rescale_leverdata](#analysis.preprocess_leverdata.rescale_leverdata)
* [analysis.preprocess_leverdata.view_processed_trial_FFT](#analysis.preprocess_leverdata.view_processed_trial_FFT)






    
## Module `analysis.preprocess_leverdata.butterworth_filter_leverdata` {#id}






    
### Functions


    
#### Function `butterworth_filter_leverdata` {#id}




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




    
## Module `analysis.preprocess_leverdata.calculate_leverdata_sample_times` {#id}






    
### Functions


    
#### Function `calculate_leverdata_sample_times` {#id}




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

    
#### Function `calculate_sample_times` {#id}




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




    
## Module `analysis.preprocess_leverdata.get_trial_frequencies` {#id}






    
### Functions


    
#### Function `get_trial_frequencies` {#id}




>     def get_trial_frequencies(
>         num_trials,
>         respMTX,
>         binaries_folder,
>         show_histogram=False
>     )


For each trial, get the MATLAB time duration from <code>respMTX</code> (index 0 is the trial start time) and get <code>leverdata</code> from the 
created binary .bin file. Divide the number of samples by the MATLAB time duration to get the estimated frequency and check that it's consistent.

A lever movement can be less than 50 ms.




    
## Module `analysis.preprocess_leverdata.rescale_leverdata` {#id}






    
### Functions


    
#### Function `rescale_leverdata` {#id}




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




    
## Module `analysis.preprocess_leverdata.view_processed_trial_FFT` {#id}






    
### Functions


    
#### Function `view_processed_trial_FFT` {#id}




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




    
## Namespace `analysis.speed` {#id}




    
### Sub-modules

* [analysis.speed.calculate_time_differences](#analysis.speed.calculate_time_differences)






    
## Module `analysis.speed.calculate_time_differences` {#id}






    
### Functions


    
#### Function `calculate_time_differences` {#id}




>     def calculate_time_differences(
>         indices_a,
>         indices_b,
>         movement_informations,
>         trial_frequencies
>     )


The function calculates the time differences between two sets of indices based on movement
information, trial frequencies, and sampling frequencies.

:param indices_a: The indices of the starting points of the movements in the first set of data
:param indices_b: The indices_b parameter is a list of indices representing the end points of a
movement in a time series data. Each index corresponds to a specific trial
:param movement_informations: The parameter "movement_informations" is a list of movement
information. Each element in the list represents a movement and contains the following information:
:param trial_frequencies: The <code>trial\_frequencies</code> parameter is a list that contains the sampling
frequency for each trial. Each trial has a corresponding index in the list, and the value at that
index represents the sampling frequency for that trial
:return: an array of time differences.


---
_Conver to pdf using Chrome Puppeteer PDF_