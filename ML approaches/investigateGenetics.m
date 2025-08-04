%% Diagnostics for Genetics workset
%% Load results from the RUS run
dirWork = '/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/work';
dirOut  = '/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/insights';

if not(exist(dirOut, 'dir'))
    mkdir(dirOut);
end

results = load(fullfile(dirWork, 'analysis_RUS', 'Results_RUS_Genetics_workSet.mat'), 'numOuterFolds', 'numRepeats', 'allSeeds', 'parentID', 'allClasses', 'testPrd');

%% Load the dataset
load(fullfile(dirWork, 'Genetics_workSet.mat'));
data = Genetics_workSet;
clear Genetics_workSet

%% Replicate the train / test split from original CV
trainIDX = cell(results.numOuterFolds, results.numRepeats);
testIDX  = cell(results.numOuterFolds, results.numRepeats);
for rep = 1:results.numRepeats

    % Set seed
    rng(results.allSeeds(rep), 'twister');

    % Partition
    [trainIDX(:,rep), testIDX(:,rep)] = makeCV(results.parentID, results.allClasses, results.numOuterFolds);
end

%% Get all NPR and KUHR diagnoses for all subjects
infoKUHR = readtable(fullfile(dirWork, 'Info_KUHR_allIDs.csv'));
infoNPR = readtable(fullfile(dirWork,'Info_NPR_allIDs.csv'));
infoICPC = readtable(fullfile(dirWork,'Info_ICPC_allIDs.csv'));

%% Age info
ageInfo = readtable(fullfile(dirWork, 'age_and_birth_month.csv'));

%% What diagnoses do our actual true cases have?
diag_NPR_trueCases  = infoNPR(ismember(infoNPR.ID_2445,   data.ID_2445(data.caseStatus == 1)), :);
diag_KUHR_trueCases = infoKUHR(ismember(infoKUHR.ID_2445, data.ID_2445(data.caseStatus == 1)), :);
diag_ICPC_trueCases = infoICPC(ismember(infoICPC.ID_2445, data.ID_2445(data.caseStatus == 1)), :);

% Filter out columns which are zero
diag_NPR_trueCases(:,find(sum(diag_NPR_trueCases{:,6:end},1) == 0) + 5) = [];
diag_KUHR_trueCases(:,find(sum(diag_KUHR_trueCases{:,6:end},1) == 0) + 5) = [];
diag_ICPC_trueCases(:,find(sum(diag_ICPC_trueCases{:,6:end},1) == 0) + 5) = [];

%% What diagnoses do our actual true non-cases have?
diag_NPR_nonCases  = infoNPR(ismember(infoNPR.ID_2445,   data.ID_2445(data.caseStatus == 0)), :);
diag_KUHR_nonCases = infoKUHR(ismember(infoKUHR.ID_2445, data.ID_2445(data.caseStatus == 0)), :);
diag_ICPC_nonCases = infoICPC(ismember(infoICPC.ID_2445, data.ID_2445(data.caseStatus == 0)), :);

% Filter out columns which are zero
diag_NPR_nonCases(:,find(sum(diag_NPR_nonCases{:,6:end},1) == 0) + 5) = [];
diag_KUHR_nonCases(:,find(sum(diag_KUHR_nonCases{:,6:end},1) == 0) + 5) = [];
diag_ICPC_nonCases(:,find(sum(diag_ICPC_nonCases{:,6:end},1) == 0) + 5) = [];

