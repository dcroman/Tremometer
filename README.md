README for Tremometer 1.0 - Matlab code to automatically detect and characterize harmonic tremor 
in continuous seismic data.

Last modified: July 31, 2017

For details on the analysis method, please read (and cite): Roman, D.C. (2017), Automated detection and characterization of harmonic tremor in continuous seismic data. Geophys. Res. Lett.,44,doi: 10.1002/2017GL073715.

Report bugs or suggestions for future releases to droman@carnegiescience.edu. 


NECESSARY FILES - The working directory must contain three files: 
1. tremometer_control.m
2. tremometer.m
3. A single-column ascii file containing one day of seismic data. Note: Tremometer does not provide filtering or instrument response deconvolution, so these operations should be peformed independently before analysis. For this task I recommend using the code described in Haney et al. (2012) Causal Instrument Corrections for ShortPeriod and Broadband Seismometers. 


SETUP
The user should set seven parameters in the first section of 'tremometer_control.m': 

The first five parameters describe the seismic data to be analyzed: 
1. x - Assign one day of (instrument-corrected and filtered) data to x
2. yr - Set start date (four digit year) of input data
3. mo - Set start date (two digit month) of input data
4. dy - Set start date (two digit day) of input data
5. fs - Set sampling frequency (in Hz). 

The last two parameters describe the criteria for detection of harmonic tremor: 
6. minfreq - set the minimum allowed frequency of the fundamental (in Hz). Default is 0.5 Hz
7. minHSI - set the minimum allowed Harmonic Strength Index for the fundamental and first two overtones. Default is 30. 


OPERATION
Once the control parameters have been set, execute the code by running tremometer_control.m at the Matlab command line (from the working directory)
> tremometer_control


EXAMPLE
An example of one day of instrument-corrected, bandpass-filtered (0.5-20Hz) seismic data containing multiple episodes of harmonic tremor is provided as 'example.asc'. To run as an example, download this file, place it in a directory with tremometer_control.m and tremometer.m, edit tremometer_control.m to set fs=40 and x=example.asc, and run tremometer_control.m at the command line. 


OUTPUT
1. Command window list of each tremor detection (detection time, frequencies of the fundamental and first three harmonics, and HSI for the fundamental and first two harmonics). 
This information is also contained in the workspace in the 'detections' table. 

2. The variable 'final' contains the analysis results for all input data. Each row corresponds to a minute of the analyzed day.

3. (Calibration mode) A figure will be displayed for each identified minute of harmonic tremor, showing the periodigram and detected harmonics (three '*' symbols). 

4. Figure 1: The HSI of the fundamental for the entire day. 

5. Figure 2: The frequencies and time(s) for each identified minute of harmonic tremor. 




TO BE ADDED TO FUTURE VERSIONS

Check more than three harmonics. 
Add more options - required number of overtones, minimum HSI per tone (are these equal or different?, number of consecutive minutes.
Change time increment - right now it is hard-coded to be one minute 
Better plotting options


KNOWN BUGS (to be fixed in future versions): 
It's still throwing 'Index exceeds matrix dimensions' errors occasionally. See for ex December 8 in PV6 data. 
