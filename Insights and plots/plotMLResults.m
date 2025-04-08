%% Get results
addpath('/ess/p697/cluster/users/parekh/software/tight_subplot');

%% Define colours
col_SVM   = [231,41,138]./255;
col_RUS   = [217,95,2]./255;
col_SMOTE = [117,112,179]./255;
col_perm  = [150 150 150]./255;
col_line  = [102,166,30]./255;

%% Additional settings
jitter       = 'on';
jitterAmount = 0.15;
marker_RUS   = 'o';
marker_SVM   = '^';
marker_SMOTE = '>';
marker_perm  = 'x';
marker_size  = 10;
fontsize_sens = 7;

%% Where to plot
ticks = 1:2:10;
xloc1 = ticks - 0.45;
xloc2 = ticks;
xloc3 = ticks + 0.45;

%% Get results
load('/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/work/2024-12-20_compiledMLResults_unimodal.mat');

%% Model names
% https://www.mathworks.com/matlabcentral/answers/101922-how-do-i-create-a-multi-line-tick-label-for-a-figure-using-matlab-7-10-r2010a#answer_445691
% mdlNames = {'Psychotic experiences', 'General mental health', ...
%             'Polygenic risk scores', 'Family & childhood diagnoses', ...
%             'Birth factors'};
mdlNames = cell(5, 1);
row1     = {'Psychotic',  'General',        'Polygenic',   'Family and',           'Birth'};
row2     = {'experiences', 'mental health', 'risk scores', 'childhood diagnoses', 'factors'};

for rr = 1:5
    mdlNames{rr} = sprintf([pad(row1{rr}, length(row2{rr}), 'both'), '\n', row2{rr}]);
end

% % Pad row 1
% for rr = 1:5
%     row1{rr} = pad(row1{rr}, length(row2{rr}), 'both');
% end
% 
% 
% labelArray = [row1; row2];
% 
% mdlNames  = strtrim(sprintf('%s\\newline%s\n', labelArray{:}));

%% Legend entries
legendNames = {'RUSBoost', 'SMOTE-SVM', 'SVM', 'Permutation accuracy'};
maxLen      = max(cellfun(@length, legendNames));
for rr = 1:4
    legendNames{rr} = pad(legendNames{rr}, maxLen, 'right');
end

