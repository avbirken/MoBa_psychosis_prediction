insightsDir = '/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/insights';
resCAPE     = load(fullfile(insightsDir, 'insights_CAPE.mat'), 'whenPsychosis_firstOnset', 'always_TP', 'always_FN');
resQ14      = load(fullfile(insightsDir, 'insights_Q14.mat'), 'whenPsychosis_firstOnset', 'always_TP', 'always_FN');
resNPR      = load(fullfile(insightsDir, 'insights_NPR.mat'), 'whenPsychosis_firstOnset', 'always_TP', 'always_FN');
resMBRN     = load(fullfile(insightsDir, 'insights_MBRN.mat'), 'whenPsychosis_firstOnset', 'always_TP', 'always_FN');
resGenetics = load(fullfile(insightsDir, 'insights_Genetics.mat'), 'whenPsychosis_firstOnset', 'always_TP', 'always_FN');

%% Make plots
doPlot(resCAPE.whenPsychosis_firstOnset, resCAPE.always_TP, resCAPE.always_FN, 'CAPE', fullfile(insightsDir, 'CAPE_TP_FN.png'));
doPlot(resQ14.whenPsychosis_firstOnset, resQ14.always_TP, resQ14.always_FN, 'Q14', fullfile(insightsDir, 'Q14_TP_FN.png'));
doPlot(resNPR.whenPsychosis_firstOnset, resNPR.always_TP, resNPR.always_FN, 'NPR', fullfile(insightsDir, 'NPR_TP_FN.png'));
doPlot(resMBRN.whenPsychosis_firstOnset, resMBRN.always_TP, resMBRN.always_FN, 'MBRN', fullfile(insightsDir, 'MBRN_TP_FN.png'));
doPlot(resGenetics.whenPsychosis_firstOnset, resGenetics.always_TP, resGenetics.always_FN, 'Genetics', fullfile(insightsDir, 'Genetics_TP_FN.png'));

%% Overall histogram of age of onset
fig = figure('Units', 'centimeters', 'Position', [10 10 14 10]);
histogram(categorical([resNPR.whenPsychosis_firstOnset{:,end}]));
box('off');
xtickangle(0);
title('Age of onset: NPR sample');
print(fullfile(insightsDir, 'AgeofOnset.png'), '-dpng', '-r600');
close(fig);

function doPlot(whenPsychosis_firstOnset, always_TP, always_FN, str, outName)
    ages_TP = [whenPsychosis_firstOnset{ismember(whenPsychosis_firstOnset(:,1), always_TP(:,1)),4}]';
    ages_FN = [whenPsychosis_firstOnset{ismember(whenPsychosis_firstOnset(:,1), always_FN(:,1)),4}]';
    allAges = [whenPsychosis_firstOnset{:,4}]';
    
    % Create stacked info
    uqInfo  = unique(allAges);
    resInfo = zeros(length(uqInfo),4);
    for ii  = 1:length(uqInfo)
        resInfo(ii,1) = uqInfo(ii);
        resInfo(ii,2) = sum(allAges == uqInfo(ii));
        resInfo(ii,3) = sum(ages_TP == uqInfo(ii));
        resInfo(ii,4) = sum(ages_FN == uqInfo(ii));
    end
    fig = figure('Units', 'centimeters', 'Position', [10 10 10 10]);
    bar(resInfo(:,1), resInfo(:,3:end), 'stacked');
    legend({'TP', 'FN'}, 'Box', 'off');
    box('off');
    title(str);
    print(outName, '-dpng', '-r600');
    close(fig);
end