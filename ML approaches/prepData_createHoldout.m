%% Prepare holdout sample
dirSource = '/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/source';
dirOutput = '/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/work';

%% List of files to process
listFiles = dir(fullfile(dirSource, '*.csv'));
listFiles = {listFiles(:).name}';

% Get rid of a few files
toRemove = {'BUP_subset.csv', 'PDB2445_DELTAKERLISTE_GYLDIG_FNR_SAMTYKKE.csv', 'PDB2445_SV_INFO_V12_20241101.csv', 'any_ICD_or_ICPC_psychosis.csv'};
listFiles = listFiles(not(ismember(listFiles, toRemove)));

%% Read all data frames
data = cell(length(listFiles), 1);
for files = 1:length(listFiles)
    data{files,1} = readtable(fullfile(dirSource, listFiles{files}));
end

%% Read list of subjects we need to work with
listSubjects = readtable(fullfile(dirOutput, 'IDList.csv'));

%% Find out IDs which are present in all dataframes
allIDs = cellfun(@(x) vertcat(x.ID_2445), data, 'UniformOutput', false);
allIDs = vertcat(allIDs{:});

% Remove subjects not in listSubjects
allIDs = allIDs(ismember(allIDs, listSubjects.ID_2445));

% Count
[a, b] = histcounts(categorical(allIDs));

% Which subjects are present all the time?
holdoutSample = b(a == length(listFiles))';

%% Save the holdout sample
holdoutSample = cell2table(holdoutSample, 'VariableNames', {'ID_2445'});
writetable(holdoutSample, fullfile(dirOutput, 'HoldoutSample.csv'));