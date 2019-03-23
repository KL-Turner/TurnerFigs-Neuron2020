function FigOne_SlowOscReview2019(ComparisonData)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose: 
%________________________________________________________________________________________________________________________
%
%   Inputs: 
%
%   Outputs: 
%
%   Last Revised: March 22nd, 2019
%________________________________________________________________________________________________________________________

%%
animalIDs = fields(ComparisonData);
x = 1;
y = 1;
z = 1;
for t = 1:length(animalIDs)
    for a = 1:length(ComparisonData.(animalID).Whisk).data{1,1})
        whiskDataC1(x, :) = ComparisonData.Whisk.data{1,1}{a,1};
        vesselID = join([string(animalID) string(ComparisonData.Whisk.vesselIDs{1,1}{a,1})]);
        vIDs1{x,1} = strrep(vesselID, ' ', '');
        x = x + 1;
    end
    
    for b = 1:length(ComparisonData.Whisk.data{2,1})
        whiskDataC2(y, :) = ComparisonData.Whisk.data{2,1}{b,1};
        vesselID = join([string(animalID) string(ComparisonData.Whisk.vesselIDs{2,1}{b,1})]);
        vIDs2{y,1} = strrep(vesselID, ' ', '');
        y = y + 1;
    end
    
    for c = 1:length(ComparisonData.Whisk.data{3,1})
        whiskDataC3(z,:) = ComparisonData.Whisk.data{3,1}{c,1};
        vesselID = join([string(animalID) string(ComparisonData.Whisk.vesselIDs{3,1}{c,1})]);
        vIDs3{z,1} = strrep(vesselID, ' ', '');
        z = z + 1;
    end
    
    whiskLFPC1(:, :, t) = ComparisonData.Whisk.LFP.S{1,1};
    whiskLFPC2(:, :, t) = ComparisonData.Whisk.LFP.S{2,1};
    whiskLFPC3(:, :, t) = ComparisonData.Whisk.LFP.S{3,1};
end
T = ComparisonData.Whisk.LFP.T;
F = ComparisonData.Whisk.LFP.F;

whiskData_C1 = mean(whiskDataC1, 1);
whiskData_C2 = mean(whiskDataC2, 1);
whiskData_C3 = mean(whiskDataC3, 1);
whiskLFP_C1 = mean(whiskLFPC1, 3);
whiskLFP_C2 = mean(whiskLFPC2, 3);
whiskLFP_C3 = mean(whiskLFPC3, 3);

whiskSTD_C1 = std(whiskDataC1, 1, 1);
whiskSTD_C2 = std(whiskDataC2, 1, 1);
whiskSTD_C3 = std(whiskDataC3, 1, 1);

T = ComparisonData.Whisk.LFP.T;
F = ComparisonData.Whisk.LFP.F;

%%
timeVec = ((1:length(whiskData_C1))/20) - 4;
evokedAvgs = figure;
ax1 = subplot(3,3,1);
legendIDs = [];
for x = 1:size(whiskDataC1, 1)
    plot(timeVec, whiskDataC1(x,:));
    vID = vIDs1{x,1};
    hold on
end
title('Ind 0.5 to 2 seconds')
xlabel('Peri-whisk time (sec)')
ylabel('\Delta Diameter (%)')

ax2 = subplot(3,3,2);
legendIDs = [];
for y = 1:size(whiskDataC2, 1)
    plot(timeVec, whiskDataC2(y,:));
    vID = vIDs1{y,1};
    hold on
end
title('Ind 2 to 5 seconds')
xlabel('Peri-whisk time (sec)')
ylabel('\Delta Diameter (%)')

ax3 = subplot(3,3,3);
legendIDs = [];
for z = 1:size(whiskDataC3, 1)
    plot(timeVec, whiskDataC3(z,:));
    vID = vIDs1{z,1};
    legendIDs = [legendIDs vID];
    hold on
end
title('Ind 5 to 10 seconds')
xlabel('Peri-whisk time (sec)')
ylabel('\Delta Diameter (%)')
legend(legendIDs)
linkaxes([ax1 ax2 ax3], 'xy')

%%
ax4 = subplot(3,3,4);
plot(timeVec, whiskData_C1, 'k')
hold on
plot(timeVec, whiskData_C1 + whiskSTD_C1)
plot(timeVec, whiskData_C1 - whiskSTD_C1)
title('Mean 0.5 to 2')
xlabel('Peri-whisk time (sec)')
ylabel('\Delta Diameter (%)')

ax5 = subplot(3,3,5);
plot(timeVec, whiskData_C2, 'k')
hold on
plot(timeVec, whiskData_C2 + whiskSTD_C2)
plot(timeVec, whiskData_C2 - whiskSTD_C2)
title('Mean 2 to 5')
xlabel('Peri-whisk time (sec)')
ylabel('\Delta Diameter (%)')

ax6 = subplot(3,3,6);
plot(timeVec, whiskData_C3, 'k')
hold on
plot(timeVec, whiskData_C3 + whiskSTD_C3)
plot(timeVec, whiskData_C3 - whiskSTD_C3)
title('Mean 5 to 10')
xlabel('Peri-whisk time (sec)')
ylabel('\Delta Diameter (%)')
linkaxes([ax4 ax5 ax6], 'xy')

%%
subplot(3,3,7);
imagesc(T,F,whiskLFP_C1);
axis xy
caxis([-.5 0.75])
ylim([1 100])
title('Mean 0.5 to 2')
ylabel('Frequency (Hz)')
xlabel('Peri-whisk time (sec)')

subplot(3,3,8);
imagesc(T,F,whiskLFP_C2);
axis xy
caxis([-.5 0.75])
ylim([1 100])
title('Mean 2 to 5')
ylabel('Frequency (Hz)')
xlabel('Peri-whisk time (sec)')

subplot(3,3,9);
imagesc(T,F,whiskLFP_C3);
axis xy
caxis([-.5 0.75])
ylim([1 100])
title('Mean 5 to 10')
ylabel('Frequency (Hz)')
xlabel('Peri-whisk time (sec)')

end