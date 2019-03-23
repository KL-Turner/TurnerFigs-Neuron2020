function [] = MainScript_SlowOscReview2019()
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose: Generates KLT's main and supplemental figs for the 2019 Slow Oscillations review paper. 
%
%            Scripts used to pre-process the original data are located in the folder "Pre-processing-scripts".
%            Functions that are used in both the analysis and pre-processing are located in the analysis folder.
%________________________________________________________________________________________________________________________
%
%   Inputs: No inputs - this function is intended to be run independently.
%
%   Outputs: Each main and supplmental figure with its corresponding number and letter in the paper.
%
%   Last Revised: March 22nd, 2019
%________________________________________________________________________________________________________________________

%% Make sure the current directory is 'TurnerFigs-SlowOscReview2019' and that the MainScript/code repository is present.
currentFolder = pwd;
addpath(genpath(currentFolder));
fileparts = strsplit(currentFolder, filesep);
if ismac
    rootfolder = fullfile(filesep, fileparts{1:end}, 'Processed Data');
else
    rootfolder = fullfile(fileparts{1:end}, 'Processed Data');
end
addpath(genpath(rootfolder))   % add root folder to Matlab's working directory

%% Run data analysis. The progress bars will show the analysis progress.
GT_multiWaitbar('Analyzing whisking-evoked data', 0, 'Color', [0.720000 0.530000 0.040000]); pause(0.25);
GT_multiWaitbar('Analyzing cross correlation', 0, 'Color', [0.720000 0.530000 0.040000]); pause(0.25);
GT_multiWaitbar('Analyzing coherence', 0, 'Color', [0.720000 0.530000 0.040000]); pause(0.25);
GT_multiWaitbar('Analyzing power spectra', 0, 'Color', [0.720000 0.530000 0.040000]); pause(0.25);

[ComparisonData] = AnalyzeData_SlowOscReview2019;
multiWaitbar_SlowOscReview2019('CloseAll');

%% Individual figures can be re-run after the analysis has completed.
% FigOne_SlowOscReview2019(ComparisonData)         % Avg. Evoked whisking responses
% FigTwo_SlowOscReview2019(ComparisonData)         % Avg. Cross-correlation
% FigThree_SlowOscReview2019(ComparisonData)       % Avg. Coherence
% FigFour_SlowOscReview2019(ComparisonData)        % Avg. Power Spectra
% SuppFigOne_SlowOscReview2019(ComparisonData)     % Individual Evoked whisking responses
% SuppFigTwo_SlowOscReview2019(ComparisonData)     % Individual Cross-correlation
% SuppFigThree_SlowOscReview2019(ComparisonData)   % Individual Coherence
% SuppFigFour_SlowOscReview2019(ComparisonData)    % Individual Power Spectra

% To view individual summary figures, change the value of line 82 to false. You will then be prompted to manually select
% any number of figures (CTL-A for all) inside any of the five folders. You can only do one animal at a time.

end

function [ComparisonData] = AnalyzeData_SlowOscReview2019()
% animalIDs = {'T72', 'T73', 'T74', 'T75', 'T76'};   % list of animal IDs
% ComparisonData = [];   % pre-allocate the results structure as empty
% 
% %% BLOCK PURPOSE: [1] Analyze the whisking-evoked changes in vessel diameter and neural LFP.
% for a = 1:length(animalIDs)
%     [ComparisonData] = AnalyzeEvokedResponses_SlowOscReview2019(animalIDs{1,a}, ComparisonData);
%     GT_multiWaitbar('Analyzing whisking-evoked data', a/length(animalIDs));
% end
% 
% %% BLOCK PURPOSE: [2] Analyze the cross-correlation between abs(whisker acceleration) and vessel diameter.
% for b = 1:length(animalIDs)
%     [ComparisonData] = AnalyzeXCorr_SlowOscReview2019(animalIDs{1,b}, ComparisonData);
%     GT_multiWaitbar('Analyzing cross correlation', b/length(animalIDs));
% end
% 
% %% BLOCK PURPOSE: [3] Analyze the spectral coherence between abs(whisker acceleration) and vessel diameter.
% for c = 1:length(animalIDs)
%     [ComparisonData] = AnalyzeCoherence_SlowOscReview2019(animalIDs{1,c}, ComparisonData);
%     GT_multiWaitbar('Analyzing coherence', c/length(animalIDs));
% end
% 
% %% BLOCK PURPOSE: [4] Analyze the spectral power of abs(whisker acceleration) and vessel diameter.
% for d = 1:length(animalIDs)
%     [ComparisonData] = AnalyzePowerSpectrum_SlowOscReview2019(animalIDs{1,d}, ComparisonData);
%     GT_multiWaitbar('Analyzing power spectra', d/length(animalIDs));
% end

%% BLOCK PURPOSE: [5] Create single trial summary figures. selectFigs = false displays the one used for representative example.
selectFigs = true;   % set to true to manually select other figure(s).
GenerateSingleFigures_SlowOscReview2019(selectFigs)

end

function [] = GenerateSingleFigures_SlowOscReview2019(selectFigs)
if selectFigs == true
    [fileNames, path] = uigetfile('*_MergedData.mat', 'MultiSelect', 'on');
    cd(path)
