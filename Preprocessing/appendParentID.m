%% Read list of all IDs and append with parent ID
allIDs   = readtable('/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/work/IDList.csv');
parentID = createParentID(allIDs.M_ID_2445, allIDs.F_ID_2445);
allIDs.parentID = parentID;
writetable(allIDs, '/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/work/IDList_ParentID.csv');