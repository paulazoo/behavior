# Data_Renamed
Original, renamed Data. Leave alone.

# Data_Copy
Data copied over for analysis. Also includes AnalysisData.

# analysis
Each analysis notebook has documentation explaining what is going on inside of it, including what should be outputted to the analysis output folder.

# ./behavior/ToneDiscrimination.m
- reads from behaviorIN.ino
- sets things in behaviorOUT.ino e.g. `fprintf(ardOut,'I')`
- lever sensor movement in ./helpers/leverMVT/detectMVTV2.m

## description:
- water-restricted mouse does 1 run of program per day
- up to many (1000) trials per run
- a run ends after _maxTotHits_ number of __Hits__ occur

__A Trial__:
- a random _ITI_ duration between each trial:
    - `fprintf(ardOut,'I')` ARDUINO tStart (pin 8) turns on
- the actual trial:
    - `fprintf(ardOut,'J')` ARDUINO tStart (pin 8) turns off
    - Either __Go trial__ or __No-Go trial__ tone is given
    - _decision_ period after tone for mouse to press lever or not
    - __Go trial__:
        - __Hit__: mouse press lever $\to$ H2O reward delivered $\to$ given _reward_consumption_ duration time to lick
            - ARDUINO H2O reward (pin 7) `fprintf(ARDUINO.out,'W')`
        - __Miss__: mouse doesn't press lever $\to$ no reward
    - __No-Go trial__:
        - __CR__: (correct reject) mouse doesn't press lever $\to$ no punishment and P(water reward) based on _fractRewCorrRej_ (aka "Surprise reward mode")
            - for "Surprise reward mode", ARDUINO H2O reward (pin 7) `fprintf(ARDUINO.out,'W')`
        - __FA__: (false alarm) mouse press lever $\to$ air puff punishment
            - ARDUINO air punishment (pin 4) `fprintf(ARDUINO.out,'A')`

## ToneDiscrimination.m Output:
__data.params__
- _[0] animalID_: string, animal ID
- _[2] nTrials_: num, number of trials per run
- _[3] amountReward_: uL, amount of water reward
- _[4] fractNoGo_: [0,1], fraction of total trials that are __No-Go__ (vs __Go__)
- _[5] fractRewCorrRej_: [0,1], fraction of correct rejection (CR) trials that are rewarded, aka "Reward surprise mode"
- _[6] durations_:
    - _ITISettings_: [a, b] s, parameters of the Uniform random distribution for inter-trial interval (e.g. [`8.0`, `12.0`]) so that mouse can't just lick at regular intervals and have to learn cue (trials start somewhat randomly)
        - ITI must be at least 1.0s
    - _reward_consumption_: s, reward delivery period duration
    - _decision_: s, time after cue for mouse to make decision and press lever or not
    - _preReinforcement_: s, duration following a lever press before either water reward or air puff punishment
- _[7] mvt_:
    - _mvtThresh_: V, threshold for lever sensor to count as lever press
    - _noMvtThresh_: V, maximum movement allowed during foreperiod without trial becoming an NaN trial
- _[8] tone_selection_: num, possible tone intensities from which one intensity will be randomly selected each trial
    - _ToneID_: `1`-`4` are tone A max-min, `5`-`8` are tone B max-min
- _[9] punish_: boole, whether punishment is given or not
- _[10] training_: boole, whether this is a training run or not
- _[11] maxMiss_: NOT IMPLEMENTED YET, num, number of misses before stopping the run; if don't stop run based on misses, set as NaN
- _[12] maxTotHits_: num, number of hits before stopping the run; if don't stop run based on hits, set as NaN
- _[13] laser_: 3 elem vector
    - [
        _fractLaser_: random fraction of trials to have optogenetic laser,
        ntrial baseline [?],
        laserExp index,
    ]
    - possible values for _fractLaser_: 0.5, 0.4, 1/3, 0.3, 1/4, 0.2, 0.1, 0
- _[14] laserExp_: possible optogenetic laser expt settings (3rd elem in _laser_)
    - `{'Arch/Jaws','ChR2', 'Arch/Jaws-Reinf', 'ArchSuprise'}`
    - 0 if no optogenetics
