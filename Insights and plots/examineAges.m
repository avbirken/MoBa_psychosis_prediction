%% Examine age of cutoff
addpath('/ess/p697/cluster/users/parekh/software/tight_subplot');
dataAll = readtable('/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/work/IDList_ParentID_cutoffInfo.csv');

fig  = figure('Units', 'centimeters', 'Position', [10 10 20 16]);
allH = tight_subplot(2, 2, [0.12 0.06], [0.08 0.04], [0.06 0.01]);

% Figure 1: age of cutoff predictor: only cases
histogram(allH(1), dataAll.cutoff_predictor(dataAll.caseStatus == 1), 'FaceColor', [217,95,2]./255);
box(allH(1), 'off');
allH(1).XAxis.Label.String = 'Age in days at predictor cutoff';
allH(1).Title.String = 'Only cases';

% Figure 2: age of cutoff predictor - year
histogram(allH(2), categorical(round(dataAll.cutoff_predictor(dataAll.caseStatus == 1)/365)), 'FaceColor', [217,95,2]./255);
box(allH(2), 'off');
allH(2).XAxis.Label.String = 'Age in years at predictor cutoff';
allH(2).Title.String = 'Only cases';

% Figure 3: age of cutoff predictor: only controls
histogram(allH(3), dataAll.cutoff_predictor(dataAll.caseStatus == 0), 'FaceColor', [27,158,119]./255);
box(allH(3), 'off');
allH(3).XAxis.Label.String = 'Age in days at predictor cutoff';
allH(3).Title.String = 'Only controls';

% Figure 4: age of cutoff predictor - year
histogram(allH(4), categorical(round(dataAll.cutoff_predictor(dataAll.caseStatus == 0)/365)), 'FaceColor', [27,158,119]./255);
box(allH(4), 'off');
allH(4).XAxis.Label.String = 'Age in years at predictor cutoff';
allH(4).Title.String = 'Only controls';

print('/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/insights/Age_Cutoff.png', '-dpng', '-r600');
close(fig);

%% Examine age of onset
data    = readtable('/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/source/2024-12-20_AgeofOnset.csv');

fig  = figure('Units', 'centimeters', 'Position', [10 10 22 10]);
allH = tight_subplot(1, 3, [0.0 0.04], [0.08 0.06], [0.06 0.01]);

% Figure 1: age of onset in days
histogram(allH(1), data.whenPsychosis_any_diff, 'FaceColor', [217,95,2]./255);
box(allH(1), 'off');
allH(1).Title.String = 'Age of onset in days';

% Figure 2: age of onset in years
histogram(allH(2), categorical(round(data.whenPsychosis_any_diff/365)), 'FaceColor', [217,95,2]./255);
box(allH(2), 'off');
allH(2).Title.String = 'Age of onset in years';
allH(2).XTickLabelRotation = 0;

% Figure 3: days since cutoff
histogram(allH(3), data.whenPsychosis_any_diff - data.cutoff_predictor, 'FaceColor', [217,95,2]./255);
box(allH(3), 'off');
allH(3).Title.String = 'Days since cutoff to diagnosis';

print('/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/insights/Age_Diagnosis.png', '-dpng', '-r600');
close(fig);