else
    fileNames = '';
end

% Load the RestingBaselines structure from this animal
baselineDirectory = dir('*_RestingBaselines.mat');
baselineDataFile = {baselineDirectory.name}';
baselineDataFile = char(baselineDataFile);
load(baselineDataFile, '-mat')

for a = 1:length(fileNames)
    % Control for the case that a single file is selected vs. multiple files
    if iscell(fileNames) == 1
        indFile = fileNames{1,a};
    else
        indFile = fileName;
    end
    
    load(indFile, '-mat');
    disp(['Analyzing single trial figure ' num2str(a) ' of ' num2str(size(fileNames,2)) '...']); disp(' ');
    [animalID, fileDate, fileID, vesselID, imageID] = GetFileInfo2_SlowOscReview2019(indFile);
    strDay = ConvertDate(fileDate);
    
    %% BLOCK PURPOSE: Filter the whisker angle and identify the solenoid timing and location.
    % Setup butterworth filter coefficients for a 10 Hz lowpass based on the sampling rate (150 Hz).
    [B, A] = butter(4, 10/(MergedData.notes.dsFs/2), 'low');
    filteredWhiskerAngle = filtfilt(B, A, MergedData.data.whiskerAngle);
    filtForceSensor = filtfilt(B, A, MergedData.data.forceSensorM);
    binWhiskers = MergedData.data.binWhiskerAngle;
    binForce = MergedData.data.binForceSensorM;
    
    %% CBV data - normalize and then lowpass filer
    vesselDiameter = MergedData.data.vesselDiameter;
    normVesselDiameter = (vesselDiameter - RestingBaselines.(vesselID).(strDay).vesselDiameter.baseLine)./(RestingBaselines.(vesselID).(strDay).vesselDiameter.baseLine);
    [D, C] = butter(4, 1/(MergedData.notes.p2Fs/2), 'low');
    filtVesselDiameter = (filtfilt(D, C, normVesselDiameter))*100;
    
    %% Neural spectrograms
    specDataFile = [animalID '_' vesselID '_' fileID '_' imageID '_SpecData.mat'];
    load(specDataFile, '-mat');
    normS = SpecData.fiveSec.normS;
    T = SpecData.fiveSec.T;
    F = SpecData.fiveSec.F;
    
    %% Yvals for behavior Indices
    whisking_YVals = 1.10*max(detrend(filtVesselDiameter, 'constant'))*ones(size(binWhiskers));
    force_YVals = 1.20*max(detrend(filtVesselDiameter, 'constant'))*ones(size(binForce));
    
    %% Figure
    figure;
    ax1 = subplot(4,1,1);
    plot((1:length(filtForceSensor))/MergedData.notes.dsFs, filtForceSensor, 'color', colors_SlowOscReview2019('sapphire'))
    title({[animalID ' Two-photon behavioral characterization and vessel ' vesselID ' diameter changes for ' fileID], 'Force sensor and whisker angle'})
    xlabel('Time (sec)')
    ylabel('Force Sensor (Volts)')
    xlim([0 MergedData.notes.trialDuration_Sec])
    
    yyaxis right
    plot((1:length(filteredWhiskerAngle))/MergedData.notes.dsFs, -filteredWhiskerAngle, 'color', colors_SlowOscReview2019('ash grey'))
    ylabel('Angle (deg)')
    legend('Force sensor', 'Whisker angle')
    xlim([0 MergedData.notes.trialDuration_Sec])

    ax2 = subplot(4,1,2:3);
    plot((1:length(filtVesselDiameter))/MergedData.notes.p2Fs, detrend(filtVesselDiameter, 'constant'), 'color', colors_SlowOscReview2019('dark candy apple red'))
    hold on;
    whiskInds = binWhiskers.*whisking_YVals;
    forceInds = binForce.*force_YVals;
    for x = 1:length(whiskInds)
        if whiskInds(1, x) == 0
            whiskInds(1, x) = NaN;
        end
        
        if forceInds(1, x) == 0
            forceInds(1, x) = NaN;
        end
    end
    scatter((1:length(binForce))/MergedData.notes.dsFs, forceInds, '.', 'MarkerEdgeColor', colors_SlowOscReview2019('rich black'));
    scatter((1:length(binWhiskers))/MergedData.notes.dsFs, whiskInds, '.', 'MarkerEdgeColor', colors_SlowOscReview2019('sapphire'));
    title('Vessel diameter in response to behaviorial events')
    xlabel('Time (sec)')
    ylabel('% change (diameter)')
    legend('Vessel diameter', 'Binarized movement events', 'binarized whisking events')
    xlim([0 MergedData.notes.trialDuration_Sec])
    
    ax3 = subplot(4,1,4);
    imagesc(T,F,normS)
    axis xy
    colorbar
    caxis([-0.5 0.75])
    linkaxes([ax1 ax2 ax3], 'x')
    title('Hippocampal (LFP) spectrogram')
    xlabel('Time (sec)')
    ylabel('Frequency (Hz)')
    xlim([0 MergedData.notes.trialDuration_Sec])
end

end