- _[15] laserCtrlIO_: boole, whether this is a control laser run or not (laser settings are all the same, but no optogenetic laser light actually delivered)
- _laserLocation_: num, LC=1 PFC=2 MC=3
- _[17] MTXTrialTypeHeader_: header,
`TRIAL#` | `TRIALTYPE(0 no-go / 1 go)` | `TONEID` | `durITI`
- _[16] MTXTrialType_: nTrials x 5 [what's the last col?] matrix, row vals based on _MTXTrialTypeHeader_. Trials not run (d/t reaching _MaxTotHits_ number of hits) are rows of NaN
    - `TRIAL#`: num, index of trial
    - `TRIALTYPE(0 no-go / 1 go)`: boole, 1 if __Go trial__ or 0 if __No-Go trial__
    - `TONEID`: num, tone id that was played
    - `durITI`: ITI duration for that trial
- _[1] computerName_: string, system/computer hostname
- _[18] systName_: string, system/computer hostname

__data.response__
- _[1] dataArduinoHeader_: header,
`TimeMATLAB` | `MVT` | `LICK1` | `LICK2`
- _[0] dataArduino_:
    - ARDUINO.data with each row as data sent from behaviorIN.ino
    - `TimeMATLAB`: double, MATLAB time
    - `MVT`: V, lever sensor movement
    - `LICK`: boole, lickspout 1 sensor
    - `LICK2`: boole, lickspout 2 sensor
- _[3] respMTXheader_: header,
`timeTrialStart` | `timeTone` | `leverPressed` | `timePressed` | `MVT0` | `ITIPress` | `rew`
- _[2] respMTX_: num of actual trials in run x 7 matrix, row vals based on _respMTXheader_
    - `timeTrialStart`: double, MATLAB time at trial start includes foreperiod duration but not ITI
    - `timeTone`: double, MATLAB time for tone
    - `leverPressed`: boole, 1 if press, 0 if doesn't press
    - `timePressed`: double, MATLAB time when press happens
    - `MVT0`: V, reference movement as the mean of the first 100 values of lever movement
    - `ITIPress`: if press lever before tone during the foreperiod duration
    -  `rew`: 1 if __Hit__, 0 if __Miss__, 0 if __FA__, 0 if __CR__ unless "Surprise reward mode" then 1 if surprise reward


# ./behavior/helpers/card/setupArduino.m
setup and open serial ports for ArdIN and ArdOUT
- outputs: `ardIn`,`ardOut`

# ./behavior/helpers/card/readArduino.m
read most recent values from ArdIN
- arguments: `ard`, `t0`, optional `msgOn`
- outputs: `d` the data
    - d(1) = absolute time
    - d(2) = lever value
    - d(3) = lickspout1 value
    - d(4) = lickspout2 value
    - d(5) = accelerator X value
    - d(6) = accelerator Y value
    - d(7) = accelerator Z value

# ./behavior/helpers/card/cleanArduino.m
turn all to LOW if ArdOUT, then close regardless if ArdIN or ArdOUT
- arguments: `ard`, `type` such as `OUT`

# ./behavior/helpers/card/recordContinuous.m
record lever and lick data continuously for some duration of time
- arguments: `ARDUINO`, `recordingDuration` the duration to record, `ESC`
- outputs: `ARDUINO` with updated `ARDUINO.data`, `ESC`

# ./behavior/helpers/general/printPerformance.m
Print a performance string based on responses so far
- arguments: `respMTX`,`MTXTrialType`,`N`
- outputs: `str` as string about the performance to display

# ./behavior/helpers/general/toneDiscrRandomizeTrial.m
randomize Go vs No Go trials, tone according to trial type, durITI, and laser
- arguments: `nTrials`,`toneSelect`,`fractGo`,`ITISettings`,`paramLaser`
- outputs: `MTXTrialType`

# ./behavior/helpers/general/vecOfRandPerm.m
helper function for random permutations of vectors

# ./behavior/helpers/sound/soundInit.m
initialize sound player with a `soundStimMatrix` = 
```
[
    1 4000 computerScalingFactor(1)*soundAmplitude 0.5 50
    2 4000 computerScalingFactor(1)*soundAmplitude*0.3163 0.5 50
    3 4000 computerScalingFactor(1)*soundAmplitude*0.1 0.5 50
    4 4000 computerScalingFactor(1)*soundAmplitude*0.03163 0.5 50
    
    5 12000 computerScalingFactor(2)*soundAmplitude 0.5 50
    6 12000 computerScalingFactor(2)*soundAmplitude*0.3163 0.5 50
    7 12000 computerScalingFactor(2)*soundAmplitude*0.1 0.5 50
    8 12000 computerScalingFactor(2)*soundAmplitude*0.03163 0.5 50
    ]
```
columns: index | freq | amplitude | sound duration | SNR
- outputs: `snd` the sound player

# ./behavior/helpers/sound/soundPlay.m
play a sound
- arguments: `soundId`, `snd` the sound player

# ./behavior/helpers/water_calibration/water_reward2duration.m
get valve duration based on water reward amount and calibration .mat file (should be in the helpers/water_calibration folder)
- arguments: `rewAmount`,`valveID`
- outputs: `durValve`

# ./behavior/helpers/leverMVT/referenceMVT.m
get referenceMVT for some number of Arduino samples
- arguments: `ARDUINO`,`num_reference_samples`
- outputs: `MVT0`

# ./behavior/helpers/leverMVT/detectLeverPress.m
detect a lever press
- arguments: `ARDUINO`, `params`, `escapeKey`
    - `ARDUINO` is a structure with fields
        - in = serial port for input arduino
        - out = serial port for output arduino
        - idx = current idx number. Increased everytime arduino in is sampled
        - t0 = reference start time to evaluate data from
    - data = data read from arduino:
        - d(1) = absolute time
        - d(2) = lever value
        - d(3) = lickspout1 value
        - d(4) = lickspout2 value
        - d(5) = accelerator X value
        - d(6) = accelerator Y value
        - d(7) = accelerator Z value
    - `params` = [`detectionDuration` `MVT0` `noMvtThresh` `mvtThresh` `maxMvtDuration`];
- outputs: `ARDUINO`, `leverPress`, `ESC`

# ./behavior/helpers/leverMVT/detectITIMovement.m
detect movement past noMvtThresh (for during ITI)
- arguments: `ARDUINO`, `params`, `escapeKey`
    - `ARDUINO` is a structure with fields
        - in = serial port for input arduino
        - out = serial port for output arduino
        - idx = current idx number. Increased everytime arduino in is sampled
        - t0 = reference start time to evaluate data from
    - data = data read from arduino:
        - d(1) = absolute time
        - d(2) = lever value
        - d(3) = lickspout1 value
        - d(4) = lickspout2 value
        - d(5) = accelerator X value
        - d(6) = accelerator Y value
        - d(7) = accelerator Z value
    - `params` = [`detectionDuration` `MVT0` `noMvtThresh`];
- outputs: `ARDUINO`, `ITIMovement`, `ESC`

# ./behavior/helpers/leverMVT/testLeverValues.m
For troubleshooting and testing lever displacement to voltage relationships


# dprime definition
$F^{-1}$(__Hit__ rate) $- F^{-1}$(__FA__ rate)
N(0, 1) distrib

