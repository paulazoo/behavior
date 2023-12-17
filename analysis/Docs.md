# PreprocessLeverData
The lever data, `leverdata`, only holds the raw lever Arduino values from Arduino's `readAnalog()` function, which scales 0-5V (the voltage range going into this pin) to numbers from 0-1023 (so at a resting neutral position, the lever is usually about 550 which anecdotally seems to match Vincent's calculated Voltage of about 2.6V). The Arduino encodes these numbers with values between 0-1023 into 2 bytes of data and sends them over to the computer via USB virtual serial port. The MATLAB program, leverIN_to_matlab.m then listens in and decodes this array of 2 bytes back into the number between 0-1023 and saves it into `leverdata`.

__Additional information on the sampling rate__: It's a more or less consistent sampling rate because the number of data bytes actually being sent through the USB virtual serial port is always exactly 2 bytes. Empirically, it varies, for the first few thousand entries it'll be a little faster ~100us, then for whatever reason it slows down to a more consistent pace of around 150-170us, probably due to hitting/overloading the serial port transfer buffer limit (in the Arduino code, there is no delay, it sends new data as soon as it has read it and reads new data as soon as it's done sending). Since it's so fast, but also empirically quite consistent after the first few thousand entries, I've decided to let go of trying to get it at an exactly even sampling rate since I believe at these several kHz frequencies, the actual animal movements will be approximated closely enough for analysis and comparisons. Plus, sending additional bytes of information (e.g. exact time) through the USB serial port will only slow it down further.

Also, anytime a trial is not currently ongoing--which is when we are in the ITI--so when tStart == LOW or 0V is at the tStart pin (pin 11), `leverdata` will be >2000. First, we will align each trial's MATLAB starting time to each first value of `leverdata` that is not >2000. Dividing the total time between trial start times by the number of entries recorded in `leverdata` between those two points will give an estimate of the sampling frequency and the change in time, `dt`, between any two entries for that trial.

The sensor itself may have some noise above a cutoff frequency, `cutoff_frequency`, of 40 Hz and all relevant attributes of the animal's movement are below 40 Hz. We'll use a sharp 6th order Butterworth filter to filter this out.

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

# HitMovements
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

# Path
Here, I'll analyze the movement path variance across all __Hit__ trials that successfully have movement from the first threshold to the second threshold and back to the first threshold (this back threshold will effectively be a third threshold) from 1 day (and ignore variance in speed for now). These movements are gotten from running **HitMovements** to get leverpress_informations.npy.

I will then plot the variance of this path over the movements aligned to the _second threshold_. I also calculate the average movement path for __Hit__ trials that had movement from the first to second to third threshold for this 1 day. Finally, I will calculate the sum (cumulative) of the path variance for the session.

## This book analyzes 1 day session.

## Requires:
- ToneDisc matfile
- **HitMovements** outputs

## Outputs to folder:
- mean_path_data.npy of E[paths]
- var_path_data.npy of Var[paths]
- std_path_data.npy of $\sqrt{\text{Var}[\text{paths}]}$
- sem_path_data.npy of SEM[paths]
- path_times.npy of the common aligned time range
- aligned_path_movements.npy a list of tuples where the first element is all the leverdata time series for each movement from before_duration before the second threshold to after_duration after the second threshold and the second element is the common time range
- plot_path_analysis.png as a png of the final figure

# Jerk
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

## This notebook analyzes 1 day session.

## Requires:
- ToneDisc matfile
- **PreprocessLeverData** output (for trial frequencies)
- **HitMovements** output

## Outputs to folder:
- velocity_trial#.npy velocities for all trials as finite differences
- acceleration_trial#.npy accelerations for all trials as finite differences
- jerk_trial#.npy jerks for all trials as finite differences
- jerk_ratios.npy number of movements x 4 numpy array 
    - with columns: `trial_index` | `jerk_ratio` | `actual_cumulative_jerk` | `minimum_cumulative_jerk`
- plot_jerk_ratios.png histogram of jerk ratio values


# ViewSingleMovements
For plotting every single movement individually.

## This notebook analyzes 1 day session.

## Requires:
- **PreprocessLeverData** output
- **HitMovements** outputs
- **Jerk** outputs
- ToneDisc matfile

## Outputs to folder:
- plot_trial#.png every single plot made is saved as a .png.
- plot_basic_trial#.png every single plot of only leverdata made is saved as a .png.



# Submodules

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
