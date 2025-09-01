Data organization:
1. Spike files must be organized in the exact format as follows. Must be abf files.

2. Example format with 2 flies and 3 dilutions tested for each fly:
- The data folder should contain 6 abf files named as follows: 01_01, 01_02, 01_03, 02_01, 02_02, 02_03.
- The first digit indicates the fly and the last digit indicates the dilution.

Run Spike_sorting_prep.mlapp:
This GUI organizes the data for spike analysis and LFP analysis.

1. Set path to “plotSpread.m” (see "Associate_function" folder)

2. Click “Load folder” and select the data folder containing all the abf files.

3. Input the n number, number of dilutions, and delta t.

4. Click “Start”

5. Click “Save spikes” and “Save LFP”

Spike sorting:
This GUI allows users to sort the spikes and obtain the spike timing

1. Run spikesort_20220527_mac.m fron the “Spike_Sorting_2.5” folder.

2. Click “load data” and select the organized spike data.

3. Click “find” to select all of the spikes.

4. Click “noise” and then click on the spike trace to separate the spikes from noise. When sorting the A spikes only, users can sort the B spikes as noise. Click “done” when finished.

5. Click “neuron” and then click on the spike trace to separate A spikes from B spikes. Click done when finished.

6. If you want to manually add or delete a spike, zoom in to the spike of interest, click on the spike, and then press “n” (this adds an A spike by default; click on the spike again and press “B” to add a B spike) or “space” (this deletes the spike).

7. When finished, move to the next spike trace by clicking the right arrow in the “Current Trace” tab. Note: “num exp” indicates the fly number and “num trials” indicates the dilution number.

8. The sorting results are automatically saved in the input folder, with an extension of SPKtemp.mat.

Spike analysis:
This GUI will calculate the spike timing, peri-stimulus time histograms (PSTH), and peak responses (Hz).

Input instruction:
There are two GUIs, one for the analysis of A spikes and one for B spikes.
- Control: No
- Raster: No
- Load data: select the SPKtemp.mat file
-  n number ORNname: total number of flies (e.g., 7)
-  n number dendrite: must be equal to n number ORNname (e.g., 7)
- number of dilution: total number of dilutions (e.g., 3)
- Numerical value of dilution: the values should be separated by space (e.g., 10^-3 10^-2 10^-1)
- Bin: bin size for the PSTH with a unit of milliseconds (e.g., 50)
- Length: length of recordings in milliseconds (e.g., 40000)
- Stimulus onset: the time point when the odorant was applied with a unit of seconds (e.g., 7.5)
- The parameters under the “Plotting” tab are only for display of the graphs and do not affect the quantified data output. To avoid error message, users must input for “Time after stimulus for PSTH” and “Dilution for PSTH”
- Time after stimulus for PSTH: define the duration of the PSTH plot to be shown. 1-second pre-stimulus period and a user defined time after stimulus will be shown (e.g., 2)
- Dilution for PSTH: dilution to be shown for the PSTH plot (e.g., 3 for the third lowest dilution)
- Click “Start” to start the analysis. When finished, click “Save data”.

Data output:
1. The output will be a mat file containing the spike timing (in millisecond and rounded to whole number), peri-stimulus time histograms (the baseline spike rate—calculated from a 1-second pre-stimulus period—was subtracted from each binned value; smoothed using a sliding window with window length = 5 and overlap = 4), and peak responses (Hz). 

LFP analysis:
This GUI will apply a Butterworth filter and downsample the LFP data: 5000 data points per second were down-sampled to 50 data points per second by averaging every 100 data points. Basal LFP (averaged from 0.5 s pre-stimulus period; 25 data points) was subtracted from each LFP value (mV).

Input instruction:
Open LFP_analysis_GUI_desampled_v2.mlapp.
- Control: No
- n number ORNname: total number of flies (e.g., 7)
- number of dilution: total number of dilutions (e.g., 3)
- Stimulus onset: the time point when the odorant was applied with a unit of seconds (e.g., 7.5)
- Length: length of recordings in seconds (e.g., 40)
- Numerical value of dilution: the values should be separated by space (e.g., 10^-3 10^-2 10^-1)
- The parameters under the “Plotting” tab are only for display of the graphs and do not affect the quantified data output. To avoid error message, users must input for “Dilution for LFP”, “Start time”, and “End time”.
- Dilution for LFP: dilution to be shown for the LFP plot (e.g., 3 for the third lowest dilution)
- Start time: start time point to be shown for the LFP plot in seconds (e.g., 6.5 for the 6.5th second)
- End time: end time point to be shown for the LFP plot in seconds (e.g., 9.5 for the 9.5th second)

Data output:
1. The output will be a mat file containing the processed LFP data, peak LFP responses, SEM of the peak responses, and peak timing in seconds.
