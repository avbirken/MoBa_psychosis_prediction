%% Compile diagnostic predictor information for children
dirSource         = '/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/source';
dirWork           = '/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/work';
allSubjs          = readtable(fullfile(dirWork, 'IDList_ParentID_cutoffInfo.csv'));
diagInfo_cases    = readtable(fullfile(dirSource, '2024-12-17_allCases_diagInfo.csv'));
diagInfo_controls = readtable(fullfile(dirSource, '2024-12-17_allControls_diagInfo.csv'));
diagInfo_mothers  = readtable(fullfile(dirSource, '2024-12-17_diagInfo-Mothers.csv'));
diagInfo_fathers  = readtable(fullfile(dirSource, '2024-12-17_diagInfo-Fathers.csv'));

%% Get rid of excess information and merge
diagInfo_cases    = diagInfo_cases(:,ismember(diagInfo_cases.Properties.VariableNames,       {'ID_2445', 'NPR_majorFChapterBeforePredCutoff', 'KUHR_majorFChapterBeforePredCutoff', 'NPR_majorFChapterAfterCutoff', 'KUHR_majorFChapterAfterCutoff', 'ICPC_majorPChapterAfterCutoff'}));
diagInfo_controls = diagInfo_controls(:,ismember(diagInfo_controls.Properties.VariableNames, {'ID_2445', 'NPR_majorFChapterBeforePredCutoff', 'KUHR_majorFChapterBeforePredCutoff', 'NPR_majorFChapterAfterCutoff', 'KUHR_majorFChapterAfterCutoff', 'ICPC_majorPChapterAfterCutoff'}));
diagInfo          = [diagInfo_controls; diagInfo_cases];

%% Ensure everyone is part of allSubjs
% 17 control subjects who are removed (fathers have invalid FNR)
diagInfo = diagInfo(ismember(diagInfo.ID_2445, allSubjs.ID_2445), :);

% Now, include the remaining subjects who may not have had any diagnostic information
allDiagInfo = outerjoin(allSubjs, diagInfo, 'MergeKeys', true);

%% Read info on actual subject list
actList = readtable(fullfile(dirWork, 'IDList_ParentID_cutoffInfo_withFollowupData.csv'));

%% Delete "healthy" subjects who do not have follow-up post 18 years
locKeep                       = ismember(allDiagInfo.ID_2445, actList.ID_2445);
allDiagInfo(~locKeep, :)      = [];
diagInfo_fathers(~locKeep, :) = [];
diagInfo_mothers(~locKeep, :) = [];

%% Remove allSubjects
clear allSubjs

%% Parents are ordered based on IDs in IDList_ParentID_cutoffInfo.csv
% Ensure allDiagInfo is in the same order as allSubjs
if(sum(strcmpi(allDiagInfo.ID_2445, actList.ID_2445)) ~= height(allDiagInfo))
    error('Mismatch of IDs');
end

%% Merge NPR and KUHR diagnoses - before
% For every diagnosis, split, unique, and merge back
d1 = cellfun(@(x) unique(strsplit(x, ' ')), strcat(allDiagInfo.NPR_majorFChapterBeforePredCutoff, {' '}, allDiagInfo.KUHR_majorFChapterBeforePredCutoff), 'UniformOutput', false);
allDiagInfo.allDiagBefore = strtrim(cellfun(@(x) horzcat(x{:}), cellfun(@(x) strcat(x, {' '}), d1, 'UniformOutput', false), 'UniformOutput', false));

%% Merge NPR, KUHR, and ICPC diagnoses - after
d1                       = cellfun(@(x) unique(strsplit(x, ' ')), strcat(allDiagInfo.NPR_majorFChapterAfterCutoff, {' '}, allDiagInfo.KUHR_majorFChapterAfterCutoff, {' '}, allDiagInfo.ICPC_majorPChapterAfterCutoff), 'UniformOutput', false);
allDiagInfo.allDiagAfter = strtrim(strrep(cellfun(@(x) horzcat(x{:}), cellfun(@(x) strcat(x, {' '}), d1, 'UniformOutput', false), 'UniformOutput', false), 'NA', ''));

%% All diagnoses in mothers - before
d1 = cellfun(@(x) unique(strsplit(x, ' ')), strcat(diagInfo_mothers.Diag_Fmajor_NPR, {' '}, diagInfo_mothers.Diag_Fmajor_KUHR, {' '}, diagInfo_mothers.Diag_Pmajor_ICPC), 'UniformOutput', false);
diagInfo_mothers.allDiagBefore = strtrim(strrep(cellfun(@(x) horzcat(x{:}), cellfun(@(x) strcat(x, {' '}), d1, 'UniformOutput', false), 'UniformOutput', false), 'NA', ''));

%% All diagnoses in fathers - before
d1 = cellfun(@(x) unique(strsplit(x, ' ')), strcat(diagInfo_fathers.Diag_Fmajor_NPR, {' '}, diagInfo_fathers.Diag_Fmajor_KUHR, {' '}, diagInfo_fathers.Diag_Pmajor_ICPC), 'UniformOutput', false);
diagInfo_fathers.allDiagBefore = strtrim(strrep(cellfun(@(x) horzcat(x{:}), cellfun(@(x) strcat(x, {' '}), d1, 'UniformOutput', false), 'UniformOutput', false), 'NA', ''));

%% Append diagnoses to allDiagInfo
allDiagInfo.allDiagBefore_mothers = diagInfo_mothers.allDiagBefore;
allDiagInfo.allDiagBefore_fathers = diagInfo_fathers.allDiagBefore;

%% Save this file
writetable(allDiagInfo, fullfile(dirSource, '2025-02-05_diagInfo_allSubjects.csv'));