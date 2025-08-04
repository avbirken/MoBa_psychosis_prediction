function [trainIDX, holdoutIDX, cv] = makeHoldout(parentID, classes, fracData, seed)
%% Group by parent ID
[grp_PID, cat_PID] = findgroups(parentID);

%% Create psuedo groups
pseudoGroups = logical(splitapply(@sum, classes, grp_PID));

%% Create holdout partition on pseudoGroups
if exist('seed', 'var') && ~isempty(seed)
    rng(seed, 'twister');
end

cv = cvpartition(pseudoGroups, 'Holdout', fracData, 'Stratify', true);

%% Now create new IDs that map on to original data
[~, b1]     = ismember(parentID, cat_PID(cv.training));
[~, b2]     = ismember(parentID, cat_PID(cv.test));
trainIDX    = find(b1);
holdoutIDX  = find(b2);