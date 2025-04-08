%% Get results
addpath('/ess/p697/cluster/users/parekh/software/tight_subplot');

%% Define colours
col_RUS   = [85,94,133]./255;
col_SMOTE = [66,162,193]./255;
col_SVM   = [208,46,32]./255;
col_perm  = [199,200,200]./255;
col_line  = [0, 0,0]./255;

%% New colours
%col_RUS   = [78,91,66]./255;
%col_SMOTE = [33,19,154]./255;
%col_SVM   = [147,47,36]./255;
%col_perm  = [199,200,200]./255;
%col_line  = [153,125,124]./255;

%% Additional settings
jitter       = 'on';
jitterAmount = 0.16;
marker_RUS   = 'o';
marker_SVM   = 'o';
marker_SMOTE = 'o';
marker_perm  = 'x';
marker_size  = 10;
fontsize_sens = 7;

%% Where to plot
ticks = 1:2:14;
xloc1 = ticks - 0.45;
xloc2 = ticks;
xloc3 = ticks + 0.45;

%% Get results
workDir = '/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/work/analysis_fuse_RUS';

% Only plotting the following scenarios: CAPE + Q14 and CAPE + Q14 + NPR
res_bimodal  = load(fullfile(workDir, 'Results_fuse_RUS_CAPE_Q14.mat'));
res_trimodal = load(fullfile(workDir, 'Results_fuse_RUS_CAPE_Q14_NPR.mat'));

%% Model names
% https://www.mathworks.com/matlabcentral/answers/101922-how-do-i-create-a-multi-line-tick-label-for-a-figure-using-matlab-7-10-r2010a#answer_445691
% mdlNames = {'Psychotic experiences', 'General mental health', ...
%             'Polygenic risk scores', 'Family & childhood diagnoses', ...
%             'Birth factors'};
mdlNames = cell(3, 1);
row1     = {'Psychotic',  'General',        'Parent and'};
row2     = {'experiences', 'mental health', 'childhood diagnoses'};

for rr = 1:3
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

% %% Legend entries
% legendNames = {'RUSBoost', 'SMOTE-SVM', 'SVM', 'Permutation accuracy'};
% maxLen      = max(cellfun(@length, legendNames));
% for rr = 1:4
%     legendNames{rr} = pad(legendNames{rr}, maxLen, 'right');
% end

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

% Bimodal
% Model 1: CAPE alone
res = 1;
scatter(allH(1), repmat(xloc1(res), 50,  1), res_bimodal.mean_testBalAccuracy_1 .* 100,     marker_size, col_RUS,  'filled', marker_RUS,  'jitter', jitter, 'jitterAmount', jitterAmount);
scatter(allH(1), repmat(xloc1(res), 100, 1), res_bimodal.perm_mean_testBalAccuracy_1 .*100, marker_size, col_perm, 'filled', marker_perm, 'jitter', jitter, 'jitterAmount', jitterAmount, 'MarkerEdgeColor', col_perm, 'LineWidth', 1);

% Model 2: Q14 alone
res = 2;
scatter(allH(1), repmat(xloc1(res), 50,  1), res_bimodal.mean_testBalAccuracy_2 .* 100,     marker_size, col_RUS,  'filled', marker_RUS,  'jitter', jitter, 'jitterAmount', jitterAmount);
scatter(allH(1), repmat(xloc1(res), 100, 1), res_bimodal.perm_mean_testBalAccuracy_2 .*100, marker_size, col_perm, 'filled', marker_perm, 'jitter', jitter, 'jitterAmount', jitterAmount, 'MarkerEdgeColor', col_perm, 'LineWidth', 1);

