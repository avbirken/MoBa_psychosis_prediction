%% Check sex information between MBRN and Genetics
% Remember to add it back as a predictor for Q14
%% Settings
workDir = '/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/source';
outDir  = '/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/work';

%% Read data
load(fullfile(outDir, 'sexInfo_MBRN.mat'));
load(fullfile(outDir, 'Genetics.mat'));
load(fullfile(outDir, 'Q14.mat'));
all_info_MBRN = readtable(fullfile(workDir, 'sexInfo_MBRN_All.csv'));

%% Create ID2445
all_info_MBRN.ID_2445 = strrep(strcat(cellstr(num2str(all_info_MBRN.PREG_ID_2445)), {'_'}, cellstr(num2str(all_info_MBRN.BARN_NR))), ' ', '');

% %% Remove non overlapping subjects
% locs = ismember(all_info_MBRN.ID_2445, Genetics.ID_2445);
% all_info_MBRN(not(locs),:) = [];
% 
%% Re-code sex status in MBRN
all_info_MBRN.KJONN(all_info_MBRN.KJONN == 1) = 0;
all_info_MBRN.KJONN(all_info_MBRN.KJONN == 2) = 1;
% 
%% Align data
% [a, b] = ismember(all_info_MBRN.ID_2445, Genetics.ID_2445);
% Genetics = Genetics(b,:);
% 
% %% Find subjects where there is a sex mismatch
% locs_mismatch = Genetics.sex ~= all_info_MBRN.KJONN;

%% For Genetics, reduce to overlapping samples in Q14
Genetics = Genetics(ismember(Genetics.ID_2445, Q14.ID_2445), :);

%% Assign sex info to Q14
Q14.sex = NaN(height(Q14),1);
[a, b]  = ismember(Genetics.ID_2445, Q14.ID_2445);
Q14.sex(b) = Genetics.sex;

%% For the ones who are not in genetics, get info from MBRN
all_info_MBRN = all_info_MBRN(ismember(all_info_MBRN.ID_2445, Q14.ID_2445(isnan(Q14.sex))), :);
[a, b]        = ismember(all_info_MBRN.ID_2445, Q14.ID_2445);
Q14.sex(b)    = all_info_MBRN.KJONN;

%% Reorder the variables
Q14 = movevars(Q14, 'sex', 'After', 'caseStatus');

%% Save
save(fullfile(outDir, 'Q14.mat'), 'Q14');