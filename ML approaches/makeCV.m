function [trainIDX, testIDX, cv] = makeCV(parentID, classes, numFolds, seed)
%% Group by parent ID
[grp_PID, cat_PID] = findgroups(parentID);

%% Create psuedo groups
pseudoGroups = logical(splitapply(@sum, classes, grp_PID));

%% Do CV on pseudoGroups
if exist('seed', 'var') && ~isempty(seed)
    rng(seed, 'twister');
end

cv = cvpartition(pseudoGroups, 'KFold', numFolds, 'Stratify', true);

%% Now go over folds and create new IDs that map on to original data
trainIDX  = cell(numFolds,1);
testIDX   = cell(numFolds,1);
for folds = 1:numFolds
    [~, b1]         = ismember(parentID, cat_PID(cv.training(folds)));
    [~, b2]         = ismember(parentID, cat_PID(cv.test(folds)));
    trainIDX{folds} = find(b1);
    testIDX{folds}  = find(b2);
end