% Model 3: CAPE + Q14: bimodal
res = 3;
scatter(allH(1), repmat(xloc1(res), 50,  1), res_bimodal.mean_testBalAccuracy_F .* 100,     marker_size, col_RUS,  'filled', marker_SVM,  'jitter', jitter, 'jitterAmount', jitterAmount);
scatter(allH(1), repmat(xloc1(res), 100, 1), res_bimodal.perm_mean_testBalAccuracy_F .*100, marker_size, col_perm, 'filled', marker_perm, 'jitter', jitter, 'jitterAmount', jitterAmount, 'MarkerEdgeColor', col_perm, 'LineWidth', 1);

% Add mean performances
res = 1;
plot(allH(1), [xloc1(res)-jitterAmount, xloc1(res)+jitterAmount], repmat(mean(res_bimodal.mean_testBalAccuracy_1 .* 100), 2, 1), 'LineWidth', 1, 'Color', col_line);
res = 2;
plot(allH(1), [xloc2(res)-jitterAmount, xloc2(res)+jitterAmount], repmat(mean(res_bimodal.mean_testBalAccuracy_2 .* 100), 2, 1), 'LineWidth', 1, 'Color', col_line);
res = 3;
plot(allH(1), [xloc3(res)-jitterAmount, xloc3(res)+jitterAmount], repmat(mean(res_bimodal.mean_testBalAccuracy_F .* 100), 2, 1), 'LineWidth', 1, 'Color', col_line);

% Add mean performance text
res = 1;
text(allH(1), ticks(res), 95, [num2str(mean(res_bimodal.mean_testBalAccuracy_1 .* 100), '%05.2f'), ' ± ', num2str(std(res_bimodal.mean_testBalAccuracy_1 .*100), '%05.2f')], 'HorizontalAlignment', 'center', 'FontSize', 9, 'Color', col_RUS);
res = 2;
text(allH(1), ticks(res), 95, [num2str(mean(res_bimodal.mean_testBalAccuracy_2 .* 100), '%05.2f'), ' ± ', num2str(std(res_bimodal.mean_testBalAccuracy_2 .*100), '%05.2f')], 'HorizontalAlignment', 'center', 'FontSize', 9, 'Color', col_RUS);
res = 3;
text(allH(1), ticks(res), 95, [num2str(mean(res_bimodal.mean_testBalAccuracy_F .* 100), '%05.2f'), ' ± ', num2str(std(res_bimodal.mean_testBalAccuracy_F .*100), '%05.2f')], 'HorizontalAlignment', 'center', 'FontSize', 9, 'Color', col_SVM);

% Add sensitivity and specificity text
res = 1;
text(allH(1), ticks(res), 30, ['Sens: ', num2str(mean(res_bimodal.mean_testSensitivity_1 .* 100), '%05.2f'), ' ± ', num2str(std(res_bimodal.mean_testSensitivity_1 .* 100), '%05.2f')], 'HorizontalAlignment', 'center', 'FontSize', fontsize_sens, 'Color', col_RUS);
text(allH(1), ticks(res), 25, ['Spec: ', num2str(mean(res_bimodal.mean_testSpecificity_1 .* 100), '%05.2f'), ' ± ', num2str(std(res_bimodal.mean_testSpecificity_1 .* 100), '%05.2f')], 'HorizontalAlignment', 'center', 'FontSize', fontsize_sens, 'Color', col_RUS);

res = 2;
text(allH(1), ticks(res), 30, ['Sens: ', num2str(mean(res_bimodal.mean_testSensitivity_2 .* 100), '%05.2f'), ' ± ', num2str(std(res_bimodal.mean_testSensitivity_2 .* 100), '%05.2f')], 'HorizontalAlignment', 'center', 'FontSize', fontsize_sens, 'Color', col_RUS);
text(allH(1), ticks(res), 25, ['Spec: ', num2str(mean(res_bimodal.mean_testSpecificity_2 .* 100), '%05.2f'), ' ± ', num2str(std(res_bimodal.mean_testSpecificity_2 .* 100), '%05.2f')], 'HorizontalAlignment', 'center', 'FontSize', fontsize_sens, 'Color', col_RUS);

