%% Diagnostics for CAPE workset
%% Load results from the RUS run
dirWork = '/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/work';
dirOut  = '/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/insights';
data_ageOnset = readtable('/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/source/2024-12-20_AgeofOnset.csv');

if not(exist(dirOut, 'dir'))
    mkdir(dirOut);
end

results = load(fullfile(dirWork, 'analysis_RUS', 'Results_RUS_CAPE.mat'), 'numOuterFolds', 'numRepeats', 'allSeeds', 'parentID', 'allClasses', 'testPrd');

%% Load the dataset
load(fullfile(dirWork, 'CAPE.mat'));
data = CAPE;
clear CAPE

%% Replicate the train / test split from original CV
trainIDX = cell(results.numOuterFolds, results.numRepeats);
testIDX  = cell(results.numOuterFolds, results.numRepeats);
for rep = 1:results.numRepeats

    % Set seed
    rng(results.allSeeds(rep), 'twister');

    % Partition
    [trainIDX(:,rep), testIDX(:,rep)] = makeCV(results.parentID, results.allClasses, results.numOuterFolds);
end

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

%% Table 
[a, b] = histcounts(categorical(vertcat(across_TP{:})));
res_TP = [b', num2cell(a)'];
[a, b] = histcounts(categorical(vertcat(across_FN{:})));
res_FN = [b', num2cell(a)'];

%% Find the people who are consistently in one of the categories
always_FN = res_FN([res_FN{:,2}] >= 40,:);
always_TP = res_TP([res_TP{:,2}] >= 40,:);

%% Ensure same ordering between data and data_ageOnset
% First, subset data to only cases
data = data(data.caseStatus == 1, :);

data_ageOnset = data_ageOnset(ismember(data_ageOnset.ID_2445, data.ID_2445), :);
[a, b]        = ismember(data.ID_2445, data_ageOnset.ID_2445);
data_ageOnset = data_ageOnset(b,:);

if sum(strcmpi(data_ageOnset.ID_2445, data.ID_2445)) ~= height(data)
    error('Misaligned tables');
end

%% Examine age of onset for these people
locs_always_TP = ismember(data_ageOnset.ID_2445, always_TP(:,1));
locs_always_FN = ismember(data_ageOnset.ID_2445, always_FN(:,1));
ages_always_TP = data_ageOnset.whenPsychosis_any_YYYY(locs_always_TP) - data_ageOnset.YOB(locs_always_TP);
ages_always_FN = data_ageOnset.whenPsychosis_any_YYYY(locs_always_FN) - data_ageOnset.YOB(locs_always_FN);

%% Put together some sort of data structure
% For every age:
% All subjects who have psychosis for that age
% All always_TP who have psychosis for that age
% All always_FN who have psychosis for that age
% All left overs
allAge = data_ageOnset.whenPsychosis_any_YYYY - data_ageOnset.YOB;
uqAge  = unique(allAge);
res    = zeros(length(uqAge), 4);
for ii = 1:length(uqAge)
    res(ii,1) = uqAge(ii);
    res(ii,2) = sum(allAge == uqAge(ii));
    res(ii,3) = sum(ages_always_TP == uqAge(ii));
    res(ii,4) = sum(ages_always_FN == uqAge(ii));
    res(ii,5) = res(ii,2) - (res(ii,3) + res(ii,4));
end

%% Plot
fig = figure('Units', 'centimeters', 'Position', [10 10 10 10]);
bar(res(:,1), res(:,3:end), 'stacked');
box off
legend({'TP', 'FN', 'Left'}, 'Box', 'off');
title('CAPE');

% %% Save
% clear results data
% save(fullfile(dirOut, 'insights_CAPE.mat'), '-v7.3');