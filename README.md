# toneDiscriminationV3.m
- reads from behaviorINV2.ino
- sets things in behaviorOUT.ino e.g. `fprintf(ardOut,'I')`
- lever sensor movement in ./helpers/leverMVT/detectMVTV2.m

## description:
- water-restricted mouse does 1 run of program per day
- up to many (1000) trials per run
- a run ends after _maxTotHits_ number of __Hits__ occur

__A Trial__:
- an _ITI_ duration between each trial
    - if lever press (_isMVT_ in code), extend _ITI_ delay
    - `fprintf(ardOut,'I')` ARDUINO LED (pin 8) turns on [?]
    - `fprintf(ardOut,'J')` ARDUINO LED (pin 8) turns off
- random _foreperiod_ at the beginning of each trial so that trial timing is somewhat random/can't be learned
    - `fprintf(ardOut,'A')` ARDUINO send a laser pulse (pin 10) to digidata
    - if lever press (_isMVT_ in code), restart and go back to _ITI_
- Either __Go trial__ or __No-Go trial__ tone is given
- _decision_ period after tone for mouse to press lever or not
- __Go trial__:
    - __Hit__: mouse press lever $\to$ H2O reward delivered $\to$ given _reward_consumption_ duration time to lick
        - ARDUINO left valve H2O (pin 7) `fprintf(ARDUINO.out,'E')`
    - __Miss__: mouse doesn't press lever $\to$ no reward
- __No-Go trial__:
    - __CR__: (correct reject) mouse doesn't press lever $\to$ no punishment and P(water reward) based on _fractRewCorrRej_ (aka "Surprise reward mode")
        - for "Surprise reward mode", ARDUINO left valve H2O (pin 7) `fprintf(ARDUINO.out,'E')`
    - __FA__: (false alarm) mouse press lever $\to$ air puff punishment
        - ARDUINO left air (pin 4) `fprintf(ARDUINO.out,'L')`

## toneDiscriminationV3.m Output:
__data.params__
- _animalID_: string, animal ID
- _nTrials_: num, number of trials per run
- _amountReward_: uL, amount of water reward
- _fractNoGo_: [0,1], fraction of total trials that are __No-Go__ (vs __Go__)
- _fractRewCorrRej_: [0,1], fraction of correct rejection (CR) trials that are rewarded, aka "Reward surprise mode"
- _durations_:
    - _foreperiod_: random distrib (e.g. `gaussian` for normal or `flat` for uniform) with parameters (e.g. mean `0.65`, std `0.15` for normal), for foreperiod duration in s so that mouse can't just lick at regular intervals and have to learn cue (trials start somewhat randomly)
    - _ITI_: s, inter-trial interval
    - _reward_consumption_: s, reward delivery period duration
    - _decision_: s, time after cue for mouse to make decision and press lever or not
    - _preReinforcement_: s, duration following a lever press before either water reward or air puff punishment
- _mvt_:
    - _thresh_: V, threshold for lever sensor to count as lever press
    - _noMvtThresh_: V, maximum movement allowed during baseline period [?]
- _tone_selection_: num, possible tone intensities from which one intensity will be randomly selected each trial
    - _ToneID_: `1`-`4` are tone A max-min, `5`-`8` are tone B max-min
- _punish_: boole, whether punishment is given or not
- _training_: boole, whether this is a training run or not
- _maxMiss_: NOT IMPLEMENTED YET, num, number of misses before stopping the run; if don't stop run based on misses, set as NaN
- _maxTotHits_: num, number of hits before stopping the run; if don't stop run based on hits, set as NaN
- _laser_: 3 elem vector
    - [
        _fractLaser_: random fraction of trials to have optogenetic laser,
        ntrial baseline [?],
        laserExp index,
    ]
    - possible values for _fractLaser_: 0.5, 0.4, 1/3, 0.3, 1/4, 0.2, 0.1, 0
- _laserExp_: possible optogenetic laser expt settings (3rd elem in _laser_)
    - `{'Arch/Jaws','ChR2', 'Arch/Jaws-Reinf', 'ArchSuprise'}`
    - 0 if no optogenetics
- _laserCtrlIO_: boole, whether this is a control laser run or not (laser settings are all the same, but no optogenetic laser light actually delivered)
- _laserLocation_: num, LC=1 PFC=2 MC=3
- _MTXTrialTypeHeader_: header,
`TRIAL#` | `TRIALTYPE(0 no-go / 1 go)` | `TONEID` | `durFOREPERIOD`
- _MTXTrialType_: nTrials x 5 [what's the last col?] matrix, row vals based on _MTXTrialTypeHeader_. Trials not run (d/t reaching _MaxTotHits_ number of hits) are rows of NaN
    - `TRIAL#`: num, index of trial
    - `TRIALTYPE(0 no-go / 1 go)`: boole, 1 if __Go trial__ or 0 if __No-Go trial__
    - `TONEID`: num, tone id that was played
    - `durFOREPERIOD`: _foreperiod_ duration for that trial
- _computerName_: string, system/computer hostname
- _systName_: string, system/computer hostname

__data.response__
- _dataArduinoHeader_: header,
`TimeMATLAB` | `MVT` | `LICK1` | `LICK2`
- _dataArduino_:
    - ARDUINO.data with each row as data sent from behaviorINV2.ino
    - `TimeMATLAB`: double, MATLAB time
    - `MVT`: V, lever sensor movement
    - `LICK`: boole, lickspout 1 sensor
    - `LICK2`: boole, lickspout 2 sensor
- _respMTXheader_: header,
`timeTrialStart` | `timeTone` | `leverPressed` | `timePressed` | `MVT0` | `earlyPress` | `rew`
- _respMTX_: num of actual trials in run x 7 matrix, row vals based on _respMTXheader_
    - `timeTrialStart`: double, MATLAB time at trial start includes foreperiod duration, but not ITI
    - `timeTone`: double, MATLAB time for tone
    - `leverPressed`: boole, 1 if press, 0 if doesn't press
    - `timePressed`: double, MATLAB time when press happens
    - `MVT0`: V, reference movement as the first value of _dataARDUINO.MVT_
    - `earlyPress`: if press lever before tone during the foreperiod duration

# ./analysis/dprime.m
$F^{-1}$(__Hit__ rate) $- F^{-1}$(__FA__ rate)
N(0, 1) distrib