res = 3;
text(allH(1), ticks(res), 30, ['Sens: ', num2str(mean(res_bimodal.mean_testSensitivity_F .* 100), '%05.2f'), ' ± ', num2str(std(res_bimodal.mean_testSensitivity_F .* 100), '%05.2f')], 'HorizontalAlignment', 'center', 'FontSize', fontsize_sens, 'Color', col_SVM);
text(allH(1), ticks(res), 25, ['Spec: ', num2str(mean(res_bimodal.mean_testSpecificity_F .* 100), '%05.2f'), ' ± ', num2str(std(res_bimodal.mean_testSpecificity_F .* 100), '%05.2f')], 'HorizontalAlignment', 'center', 'FontSize', fontsize_sens, 'Color', col_SVM);

%% Add vertical line to separate trimodal
res = 3;
plot(allH(1), repmat(ticks(res)+1, 11, 1), 0:10:100, 'LineStyle', '--', 'LineWidth', 0.3, 'Color', 'k');

% Trimodal now
% Model 1: CAPE alone
res = 4;
scatter(allH(1), repmat(xloc1(res), 50,  1), res_trimodal.mean_testBalAccuracy_1 .* 100,     marker_size, col_RUS,  'filled', marker_RUS,  'jitter', jitter, 'jitterAmount', jitterAmount);
scatter(allH(1), repmat(xloc1(res), 100, 1), res_trimodal.perm_mean_testBalAccuracy_1 .*100, marker_size, col_perm, 'filled', marker_perm, 'jitter', jitter, 'jitterAmount', jitterAmount, 'MarkerEdgeColor', col_perm, 'LineWidth', 1);

% Model 2: Q14 alone
res = 5;
scatter(allH(1), repmat(xloc1(res), 50,  1), res_trimodal.mean_testBalAccuracy_2 .* 100,     marker_size, col_RUS,  'filled', marker_RUS,  'jitter', jitter, 'jitterAmount', jitterAmount);
scatter(allH(1), repmat(xloc1(res), 100, 1), res_trimodal.perm_mean_testBalAccuracy_2 .*100, marker_size, col_perm, 'filled', marker_perm, 'jitter', jitter, 'jitterAmount', jitterAmount, 'MarkerEdgeColor', col_perm, 'LineWidth', 1);

% Model 3: NPR alone
res = 6;
scatter(allH(1), repmat(xloc1(res), 50,  1), res_trimodal.mean_testBalAccuracy_3 .* 100,     marker_size, col_RUS,  'filled', marker_RUS,  'jitter', jitter, 'jitterAmount', jitterAmount);
scatter(allH(1), repmat(xloc1(res), 100, 1), res_trimodal.perm_mean_testBalAccuracy_3 .*100, marker_size, col_perm, 'filled', marker_perm, 'jitter', jitter, 'jitterAmount', jitterAmount, 'MarkerEdgeColor', col_perm, 'LineWidth', 1);

% Model 3: CAPE + Q14 + NPR: trimodal
res = 7;
scatter(allH(1), repmat(xloc1(res), 50,  1), res_trimodal.mean_testBalAccuracy_F .* 100,     marker_size, col_RUS,  'filled', marker_RUS,  'jitter', jitter, 'jitterAmount', jitterAmount);
scatter(allH(1), repmat(xloc1(res), 100, 1), res_trimodal.perm_mean_testBalAccuracy_F .*100, marker_size, col_perm, 'filled', marker_perm, 'jitter', jitter, 'jitterAmount', jitterAmount, 'MarkerEdgeColor', col_perm, 'LineWidth', 1);

