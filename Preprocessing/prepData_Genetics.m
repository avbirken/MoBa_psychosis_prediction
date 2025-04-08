%% Prepare genetics (PRS) data for ML
%% Settings
workDir = '/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/source';
outDir  = '/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/work';
PCsDir  = '/ess/p697/cluster/users/parekh/2024-09-24_MoBa-Genetics-1000Genome/';
toRead  = 'PRS_SCZ.csv';

%% Get data
% data_ADHD = readtable(fullfile(workDir, 'PRS_ADHD.csv'));
% data_ASD  = readtable(fullfile(workDir, 'PRS_ASD.csv'));
% data_BIP  = readtable(fullfile(workDir, 'PRS_BIP.csv'));
% data_MDD  = readtable(fullfile(workDir, 'PRS_MDD.csv'));
% data_SCZ  = readtable(fullfile(workDir, 'PRS_SCZ.csv'));

%% Get all IDs
allIDs = readtable(fullfile(outDir, 'IDList_ParentID_cutoffInfo_withFollowupData.csv'));

%% Get data
data     = readtable(fullfile(workDir, toRead));
[a, b]   = ismember(data.ID_2445, allIDs.ID_2445);
data     = data(a,:);

%% Ensure same ordering etc.
allIDs  = allIDs(ismember(allIDs.ID_2445, data.ID_2445), :);
[~, b]  = ismember(data.ID_2445, allIDs.ID_2445);
allIDs  = allIDs(b, :);

%% Append parent ID to data
data.ParentID = allIDs.parentID;

%% Create case status variable
data.caseStatus = allIDs.caseStatus;

%% Ensure consistent ordering
% data_ADHD = sortrows(data_ADHD, 'ID_2445');
% data_ASD  = sortrows(data_ASD,  'ID_2445');
% data_BIP  = sortrows(data_BIP,  'ID_2445');
% data_MDD  = sortrows(data_MDD,  'ID_2445');
% data  = sortrows(data,  'ID_2445');

% if any(not([sum(strcmpi(data_ADHD.ID_2445, data_ASD.ID_2445)); sum(strcmpi(data_ADHD.ID_2445, data_BIP.ID_2445)); ...
%             sum(strcmpi(data_ADHD.ID_2445, data_MDD.ID_2445)); sum(strcmpi(data_ADHD.ID_2445, data_SCZ.ID_2445))] == height(data_ADHD)))
%     error('Something went wrong');
% end

% %% Create case status variable
% data_ADHD.caseStatus = data_ADHD.any_psychosis_ICD_or_ICPC;

%% Read in the PCs from 1000 genome
newPCs = readtable(fullfile(PCsDir, 'MoBa_Projections.sscore'), 'FileType', 'text');

%% Merge new PCs with data
data = innerjoin(data, newPCs, 'LeftKeys', 'IID', 'RightKeys', 'IID');

%% Separate out covariates
locPCs      = find(not(logical(cellfun(@isempty, regexpi(data.Properties.VariableNames, '^PC.*_AVG$')))));
locBatch    = find(strcmpi(data.Properties.VariableNames, 'genotyping_batch'));
covariates  = data(:, [1, locBatch, locPCs]);

%% Separate out sex and case status
info = data(:, {'ID_2445', 'ParentID', 'caseStatus', 'sex'});
% info = data_ADHD(:, {'ID_2445', 'caseStatus', 'sex'});

%% Locations to keep
locPRS = find(not(logical(cellfun(@isempty, regexpi(data.Properties.VariableNames, '^Pt_')))));
toKeep = [1, locPRS];

%% Subset
% data_ADHD = data_ADHD(:, toKeep);
% data_ASD  = data_ASD(:,  toKeep);
% data_BIP  = data_BIP(:,  toKeep);
% data_MDD  = data_MDD(:,  toKeep);
data  = data(:,  toKeep);

%% Locations to rename
toRename = 2:12;
% data_ADHD.Properties.VariableNames(toRename) = strcat({'ADHD_'}, data_ADHD.Properties.VariableNames(toRename));
% data_ASD.Properties.VariableNames(toRename)  = strcat({'ASD_'},  data_ASD.Properties.VariableNames(toRename));
% data_BIP.Properties.VariableNames(toRename)  = strcat({'BIP_'},  data_BIP.Properties.VariableNames(toRename));
% data_MDD.Properties.VariableNames(toRename)  = strcat({'MDD_'},  data_MDD.Properties.VariableNames(toRename));
data.Properties.VariableNames(toRename)  = strcat({'SCZ_'},  data.Properties.VariableNames(toRename));

% %% Merge
% data = innerjoin(innerjoin(innerjoin(innerjoin(data_ADHD, data_ASD), data_BIP), data_MDD), data);

%% Expand covariates
allBatches = dummyvar(categorical(covariates.genotyping_batch));
batchNames = strcat({'Batch_'}, num2str((1:size(allBatches, 2))', '%02d'));

%% Append new batches to covariates
covariates.genotyping_batch = [];
for ii = 1:size(allBatches, 2)
    covariates.(batchNames{ii}) = allBatches(:,ii);
end

% %% Get all IDs
% allIDs = readtable(fullfile(outDir, 'IDList_ParentID_cutoffInfo.csv'));
% [a, b] = ismember(data.ID_2445, allIDs.ID_2445);
% data   = data(a,:);
% 
% %% Ensure same ordering etc.
% allIDs  = allIDs(ismember(allIDs.ID_2445, data.ID_2445), :);
% [~, b]  = ismember(data.ID_2445, allIDs.ID_2445);
% allIDs  = allIDs(b, :);
% 
% %% Append parent ID to data
% data.ParentID = allIDs.parentID;
% 
% %% Create case status variable
% data.caseStatus = allIDs.caseStatus;

%% Now merge sex, case status, and parent info into data
data = innerjoin(data, info);

%% Now merge covariates into data
data = innerjoin(data, covariates);

%% Re-order variables
data = movevars(data, 'ParentID',   'After', 'ID_2445');
data = movevars(data, 'caseStatus', 'After', 'ParentID');

%% Rename and save
Genetics = data;

%% Save
save(fullfile(outDir, 'Genetics.mat'), 'Genetics');