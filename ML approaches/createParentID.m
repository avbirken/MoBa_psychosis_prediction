function PID = createParentID(MID, FID)
% Create parent ID (PID) for every individial using their mother ID (MID) 
% and father ID (FID)

%% Start by assigining MID as the PID
PID = MID;

%% If mother ID is empty, replace with father ID
locs      = strcmpi(PID, '');
PID(locs) = FID(locs);

%% Now handle situations where MID is different but FID is the same
% First subset to cases where we know who the father is
tmp_locs   = ~strcmpi(FID, '');
subset_FID = FID(tmp_locs);

% Next, quantify the number of offspring each father has
[a, b] = histcounts(categorical(subset_FID));

% Find fathers who have more than one offspring
FID_moreThanOne = b(a > 1)';

% Now, loop over each of these fathers, check who their offspring are,
% check the MID for these offspring; if they are the same, do nothing;
% else, replace PID with FID for all these children
for subjs = 1:length(FID_moreThanOne)
    % Who is this father?
    tmpFID = FID_moreThanOne{subjs};

    % What is the location?
    tmplocs = strcmpi(FID, tmpFID);

    % Who is/are the mother(s)?
    tmpMID = MID(tmplocs);

    if length(unique(tmpMID)) == 1
        continue;
    else
        PID(tmplocs) = FID(tmplocs);
    end
end