% Add mean performances
res = 4;
plot(allH(1), [xloc1(res)-jitterAmount, xloc1(res)+jitterAmount], repmat(mean(res_trimodal.mean_testBalAccuracy_1 .* 100), 2, 1), 'LineWidth', 1, 'Color', col_line);
res = 5;
plot(allH(1), [xloc2(res)-jitterAmount, xloc2(res)+jitterAmount], repmat(mean(res_trimodal.mean_testBalAccuracy_2 .* 100), 2, 1), 'LineWidth', 1, 'Color', col_line);
res = 6;
plot(allH(1), [xloc3(res)-jitterAmount, xloc3(res)+jitterAmount], repmat(mean(res_trimodal.mean_testBalAccuracy_3 .* 100), 2, 1), 'LineWidth', 1, 'Color', col_line);
res = 7;
plot(allH(1), [xloc3(res)-jitterAmount, xloc3(res)+jitterAmount], repmat(mean(res_trimodal.mean_testBalAccuracy_F .* 100), 2, 1), 'LineWidth', 1, 'Color', col_line);

% Add mean performance text
res = 4;
text(allH(1), ticks(res), 95, [num2str(mean(res_trimodal.mean_testBalAccuracy_1 .* 100), '%05.2f'), ' ± ', num2str(std(res_trimodal.mean_testBalAccuracy_1 .*100), '%05.2f')], 'HorizontalAlignment', 'center', 'FontSize', 9, 'Color', col_RUS);
res = 5;
text(allH(1), ticks(res), 95, [num2str(mean(res_trimodal.mean_testBalAccuracy_2 .* 100), '%05.2f'), ' ± ', num2str(std(res_trimodal.mean_testBalAccuracy_2 .*100), '%05.2f')], 'HorizontalAlignment', 'center', 'FontSize', 9, 'Color', col_RUS);
res = 6;
text(allH(1), ticks(res), 95, [num2str(mean(res_trimodal.mean_testBalAccuracy_3 .* 100), '%05.2f'), ' ± ', num2str(std(res_trimodal.mean_testBalAccuracy_3 .*100), '%05.2f')], 'HorizontalAlignment', 'center', 'FontSize', 9, 'Color', col_RUS);
res = 7;
text(allH(1), ticks(res), 95, [num2str(mean(res_trimodal.mean_testBalAccuracy_F .* 100), '%05.2f'), ' ± ', num2str(std(res_trimodal.mean_testBalAccuracy_F .*100), '%05.2f')], 'HorizontalAlignment', 'center', 'FontSize', 9, 'Color', col_RUS);

% Add sensitivity and specificity text
res = 4;
text(allH(1), ticks(res), 30, ['Sens: ', num2str(mean(res_trimodal.mean_testSensitivity_1 .* 100), '%05.2f'), ' ± ', num2str(std(res_trimodal.mean_testSensitivity_1 .* 100), '%05.2f')], 'HorizontalAlignment', 'center', 'FontSize', fontsize_sens, 'Color', col_RUS);
text(allH(1), ticks(res), 25, ['Spec: ', num2str(mean(res_trimodal.mean_testSpecificity_1 .* 100), '%05.2f'), ' ± ', num2str(std(res_trimodal.mean_testSpecificity_1 .* 100), '%05.2f')], 'HorizontalAlignment', 'center', 'FontSize', fontsize_sens, 'Color', col_RUS);

res = 5;
text(allH(1), ticks(res), 30, ['Sens: ', num2str(mean(res_trimodal.mean_testSensitivity_2 .* 100), '%05.2f'), ' ± ', num2str(std(res_trimodal.mean_testSensitivity_2 .* 100), '%05.2f')], 'HorizontalAlignment', 'center', 'FontSize', fontsize_sens, 'Color', col_RUS);
text(allH(1), ticks(res), 25, ['Spec: ', num2str(mean(res_trimodal.mean_testSpecificity_2 .* 100), '%05.2f'), ' ± ', num2str(std(res_trimodal.mean_testSpecificity_2 .* 100), '%05.2f')], 'HorizontalAlignment', 'center', 'FontSize', fontsize_sens, 'Color', col_RUS);

