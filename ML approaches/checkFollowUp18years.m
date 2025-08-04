% Filter out non-case subjects who may have withdrawn consent from NPR or KUHR
%% Set directories
dirWork = '/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/work';

%% Read data
data_info = readtable(fullfile(dirWork, 'IDList_ParentID.csv'));
data_diag = readtable(fullfile(dirWork, 'IDList_ParentID_cutoffInfo.csv'));

%% Consistently align the datasets
data_info = sortrows(data_info, 'ID_2445');
data_diag = sortrows(data_diag, 'ID_2445');

if sum(strcmpi(data_info.ID_2445, data_diag.ID_2445)) ~= height(data_info)
    error('Misaligned tables');
end

%% Merge datasets
data = data_diag;
data.consent_NPR  = data_info.Consent_NPR;
data.consent_KUHR = data_info.Consent_KUHR;

%% Convert consent info to numeric types
data.consent_NPR  = str2double(data.consent_NPR);
data.consent_KUHR = str2double(data.consent_KUHR);

% Convert NaN to 0
data.consent_NPR(isnan(data.consent_NPR))   = 0;
data.consent_KUHR(isnan(data.consent_KUHR)) = 0;

%% Write out a list of people who are not cases and have withdrawn consent
locSave = (data.consent_NPR == 1 | data.consent_KUHR == 1) & data.caseStatus == 0;
toSave  = data(locSave, :);
data(locSave, :) = [];

%% Write out
writetable(toSave, fullfile(dirWork, 'Excluded_noFollowUp18years.csv'));
writetable(data, fullfile(dirWork, 'IDList_ParentID_cutoffInfo_withFollowupData.csv'));