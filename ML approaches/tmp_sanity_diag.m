opts = detectImportOptions('/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/work/alt_DiagInfo.csv');
opts.VariableTypes = repmat({'char'}, length(opts.VariableTypes), 1);
altDiag = readtable('/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/work/alt_DiagInfo.csv', opts);

%%
altCaseDef = altDiag(:, [1, find(not(cellfun(@isempty, regexpi(altDiag.Properties.VariableNames, '^F2'))))]);
altCaseDef = altCaseDef(not(sum(cellfun(@isempty, altCaseDef{:,2:end}), 2) == 8), :);

%% Actual list
actualCaseList = readtable('/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/source/2024-12-17_allCases_diagInfo.csv');
beforeCases    = readtable('/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/source/2024-12-17_diagBeforeQ14.csv');

%% All subjects
allSubjs = readtable('/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/source/2024-12-17_diagInfo_allSubjects.csv');

%%
toLook   = setdiff(actualCaseList.ID_2445, altCaseDef.ID2445);
workList = actualCaseList(ismember(actualCaseList.ID_2445, toLook), :);

%% All before diagnoses in cases
tmp_allBefore_cases = strrep(strrep(allSubjs.allDiagBefore(allSubjs.caseStatus == 1), 'NA', ''), '  ', ' ');
tmp_allAfter_cases  = strrep(strrep(allSubjs.allDiagAfter(allSubjs.caseStatus  == 1), 'NA', ''), '  ', ' ');

%%
allSubjs_onlyCases       = allSubjs(allSubjs.caseStatus == 1, :);
d1                       = cellfun(@(x) unique(strsplit(x, ' ')), strcat(allSubjs_onlyCases.NPR_majorFChapterAfterCutoff, {' '}, allSubjs_onlyCases.KUHR_majorFChapterAfterCutoff), 'UniformOutput', false);
allSubjs_onlyCases.allDiagAfter_work = strtrim(strrep(cellfun(@(x) horzcat(x{:}), cellfun(@(x) strcat(x, {' '}), d1, 'UniformOutput', false), 'UniformOutput', false), 'NA', ''));