% %% Prepare data to plot
% % Order of results: CAPE, Q14, Genetics, NPR, MBRN
% results_RUS = [mean(RUS_CAPE.test_balAccuracy)',     mean(RUS_Q14.test_balAccuracy)', ...
%                mean(RUS_Genetics.test_balAccuracy)', mean(RUS_NPR.test_balAccuracy)', ...
%                mean(RUS_MBRN.test_balAccuracy)'] .* 100;
% 
% results_SVM = [mean(SVM_balAcc_CAPE.test_balAccuracy)',     mean(SVM_balAcc_Q14.test_balAccuracy)', ...
%                mean(SVM_balAcc_Genetics.test_balAccuracy)', mean(SVM_balAcc_NPR.test_balAccuracy)', ...
%                mean(SVM_balAcc_MBRN.test_balAccuracy)'] .* 100;
% 
% perm_results_RUS = [mean(RUS_CAPE.perm_test_balAccuracy)',     mean(RUS_Q14.perm_test_balAccuracy)', ...
%                     mean(RUS_Genetics.perm_test_balAccuracy)', mean(RUS_NPR.perm_test_balAccuracy)', ...
%                     mean(RUS_MBRN.perm_test_balAccuracy)'] .* 100;
% 
% perm_results_SVM = [mean(SVM_balAcc_CAPE.perm_test_balAccuracy)',     mean(SVM_balAcc_Q14.perm_test_balAccuracy)', ...
%                     mean(SVM_balAcc_Genetics.perm_test_balAccuracy)', mean(SVM_balAcc_NPR.perm_test_balAccuracy)', ...
%                     mean(SVM_balAcc_MBRN.perm_test_balAccuracy)'] .* 100;
% 
% sensitivity_RUS = [mean(RUS_CAPE.test_sensitivity)',     mean(RUS_Q14.test_sensitivity)', ...
%                mean(RUS_Genetics.test_sensitivity)', mean(RUS_NPR.test_sensitivity)', ...
%                mean(RUS_MBRN.test_sensitivity)'] .* 100;
% 
% sensitivity_SVM = [mean(SVM_balAcc_CAPE.test_sensitivity)',     mean(SVM_balAcc_Q14.test_sensitivity)', ...
%                mean(SVM_balAcc_Genetics.test_sensitivity)', mean(SVM_balAcc_NPR.test_sensitivity)', ...
%                mean(SVM_balAcc_MBRN.test_sensitivity)'] .* 100;
% 
% specificity_RUS = [mean(RUS_CAPE.test_specificity)',     mean(RUS_Q14.test_specificity)', ...
%                mean(RUS_Genetics.test_specificity)', mean(RUS_NPR.test_specificity)', ...
%                mean(RUS_MBRN.test_specificity)'] .* 100;
% 
% specificity_SVM = [mean(SVM_balAcc_CAPE.test_specificity)',     mean(SVM_balAcc_Q14.test_specificity)', ...
%                mean(SVM_balAcc_Genetics.test_specificity)', mean(SVM_balAcc_NPR.test_specificity)', ...
%                mean(SVM_balAcc_MBRN.test_specificity)'] .* 100;

%% Set up figure
fig  = figure('Units', 'centimeters', 'Position', [10 10 17 12]);
allH = tight_subplot(1, 1, 0, [0.17 0.02], [0.085 0.01]);
hold(allH(1), 'on');

% Plot results - balanced accuracy
for res = 1:5
    scatter(allH(1), repmat(xloc1(res), 50,  1), test_balAccuracy_RUS(:,res) .* 100,     marker_size, col_RUS,  'filled', marker_RUS,  'jitter', jitter, 'jitterAmount', jitterAmount);
    scatter(allH(1), repmat(xloc1(res), 100, 1), perm_test_balAccuracy_RUS(:,res) .*100, marker_size, col_perm, 'filled', marker_perm, 'jitter', jitter, 'jitterAmount', jitterAmount, 'MarkerEdgeColor', col_perm, 'LineWidth', 1);

    scatter(allH(1), repmat(xloc2(res), 50,  1), test_balAccuracy_SMOTE_SVM(:,res) .* 100,     marker_size, col_SMOTE, 'filled', marker_SMOTE, 'jitter', jitter, 'jitterAmount', jitterAmount);
    scatter(allH(1), repmat(xloc2(res), 100, 1), perm_test_balAccuracy_SMOTE_SVM(:,res) .*100, marker_size, col_perm,  'filled', marker_perm,  'jitter', jitter, 'jitterAmount', jitterAmount, 'MarkerEdgeColor', col_perm, 'LineWidth', 1);

    scatter(allH(1), repmat(xloc3(res), 50,  1), test_balAccuracy_SVM_balAcc(:,res) .* 100,     marker_size, col_SVM,  'filled', marker_SVM,  'jitter', jitter, 'jitterAmount', jitterAmount);
    scatter(allH(1), repmat(xloc3(res), 100, 1), perm_test_balAccuracy_SVM_balAcc(:,res) .*100, marker_size, col_perm, 'filled', marker_perm, 'jitter', jitter, 'jitterAmount', jitterAmount, 'MarkerEdgeColor', col_perm, 'LineWidth', 1);
end

% Add mean performances
for res = 1:5
    plot(allH(1), [xloc1(res)-jitterAmount, xloc1(res)+jitterAmount], repmat(mean(test_balAccuracy_RUS(:,res) .* 100), 2, 1),      'LineWidth', 3, 'Color', col_line);
    plot(allH(1), [xloc2(res)-jitterAmount, xloc2(res)+jitterAmount], repmat(mean(test_balAccuracy_SMOTE_SVM(:,res) .* 100), 2, 1), 'LineWidth', 3, 'Color', col_line);
    plot(allH(1), [xloc3(res)-jitterAmount, xloc3(res)+jitterAmount], repmat(mean(test_balAccuracy_SVM_balAcc(:,res) .* 100), 2, 1), 'LineWidth', 3, 'Color', col_line);
end

% Add vertical lines to separate models
for res = 1:4
    plot(allH(1), repmat(ticks(res)+1, 11, 1), 0:10:100, 'LineStyle', '--', 'LineWidth', 1, 'Color', 'k');
end

% Add mean performance text
for res = 1:5
    text(allH(1), ticks(res), 95, [num2str(mean(test_balAccuracy_RUS(:,res).*100), '%05.2f'), ' ± ', num2str(std(test_balAccuracy_RUS(:,res) .*100), '%05.2f')], 'HorizontalAlignment', 'center', 'FontSize', 9, 'Color', col_RUS);
    text(allH(1), ticks(res), 90, [num2str(mean(test_balAccuracy_SMOTE_SVM(:,res).*100), '%05.2f'), ' ± ', num2str(std(test_balAccuracy_SMOTE_SVM(:,res).*100), '%05.2f')], 'HorizontalAlignment', 'center', 'FontSize', 9, 'Color', col_SMOTE);
    text(allH(1), ticks(res), 85, [num2str(mean(test_balAccuracy_SVM_balAcc(:,res).*100), '%05.2f'), ' ± ', num2str(std(test_balAccuracy_SVM_balAcc(:,res).*100), '%05.2f')], 'HorizontalAlignment', 'center', 'FontSize', 9, 'Color', col_SVM);
end

% Add sensitivity and specificity text
for res = 1:5
    text(allH(1), ticks(res), 30, ['Sens: ', num2str(mean(test_sensitivity_RUS(:,res) .* 100), '%05.2f'), ' ± ', num2str(std(test_sensitivity_RUS(:,res) .* 100), '%05.2f')], 'HorizontalAlignment', 'center', 'FontSize', fontsize_sens, 'Color', col_RUS);
    text(allH(1), ticks(res), 25, ['Spec: ', num2str(mean(test_specificity_RUS(:,res) .* 100), '%05.2f'), ' ± ', num2str(std(test_specificity_RUS(:,res) .* 100), '%05.2f')], 'HorizontalAlignment', 'center', 'FontSize', fontsize_sens, 'Color', col_RUS);

    text(allH(1), ticks(res), 20, ['Sens: ', num2str(mean(test_sensitivity_SMOTE_SVM(:,res) .* 100), '%05.2f'), ' ± ', num2str(std(test_sensitivity_SMOTE_SVM(:,res) .* 100), '%05.2f')], 'HorizontalAlignment', 'center', 'FontSize', fontsize_sens, 'Color', col_SMOTE);
    text(allH(1), ticks(res), 15, ['Spec: ', num2str(mean(test_specificity_SMOTE_SVM(:,res) .* 100), '%05.2f'), ' ± ', num2str(std(test_specificity_SMOTE_SVM(:,res) .* 100), '%05.2f')], 'HorizontalAlignment', 'center', 'FontSize', fontsize_sens, 'Color', col_SMOTE);

    text(allH(1), ticks(res), 10, ['Sens: ', num2str(mean(test_sensitivity_SVM_balAcc(:,res) .* 100), '%05.2f'), ' ± ', num2str(std(test_sensitivity_SVM_balAcc(:,res) .* 100), '%05.2f')], 'HorizontalAlignment', 'center', 'FontSize', fontsize_sens, 'Color', col_SVM);
    text(allH(1), ticks(res), 05, ['Spec: ', num2str(mean(test_specificity_SVM_balAcc(:,res) .* 100), '%05.2f'), ' ± ', num2str(std(test_specificity_SVM_balAcc(:,res) .* 100), '%05.2f')], 'HorizontalAlignment', 'center', 'FontSize', fontsize_sens, 'Color', col_SVM);
end

% Modify x axis
allH(1).XLim                    = [0 10];
allH(1).XTick                   = ticks;
allH(1).XAxis.TickLength        = [0 0];

% Add x tick labels
for res = 1:5
    text(allH(1), ticks(res), -7, mdlNames{res}, 'HorizontalAlignment', 'center', 'FontSize', 10, 'FontWeight', 'normal');
end

% Modify y axis
allH(1).YLim           = [0 100];
allH(1).YTick          = 0:10:100;
allH(1).YTickLabel     = 0:10:100;
allH(1).YLabel.String  = 'Balanced accuracy (%)';
allH(1).YAxis.FontSize = 10;

% Plot dummies
a1 = plot(allH(1), NaN, NaN, 'MarkerSize', 50, 'MarkerFaceColor',  col_RUS,  'Marker', marker_RUS, 'MarkerEdgeColor', col_RUS,  'LineStyle', 'none');
a2 = plot(allH(1), NaN, NaN, 'MarkerSize', 50, 'MarkerFaceColor',  col_SMOTE,  'Marker', marker_SMOTE, 'MarkerEdgeColor', col_SMOTE,  'LineStyle', 'none');
a3 = plot(allH(1), NaN, NaN, 'MarkerSize', 50, 'MarkerFaceColor',  col_SVM,  'Marker', marker_SVM, 'MarkerEdgeColor', col_SVM,  'LineStyle', 'none');
a4 = plot(allH(1), NaN, NaN, 'MarkerSize', 100, 'MarkerFaceColor', col_perm, 'Marker', marker_perm, 'MarkerEdgeColor', col_perm, 'LineStyle', 'none', 'LineWidth', 2);

% Create legend
ll = legend(allH(1), [a1, a2, a3, a4], legendNames, ...
            'Location', 'southoutside', 'Orientation', 'horizontal', 'FontSize', 10);
ll.Position(2) = ll.Position(2) - 0.17;
ll.Box = 'off';

% Set font for entire figure
% allH(1).FontName = 'AvenirHeavy';

%% Save
print('/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/work/Results_allML_unimodal.png', '-dpng', '-r900');
close(fig);