%% When did our true cases get their psychosis diagnoses?
wchDiag_ICD   = {'F20', 'F21', 'F22', 'F23', 'F24', 'F25', 'F26', 'F27', 'F28', 'F29'};
wchDiag_ICPC  = {'P72', 'P98'};
allCols_ICD   = cellfun(@(x) strcat(wchDiag_ICD, '_', x), cellstr(num2str((2008:2023)')), 'UniformOutput', false);
allCols_ICD   = vertcat(allCols_ICD{:});
allCols_ICD   = allCols_ICD(:);
allCols_NPR   = intersect(allCols_ICD, infoNPR.Properties.VariableNames);
allCols_KUHR  = intersect(allCols_ICD, infoKUHR.Properties.VariableNames);

allCols_ICPC   = cellfun(@(x) strcat(wchDiag_ICPC, '_', x), cellstr(num2str((2006:2023)')), 'UniformOutput', false);
allCols_ICPC   = vertcat(allCols_ICPC{:});
allCols_ICPC   = allCols_ICPC(:);
allCols_ICPC   = intersect(allCols_ICPC, infoICPC.Properties.VariableNames);

whenPsychosis = cell(sum(data.caseStatus==1),4);

for subjs = 1:length(whenPsychosis)
    wch = diag_KUHR_trueCases.ID_2445{subjs};
    whenPsychosis{subjs,1} = wch;

    whr = find(ismember(infoNPR.ID_2445, wch));
    if ~isempty(whr)
        try
            whenPsychosis{subjs,2} = allCols_NPR(infoNPR{whr,allCols_NPR}==1);
        end
    end

    whr = find(ismember(infoKUHR.ID_2445, wch));
    if ~isempty(whr)
        try
            whenPsychosis{subjs,3} = allCols_KUHR(infoKUHR{whr,allCols_KUHR}==1);
        end
    end

    whr = find(ismember(infoICPC.ID_2445, wch));
    if ~isempty(whr)
        try
            whenPsychosis{subjs,4} = allCols_ICPC(infoICPC{whr,allCols_ICPC}==1);
        end
    end
end

% Now go over this info and simplify to the first onset year
whenPsychosis_firstOnset = cell(sum(data.caseStatus==1), 4);
for subjs = 1:length(whenPsychosis_firstOnset)
    tmp = cellfun(@(x) strsplit(x, '_'), vertcat(whenPsychosis{subjs,2:end}), 'UniformOutput', false);
    tmp = vertcat(tmp{:});
    tmp = str2double(tmp(:,2));
    whenPsychosis_firstOnset{subjs,1} = whenPsychosis{subjs,1};
    whenPsychosis_firstOnset{subjs,2} = min(tmp);
end

% Append birth info to whenPsychosis_firstOnset
for subjs = 1:length(whenPsychosis_firstOnset)
    whenPsychosis_firstOnset{subjs,3} = ageInfo.FAAR(strcmpi(ageInfo.ID_2445, whenPsychosis_firstOnset{subjs}));
    whenPsychosis_firstOnset{subjs,4} = whenPsychosis_firstOnset{subjs,2} - whenPsychosis_firstOnset{subjs,3};
end

%% Clear up
clear infoKUHR infoNPR infoICPC

%% Age of onset info
% ageInfo = readtable('age_and_birth_month.csv');

%% Make a list of all diagnoses that exist for all cases (lifetime)
allDiag_trueCases = cell(height(diag_KUHR_trueCases), 4);
for subjs = 1:length(allDiag_trueCases)
    wch = diag_KUHR_trueCases.ID_2445{subjs};
    allDiag_trueCases{subjs,1} = wch;

    if ismember(wch, diag_NPR_trueCases.ID_2445)
        loc = ismember(diag_NPR_trueCases.ID_2445, wch);
        tmp = diag_NPR_trueCases.Properties.VariableNames(find(diag_NPR_trueCases{loc, 6:end} == 1) + 5);
        if ~isempty(tmp)
            tmp = cellfun(@(x) strsplit(x, '_'), tmp, 'UniformOutput', false);
            tmp = vertcat(tmp{:});
            tmp = unique(tmp(:,1));
            tmp = strcat(tmp, ',');
            tmp = horzcat(tmp{:});
            allDiag_trueCases{subjs,2} = tmp(1:end-1);
        end
    end

    if ismember(wch, diag_KUHR_trueCases.ID_2445)
        loc = ismember(diag_KUHR_trueCases.ID_2445, wch);
        tmp = diag_KUHR_trueCases.Properties.VariableNames(find(diag_KUHR_trueCases{loc, 6:end} == 1) + 5);
        if ~isempty(tmp)
            tmp = cellfun(@(x) strsplit(x, '_'), tmp, 'UniformOutput', false);
            tmp = vertcat(tmp{:});
            tmp = unique(tmp(:,1));
            tmp = strcat(tmp, ',');
            tmp = horzcat(tmp{:});
            allDiag_trueCases{subjs,3} = tmp(1:end-1);
        end
    end

    if ismember(wch, diag_ICPC_trueCases.ID_2445)
        loc = ismember(diag_ICPC_trueCases.ID_2445, wch);
        tmp = diag_ICPC_trueCases.Properties.VariableNames(find(diag_ICPC_trueCases{loc, 6:end} == 1) + 5);
        if ~isempty(tmp)
            tmp = cellfun(@(x) strsplit(x, '_'), tmp, 'UniformOutput', false);
            tmp = vertcat(tmp{:});
            tmp = unique(tmp(:,1));
            tmp = strcat(tmp, ',');
            tmp = horzcat(tmp{:});
            allDiag_trueCases{subjs,4} = tmp(1:end-1);
        end
    end    
end

% %% Make a list of all diagnoses that exist for all non-cases (lifetime)
% allDiag_nonCases = cell(height(diag_KUHR_nonCases), 4);
% for subjs = 1:length(allDiag_nonCases)
%     wch = diag_KUHR_nonCases.ID_2445{subjs};
%     allDiag_nonCases{subjs,1} = wch;
% 
%     if ismember(wch, diag_NPR_nonCases.ID_2445)
%         loc = ismember(diag_NPR_nonCases.ID_2445, wch);
%         tmp = diag_NPR_nonCases.Properties.VariableNames(find(diag_NPR_nonCases{loc, 6:end} == 1) + 5);
%         if ~isempty(tmp)
%             tmp = cellfun(@(x) strsplit(x, '_'), tmp, 'UniformOutput', false);
%             tmp = vertcat(tmp{:});
%             tmp = unique(tmp(:,1));
%             tmp = strcat(tmp, ',');
%             tmp = horzcat(tmp{:});
%             allDiag_nonCases{subjs,2} = tmp(1:end-1);
%         end
%     end
% 
%     if ismember(wch, diag_KUHR_nonCases.ID_2445)
%         loc = ismember(diag_KUHR_nonCases.ID_2445, wch);
%         tmp = diag_KUHR_nonCases.Properties.VariableNames(find(diag_KUHR_nonCases{loc, 6:end} == 1) + 5);
%         if ~isempty(tmp)
%             tmp = cellfun(@(x) strsplit(x, '_'), tmp, 'UniformOutput', false);
%             tmp = vertcat(tmp{:});
%             tmp = unique(tmp(:,1));
%             tmp = strcat(tmp, ',');
%             tmp = horzcat(tmp{:});
%             allDiag_nonCases{subjs,3} = tmp(1:end-1);
%         end
%     end
% 
%     if ismember(wch, diag_ICPC_nonCases.ID_2445)
%         loc = ismember(diag_ICPC_nonCases.ID_2445, wch);
%         tmp = diag_ICPC_nonCases.Properties.VariableNames(find(diag_ICPC_nonCases{loc, 6:end} == 1) + 5);
%         if ~isempty(tmp)
%             tmp = cellfun(@(x) strsplit(x, '_'), tmp, 'UniformOutput', false);
%             tmp = vertcat(tmp{:});
%             tmp = unique(tmp(:,1));
%             tmp = strcat(tmp, ',');
%             tmp = horzcat(tmp{:});
%             allDiag_nonCases{subjs,4} = tmp(1:end-1);
%         end
%     end    
% end

%% Find out how our cases are being classified
across_TP = cell(results.numOuterFolds, results.numRepeats);
across_FN = cell(results.numOuterFolds, results.numRepeats);
for rep = 1:results.numRepeats
    for folds = 1:results.numOuterFolds

        % For this fold, this repeat, get ID, true status and predicted status
        tmp_IDs         = data.ID_2445(testIDX{folds,rep});
        tmp_trueStatus  = data.caseStatus(testIDX{folds,rep});
        tmp_predStatus  = results.testPrd{folds,rep};

        % Identify true positives
        across_TP{folds,rep} = tmp_IDs(tmp_trueStatus == 1 & tmp_predStatus == 1);
        
        % Identify false negatives
        across_FN{folds,rep} = tmp_IDs(tmp_trueStatus == 1 & tmp_predStatus == 0);
    end
end

% %% Find out how our non cases are being classified
% across_FP = cell(results.numOuterFolds, results.numRepeats);
% across_TN = cell(results.numOuterFolds, results.numRepeats);
% for rep = 1:results.numRepeats
%     for folds = 1:results.numOuterFolds
% 
%         % For this fold, this repeat, get ID, true status and predicted status
%         tmp_IDs         = data.ID_2445(testIDX{folds,rep});
%         tmp_trueStatus  = data.caseStatus(testIDX{folds,rep});
%         tmp_predStatus  = results.testPrd{folds,rep};
% 
%         % Identify true positives
%         across_FP{folds,rep} = tmp_IDs(tmp_trueStatus == 0 & tmp_predStatus == 1);
% 
%         % Identify false negatives
%         across_TN{folds,rep} = tmp_IDs(tmp_trueStatus == 0 & tmp_predStatus == 0);
%     end
% end

%% Table 
[a, b] = histcounts(categorical(vertcat(across_TP{:})));
res_TP = [b', num2cell(a)'];
[a, b] = histcounts(categorical(vertcat(across_FN{:})));
res_FN = [b', num2cell(a)'];

% [a, b] = histcounts(categorical(vertcat(across_FP{:})));
% res_FP = [b', num2cell(a)'];
% [a, b] = histcounts(categorical(vertcat(across_TN{:})));
% res_TN = [b', num2cell(a)'];

%% Find the people who are consistently in one of the categories
always_FN = res_FN([res_FN{:,2}] >= 40,:);
diag_always_FN = allDiag_trueCases(ismember(allDiag_trueCases(:,1), always_FN(:,1)), :);

always_TP = res_TP([res_TP{:,2}] >= 40,:);
diag_always_TP = allDiag_trueCases(ismember(allDiag_trueCases(:,1), always_TP(:,1)), :);

% always_FP = res_FP([res_FP{:,2}] >= 40,:);
% diag_always_FP = allDiag_nonCases(ismember(allDiag_nonCases(:,1), always_FP(:,1)), :);
% 
% always_TN = res_TN([res_TN{:,2}] >= 40,:);
% diag_always_TN = allDiag_nonCases(ismember(allDiag_nonCases(:,1), always_TN(:,1)), :);

%% Save
save(fullfile(dirOut, 'insights_Genetics.mat'), '-v7.3');