res = 6;
text(allH(1), ticks(res), 30, ['Sens: ', num2str(mean(res_trimodal.mean_testSensitivity_3 .* 100), '%05.2f'), ' ± ', num2str(std(res_trimodal.mean_testSensitivity_3 .* 100), '%05.2f')], 'HorizontalAlignment', 'center', 'FontSize', fontsize_sens, 'Color', col_RUS);
text(allH(1), ticks(res), 25, ['Spec: ', num2str(mean(res_trimodal.mean_testSpecificity_3 .* 100), '%05.2f'), ' ± ', num2str(std(res_trimodal.mean_testSpecificity_3 .* 100), '%05.2f')], 'HorizontalAlignment', 'center', 'FontSize', fontsize_sens, 'Color', col_RUS);

res = 7;
text(allH(1), ticks(res), 30, ['Sens: ', num2str(mean(res_trimodal.mean_testSensitivity_F .* 100), '%05.2f'), ' ± ', num2str(std(res_trimodal.mean_testSensitivity_F .* 100), '%05.2f')], 'HorizontalAlignment', 'center', 'FontSize', fontsize_sens, 'Color', col_RUS);
text(allH(1), ticks(res), 25, ['Spec: ', num2str(mean(res_trimodal.mean_testSpecificity_F .* 100), '%05.2f'), ' ± ', num2str(std(res_trimodal.mean_testSpecificity_F .* 100), '%05.2f')], 'HorizontalAlignment', 'center', 'FontSize', fontsize_sens, 'Color', col_RUS);

% Modify x axis
allH(1).XLim                    = [0 13];
allH(1).XTick                   = ticks;
allH(1).XAxis.TickLength        = [0 0];

% % Add x tick labels
% for res = 1:5
%     text(allH(1), ticks(res), -7, mdlNames{res}, 'HorizontalAlignment', 'center', 'FontSize', 8.5, 'FontWeight', 'normal');
% end

% Modify y axis
allH(1).YLim           = [0 100];
allH(1).YTick          = 0:10:100;
allH(1).YTickLabel     = 0:10:100;
allH(1).YLabel.String  = 'Balanced accuracy (%)';
allH(1).YAxis.FontSize = 9;

%% Plot dummies
a1 = plot(allH(1), NaN, NaN, 'MarkerSize', 50, 'MarkerFaceColor',  col_RUS,  'Marker', marker_RUS, 'MarkerEdgeColor', col_RUS,  'LineStyle', 'none');
a2 = plot(allH(1), NaN, NaN, 'MarkerSize', 50, 'MarkerFaceColor',  col_SMOTE,  'Marker', marker_SMOTE, 'MarkerEdgeColor', col_SMOTE,  'LineStyle', 'none');
a3 = plot(allH(1), NaN, NaN, 'MarkerSize', 50, 'MarkerFaceColor',  col_SVM,  'Marker', marker_SVM, 'MarkerEdgeColor', col_SVM,  'LineStyle', 'none');
a4 = plot(allH(1), NaN, NaN, 'MarkerSize', 100, 'MarkerFaceColor', col_perm, 'Marker', marker_perm, 'MarkerEdgeColor', col_perm, 'LineStyle', 'none', 'LineWidth', 2);

% Create legend
ll = legend(allH(1), [a1, a2, a3, a4], legendNames, ...
            'Location', 'southoutside', 'Orientation', 'horizontal', 'FontSize', 10, 'FontWeight', 'bold');
ll.Position(2) = ll.Position(2) - 0.17;
ll.Box = 'off';

% Set font for entire figure
% allH(1).FontName = 'AvenirHeavy';

%% Save
print('N:/durable/users/avbirken/Paper_3/25-02-06-Results_allML_unimodal_VBB.svg', '-dsvg', '-r900');
print('N:/durable/users/avbirken/Paper_3/25-02-06-Results_allML_unimodal_VBB.png', '-dpng', '-r900');
close(fig);