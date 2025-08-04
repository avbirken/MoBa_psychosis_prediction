%% Prepare diagnostic predictor data
dirSource = '/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/source';
dirWork   = '/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/work';
outDir    = '/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/work';
diagInfo  = readtable(fullfile(dirSource, '2025-02-05_diagInfo_allSubjects.csv'));

%% Remove some columns that we don't need
diagInfo = diagInfo(:, ismember(diagInfo.Properties.VariableNames, {'ID_2445', 'M_ID_2445', 'F_ID_2445', 'parentID', 'allDiagBefore', 'allDiagBefore_mothers', 'allDiagBefore_fathers'}));

%% Create dummy variables - children's diagnoses
toCode  = {'F1', 'F31', 'F32', 'F33', 'F4', 'F5', 'F6', 'F8', 'F84', 'F90'};
toName  = {'F1X_chapter_C', 'F31_C', 'F32_C', 'F33_C', 'F4X_chapter_C', 'F5X_chapter_C', 'F6X_chapter_C', ...
           'F8X_chapter_C', 'F84_C', 'F90_C'};
for codes = 1:length(toCode)
  diagInfo.(toName{codes}) = double(not(cellfun(@isempty, regexpi(diagInfo.allDiagBefore, toCode(codes)))));
end

%% Create dummy variables - mother's diagnoses
toCode  = {'F1', 'F2', 'F31', 'F32', 'F33', 'F4', 'F5', 'F6', 'F8', 'F84', 'F90', 'P72', 'P98'};
toName  = {'F1X_chapter_M', 'F2X_chaper_M', 'F31_M', 'F32_M', 'F33_M', 'F4X_chapter_M', 'F5X_chapter_M', 'F6X_chapter_M', ...
           'F8X_chapter_M', 'F84_M', 'F90_M', 'P72_M', 'P98_M'};
for codes = 1:length(toCode)
  diagInfo.(toName{codes}) = double(not(cellfun(@isempty, regexpi(diagInfo.allDiagBefore_mothers, toCode(codes)))));
end

%% Create dummy variables - father's diagnoses
toCode  = {'F1', 'F2', 'F31', 'F32', 'F33', 'F4', 'F5', 'F6', 'F8', 'F84', 'F90', 'P72', 'P98'};
toName  = {'F1X_chapter_F', 'F2X_chaper_F', 'F31_F', 'F32_F', 'F33_F', 'F4X_chapter_F', 'F5X_chapter_F', 'F6X_chapter_F', ...
           'F8X_chapter_F', 'F84_F', 'F90_F', 'P72_F', 'P98_F'};
for codes = 1:length(toCode)
  diagInfo.(toName{codes}) = double(not(cellfun(@isempty, regexpi(diagInfo.allDiagBefore_fathers, toCode(codes)))));
end

% %% Get old NPR information to extract out sex information
% load(fullfile(oldWork, 'NPR_workSet.mat'));
% load(fullfile(oldWork, 'NPR_holdout.mat'));
% oldNPR = [NPR_workSet; NPR_holdout];
% oldNPR = oldNPR(ismember(oldNPR.ID_2445, diagInfo.ID_2445),:);
% [a, b] = ismember(diagInfo.ID_2445, oldNPR.ID_2445);
% oldNPR = oldNPR(b,:);
% if sum(strcmpi(oldNPR.ID_2445, diagInfo.ID_2445)) ~= height(diagInfo)
%     error('Misaligned data');
% end

%% Prepare data for saving
NPR = diagInfo;
NPR.M_ID_2445 = [];
NPR.F_ID_2445 = [];
NPR.allDiagBefore = [];
NPR.allDiagBefore_mothers = [];
NPR.allDiagBefore_fathers = [];

%% Get all IDs
allIDs = readtable(fullfile(dirWork, 'IDList_ParentID_cutoffInfo_withFollowupData.csv'));

%% Align with NPR
[a, b]  = ismember(NPR.ID_2445, allIDs.ID_2445);
NPR     = NPR(a,:);

%% Ensure same ordering etc.
allIDs  = allIDs(ismember(allIDs.ID_2445, NPR.ID_2445), :);
[~, b]  = ismember(NPR.ID_2445, allIDs.ID_2445);
allIDs  = allIDs(b, :);

%% Create case status variable
NPR.caseStatus = allIDs.caseStatus;

%% Re-order variables
NPR = movevars(NPR, 'parentID',   'After', 'ID_2445');
NPR = movevars(NPR, 'caseStatus', 'After', 'parentID');

%% Fix parentID to ParentID
NPR.Properties.VariableNames{strcmp(NPR.Properties.VariableNames, 'parentID')} = 'ParentID';

%% Rename and save
save(fullfile(outDir, 'NPR.mat'), 'NPR');