## **data/datasets_with_spike_waveforms_2000Hz.mat**

The file **data/datasets_with_spike_waveforms_2000Hz.mat** contains a single MATLAB struct called `datasets`.
`datasets` has the following fields, each with 224 rows corresponding to a single recording:

`animal` - a 224x1 categorical vector with the ID of the animal (i.e. "m1")
`day` - a cell array with each entry corresponding to the recording day (either "D1" through "D5") or a date + hour for certain monitoring sessions
`sess` - a cell array with values of:

* "b1" indicating behavior session 1 of that day (delayed alternation),
* "b2" indicating behavior session 2 (not used here, continuous alternation)
* "s1"/"s2"/"s3" are sleep sessions before, between, and after b sessions
* "mon1"/"mon2"/"mon3" are ~1 hour monitoring sessions
* An integer, also a monitoring session but for m7 over night

`data` - a 224x6 cell array with columns corresponding to:

* Col 1: spike time in seconds of ALL detected interictal spikes
* Col 2: the x position on the maze at that spike time, in PIXELS. ***For animal m7, conversion factor is 14cm/px, for all others it is 3.6757 cm/px. The maze dimensions are 48x48 cm and 80x90 cm respectively***
* Col 3: the y position at that spike time
* Col 4: the maze zone at that spike time (Outer arms/other = 0, Delay = 1, Choice = 2, West Reward = 3, East Reward = 4)
* Col 5: the velocity at that spike time
* Col 6: A matrix containing 400 samples at 2000 Hz LFP. The 201-th sample is centered on the time of each spike in Col 1

`ISIs` - a 224x1 cell array containing the inter-spike intervals (ISI) for that session

`BIRDs` - a 224x1 cell array each containing a struct with as many fields as their are BIRDs + solitary spikes,  the field names are

* `chain_idx`: each row contains a vector of indexes which refer to entries in the respective `data` struct. Indexes in the same row are "chained" together, i.e. they are part of the same BIRD (brief interictal rhythmic discharge). BIRDs of length 1 are SOLITARY SPIKES
* `chain_len`: the number of spikes in the BIRD. Again, BIRDs of length 1 are SOLITARY SPIKES
* `chain_dur`: the number of seconds from the first spike to the last spike. Solitary spikes have duration of 0 s

`is_solitary`: a helper field which is a 224x1 cell array of logical vectors indicating whether the spike in `data` is solitary (redundant to `BIRDs.chain_dur == 0` or `BIRDs.chain_len == 0`)

`behavior`: a helper field which is a 224x1 logical array indicating whether the session in question is behavioral session

`pos`: a 224x1 cell array each containing a struct with fields `x`,`y`, and `t` (seconds)

`parsed_path`: ***most of the fields here can be safely ignored as they either redundant are used in preprocessing to arrive at `pos` and/or `data`.*** For completeness, this a 224x1 cell array each containing a large struct with entries as follows:

* `path`: an array with columns of x-position, y-position, and time (seconds)
* `Coordinates`: a struct with fields containing the x and y coordinate of pertinent corners of the maze
* `Maze`: a struct with `x` and `y` boundaries of the maze
* `Entry`: a struct with fields that contain a list of rows in `path` where the animal enters the zone denoted by the respective fieldname
* `Trials`: A cell array with as many columns as trials. In each cell, the x and y positions of where the mouse was during that trial are contained
* `TrialIndices`: A cell array with as many columns as trials. In each cell are the starting and stopping index of of `pos` that lead to cells of `Trials`
* `Evaluate`: an array containing the outcome of each trial, and the last few rows are human-readable summaries of the behavioral performance
* `BinnedPath`: an array with columns: time, x, y, x-bin, y-bin, maze-zone index ( see `data` Col 4), and velocity.
* `xbins`, `ybins`, and `counts`: the binned occupancy of locations on the maze
* `ZoneBins`: a struct where each field contains an array of the bins from `BinnedPath` that correspond to pertinent reward zones
* `Bounds`: a struct with field corresponding to pertinent zones, specifying rectangular areas that serve to establish if the mouse is in that zone

## Detector\_Tuning

A folder which contains the following files and subdirectories:

* ".\Labeling Ground Truth\ls_label_3min_fixed_2462_PART2_MERGED_labelled.mat"  : a MATLAB labelled signal set with manually labelled interictal spikes
* "grab_spike_no_spike_examples.m": uses the signals stored in ".\Labeling Ground Truth\ls_label_3min_fixed_2462_PART2_MERGED_labelled.mat" to perform AUC analysis. Setting the variable `wh_animal` to an integer 1-7 changes with animal for which the performance curve is calculated. Based on the resultant F1/2 score, the optimal detector setting are determined
* "inspect_detections.m": a helper function to plot the detected samples on the the signal
* "PrecSummary.m": a helper function to compute F1 and F1/2 scores from the putative detections and ground truth. F1 and F1/2 scores are summaries of the recall and precision of the detector
* "spike_detector.m": the function that takes in an LFP (`sig`) and time stamps (`ts`) and returns a set of indexes corresponding to interictal spike. This can be tuned by setting `fs`(sample rate),`f_low`(low pass band),`f_high` (high pass band),`theta` (threshold)
* "spike_simple_detection_pipeline.m": wraps spike_detector calls
