function [harmPow, harmFreq, interharmPow, harmStrength] = tremometer(x,fs,nHarm)

 
% use Kaiser window to reduce effects of leakage before calculating periodogram
x = x - mean(x);
n = length(x);
w = kaiser(n,38);	    
[Pxx, F] = periodogram(x,w,n,fs);           %returns the PSD estimate - the integral of the PSD is the power in the time series


% pre-allocate harmonic tables - nHarm is a user-supplied argument - compute HSI for nHarm harmonics
harmPow = NaN(nHarm,1);
harmFreq = NaN(nHarm,1);
interharmPow = NaN(nHarm-1,1);
harmStrength = NaN(nHarm-1,1);
harmIdx = NaN(nHarm, 2);	
iHarm = NaN(nHarm, 1);

% Remove DC component
Pxx(1) = 2*Pxx(1);				
rbw = enbw(w, fs);				
[~, ~, ~, iLeft, iRight] = signal.internal.getToneFromPSD(Pxx, F, rbw, 0);  
Pxx(iLeft:iRight) = 0;                                                       


% Get an estimate of the fundamental frequency / amplitude through Harmonic Product Spectrum calculation
% hps1 is Pxx, so there are really only five decimations here. 
hps1=downsample(Pxx,1);                     %Redundant - could just use Pxx
hps2=downsample(Pxx,2);
hps3=downsample(Pxx,3);
hps4=downsample(Pxx,4);
hps5=downsample(Pxx,5);
hps6=downsample(Pxx,6);

y=[];
for i=1:length(hps6)
  Product=hps1(i)*hps2(i)*hps3(i)*hps4(i)*hps5(i)*hps6(i);
  y(i)=Product;
end

[~,n]=findpeaks(y,'SORTSTR','descend');
Maximum=n(1);
Ffund=F(Maximum);

	
%Check Pxx for peak near the ID'd fundamental freq
[~, ~, iHarm(1), iLeft, iRight] = signal.internal.getToneFromPSD(Pxx, F, rbw, Ffund);
harmFreq(1)=F(iHarm(1));
harmPow(1)=Pxx(iHarm(1));
harmIdx(1, :) = [iLeft; iRight];

% get indices of the harmonic frequencies / amplitudes, then use to query frequency and amplitude for each harmonic
for i=2:nHarm
  [~, ~, iHarm(i), iLeft, iRight] = signal.internal.getToneFromPSD(Pxx, F, rbw, i*Ffund);
  harmFreq(i)=F(iHarm(i));
  harmPow(i)=Pxx(iHarm(i));
  harmIdx(i, :) = [iLeft; iRight];
end

%Adjust frequency and amplitude of candidate harmonics by finding the maximum amplitude within 0.1Hz of each F in Pxx. It needs the 'else' bit or it throws a subscript indices tantrum if iHarm indices are low. 
%For now this is hardwired to +-0.1Hz search range.
for i=1:nHarm
    if iHarm(i)>=7
harmPow(i) = max(Pxx(iHarm(i)-6:iHarm(i)+6));
iHarm(i)=find(Pxx==harmPow(i));
harmFreq(i)=F(iHarm(i));
    else
harmFreq(i)=F(iHarm(i));
harmPow(i)=Pxx(iHarm(i));
    end
end


% Compute inter-harmonic frequencies - do this by taking the max in between harmonics
% First, must meet all three of the following conditions to assign an interharmonic, otherwise it gets a zero:
% harmIdx has two values for each harmonic - for an interharmonic to be calculated all of the numbers in column 1 have to be unique and all of the numbers in column 2 have to be unique (first two conditions)
% all of the numbers in harmIdx also have to be real numbers, not NANs (third condition)
% This is kludgy but it works. 

for i=1:(nHarm-1)
    if length(unique(harmIdx(:,1)))==nHarm && length(unique(harmIdx(:,2)))==nHarm && ~any(isnan(harmIdx(:,1)))
    interharmPow(i)=max(Pxx(round(harmIdx(i,2)+((harmIdx((i+1),1)-harmIdx(i,2))*.25)):round(harmIdx(i,2)+((harmIdx((i+1),1)-harmIdx(i,2))*.75))));
    else interharmPow(i)=0;
    end
end

if any(interharmPow)
   interharmPow = interharmPow*rbw;
end


% compute harmonic strength index

for i=1:(nHarm-1)
    if any(interharmPow)
        harmStrength(i)=harmPow(i)/interharmPow(i);
    else
        harmStrength(i)=0;
    end
end



