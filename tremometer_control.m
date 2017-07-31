%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Tremometer 1.0                                                                                    %
%                                                                                                     %
%   Matlab code to automatically detect and characterize harmonic tremor                              %
%   in continuous seismic data using a pitch-detection algorithm                                      %
%                                                                                                     %
%   Diana C. Roman                                                                                    %
%   Last modified July 31, 2017                                                                       %
%                                                                                                     %
%   Please cite: Roman, D.C. (2017), Automated detection and characterization of harmonic tremor      %
%   in continuous seismic data. Geophys. Res. Lett.,44,doi: 10.1002/2017GL073715.                     %
%                                                                                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Set the following variables            %
%   (or leave as default values)           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



x=load('example.asc');      		%Assign one day of (instrument-corrected and filtered) data to x
yr=2015;			                  %Set start date (four digit year) of input data
mo=03;				                  %Set start date (two digit month) of input data
dy=03;				                  %Set start date (two digit day) of input data
fs=40;          		            %set sampling frequency (in Hz)
minfreq=0.5;    		            %set the minimum frequency of the fundamental (in Hz). Default is 0.5 Hz
minHSI=30;       		            %set the minimum Harmonic Strength Index for fundamental and two overtones. Default is 30. 




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Don't change anything below here       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nHarm=4;

s=1440;

for i=1:s
startpt(i)=1+((i-1)*fs*60);
endpt(i)=i*fs*60;
end

final=zeros(14,s);

for j=1:s
[harmpow,harmfreq,interharmpow,harmstrength]=tremometer(x(startpt(j):endpt(j)),fs,nHarm);
final(:,j)=vertcat(harmfreq,harmpow,interharmpow,harmstrength);
end

final=final';


%   Check minimum frequency criterion 
for j=1:s
if final(j,1) > minfreq
final(j,15)=1;
else final(j,15)=0;
end
end


%   Check minimum HSI criterion for each harmonic  
for j=1:s
if final(j,12) > minHSI
final(j,16)=1;
else final(j,16)=0;
end
end

for j=1:s
if final(j,13) > minHSI
final(j,17)=1;
else final(j,17)=0;
end
end

for j=1:s
if final(j,14) > minHSI
final(j,18)=1;
else final(j,18)=0;
end
end


%   Check if all criteria are met and flag tremor episodes, then add them to a list of detections with times
for j=1:s
if final(j,15)+final(j,16)+final(j,17)+final(j,18)==4
final(j,19)=1;
else final(j,19)=0;
end
end

%Make a table of harmonic tremor detections
ind1 = final(:,19) == 1;
date=datetime(yr,mo,dy,0,0,0);
t1=date;
t2=date+minutes(1439);
t=t1:minutes(1):t2;
t=t';
detection_times=t(ind1,:);
fund_freq=final(ind1,1);
harm_freq_1=final(ind1,2);
harm_freq_2=final(ind1,3);
harm_freq_3=final(ind1,4);
harm_pow_1=final(ind1,5);
harm_pow_2=final(ind1,6);
harm_pow_3=final(ind1,7);
harm_pow_4=final(ind1,8);
interharm_pow_1=final(ind1,9);
interharm_pow_2=final(ind1,10);
interharm_pow_3=final(ind1,11);
HSI_1=final(ind1,12);
HSI_2=final(ind1,13);
HSI_3=final(ind1,14);
clc
detections=table(detection_times,fund_freq,harm_freq_1,harm_freq_2,harm_freq_3,HSI_1,HSI_2,HSI_3)


%   Make some plots  
plot(t,final(:,12))
datetick('x')
ylabel('Harmonic Strength Index')
xlabel('Time of Day')
hline=refline([0 minHSI]);
hline.Color = 'r';
%end

figure
plot(detection_times,harm_freq_1, 'o')
ylabel('Frequency (Hz)')
xlabel('Time of Day')
%end

%Calibration mode - make Figure 1c for all detections
for j=1:s
if final(j,19) == 1
figure
snip=x(startpt(j):endpt(j));
snip=snip-mean(snip);
n=length(snip);
w=kaiser(n,38);
[Pxx,F]=periodogram(snip,w,n,fs);
plot(F,Pxx)
hold('on')
plot(final(j,1:3),final(j,5:7),'*')
ylabel('Power')
xlabel('Frequency (Hz)')
end
end


%tidy up
clear date detection_times dy endpt F fs fund_freq harm_freq_1 harm_freq_2 harm_freq_3 harm_pow_1 harm_pow_2 harm_pow_3 harm_pow_4 harmfreq harmpow harmstrength hline HSI_1 HSI_2 HSI_3 i ind1 interharmpow interharm_pow_1 interharm_pow_2 interharm_pow_3 j minfreq minHSI mo n nHarm prcdata Pxx s samplrate snip startpt t t1 t2 temp_detections w x yr

