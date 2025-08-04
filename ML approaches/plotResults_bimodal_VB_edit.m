%% Get results
addpath('Z:/users/parekh/software/tight_subplot');

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
fontsize_sens = 9;

%% Where to plot
ticks = 1:2:5;
xloc1 = ticks - 0.45;
xloc2 = ticks;
xloc3 = ticks + 0.45;

%% Get results
workDir = 'Z:/users/parekh/2024-11-11_predictionPsychosis_VB/work/analysis_fuse_RUS';

% Only plotting the following scenarios: CAPE + Q14 and CAPE + Q14 + NPR
res_bimodal  = load(fullfile(workDir, 'Results_fuse_RUS_CAPE_Q14.mat'));

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

%% Set up figure
fig  = figure('Units', 'centimeters', 'Position', [10 10 17 12]);
allH = tight_subplot(1, 1, 0, [0.17 0.02], [0.085 0.01]);
hold(allH(1), 'on');

% Bimodal
% Model 1: CAPE alone
res = 1;
scatter(allH(1), repmat(ticks(res), 50,  1), res_bimodal.mean_testBalAccuracy_1 .* 100,     marker_size, col_RUS,  'filled', marker_RUS,  'jitter', jitter, 'jitterAmount', jitterAmount);
scatter(allH(1), repmat(ticks(res), 100, 1), res_bimodal.perm_mean_testBalAccuracy_1 .*100, marker_size, col_perm, 'filled', marker_perm, 'jitter', jitter, 'jitterAmount', jitterAmount, 'MarkerEdgeColor', col_perm, 'LineWidth', 1);

% Model 2: Q14 alone
res = 2;
scatter(allH(1), repmat(ticks(res), 50,  1), res_bimodal.mean_testBalAccuracy_2 .* 100,     marker_size, col_RUS,  'filled', marker_RUS,  'jitter', jitter, 'jitterAmount', jitterAmount);
scatter(allH(1), repmat(ticks(res), 100, 1), res_bimodal.perm_mean_testBalAccuracy_2 .*100, marker_size, col_perm, 'filled', marker_perm, 'jitter', jitter, 'jitterAmount', jitterAmount, 'MarkerEdgeColor', col_perm, 'LineWidth', 1);

% Model 3: CAPE + Q14: bimodal
res = 3;
scatter(allH(1), repmat(ticks(res), 50,  1), res_bimodal.mean_testBalAccuracy_F .* 100,     marker_size, col_SVM,  'filled', marker_SVM,  'jitter', jitter, 'jitterAmount', jitterAmount);
scatter(allH(1), repmat(ticks(res), 100, 1), res_bimodal.perm_mean_testBalAccuracy_F .*100, marker_size, col_perm, 'filled', marker_perm, 'jitter', jitter, 'jitterAmount', jitterAmount, 'MarkerEdgeColor', col_perm, 'LineWidth', 1);

% Add mean performances
res = 1;
plot(allH(1), [ticks(res)-jitterAmount, ticks(res)+jitterAmount], repmat(mean(res_bimodal.mean_testBalAccuracy_1 .* 100), 2, 1), 'LineWidth', 1, 'Color', col_line);
res = 2;
plot(allH(1), [ticks(res)-jitterAmount, ticks(res)+jitterAmount], repmat(mean(res_bimodal.mean_testBalAccuracy_2 .* 100), 2, 1), 'LineWidth', 1, 'Color', col_line);
res = 3;
plot(allH(1), [ticks(res)-jitterAmount, ticks(res)+jitterAmount], repmat(mean(res_bimodal.mean_testBalAccuracy_F .* 100), 2, 1), 'LineWidth', 1, 'Color', col_line);

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

% Modify x axis
allH(1).XLim             = [0 6];
allH(1).XTick            = ticks;
allH(1).XAxis.TickLength = [0 0];

% Add x tick labels
for res = 1:2
    text(allH(1), ticks(res), -7, mdlNames{res}, 'HorizontalAlignment', 'center', 'FontSize', 8.5, 'FontWeight', 'normal');
end
text(allH(1), ticks(res+1), -7, 'Multimodal', 'HorizontalAlignment', 'center', 'FontSize', 8.5, 'FontWeight', 'normal');

% Modify y axis
allH(1).YLim           = [0 100];
allH(1).YTick          = 0:10:100;
allH(1).YTickLabel     = 0:10:100;
allH(1).YLabel.String  = 'Balanced accuracy (%)';
allH(1).YAxis.FontSize = 9;

% Plot dummies
a1 = plot(allH(1), NaN, NaN, 'MarkerSize', 50, 'MarkerFaceColor',  col_RUS,  'Marker', marker_RUS, 'MarkerEdgeColor', col_RUS,  'LineStyle', 'none');
a3 = plot(allH(1), NaN, NaN, 'MarkerSize', 50, 'MarkerFaceColor',  col_SVM,  'Marker', marker_SVM, 'MarkerEdgeColor', col_SVM,  'LineStyle', 'none');
a4 = plot(allH(1), NaN, NaN, 'MarkerSize', 100, 'MarkerFaceColor', col_perm, 'Marker', marker_perm, 'MarkerEdgeColor', col_perm, 'LineStyle', 'none', 'LineWidth', 2);

% Create legend
ll = legend(allH(1), [a1, a3, a4], {'Unimodal', 'Multimodal', 'Permutation'}, ...
            'Location', 'southoutside', 'Orientation', 'horizontal', 'FontSize', 10, 'FontWeight', 'bold');
ll.Position(2) = ll.Position(2) - 0.17;
ll.Box = 'off';

%% Save
print('/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/work/Multimodal_bimodal_CAPE-Q14.png', '-dpng', '-r900');
close(fig);