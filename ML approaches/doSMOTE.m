function [resampledFeat, resampledClass] = doSMOTE(trainFeat, trainClass, variant, catgLocs, sendDouble)
% This function is intended to be called within CV

% Make sure variant is lower case
variant = lower(variant);

% Remove any frills in variant name
variant = strrep(strrep(variant, '-', ''), '_', '');

% If sendDouble is not specified, set it to true
if not(exist('sendDouble', 'var')) || isempty(sendDouble)
    sendDouble = true;
end

% Which variant of SMOTE to invoke?
switch(variant)
    case 'smoten'
        % Invoke smote N
        SmoteN = py.imblearn.over_sampling.SMOTEN;

        % Resample dataset
        resampled = SmoteN.fit_resample(trainFeat, py.numpy.array(trainClass));

        % Extract out data
        resampledFeat  = double(resampled.cell{1});
        resampledClass = double(resampled.cell{2});

    case 'smotenc'
        % First, make each column a cell
        [nrow, ncol] = size(trainFeat);
        if sendDouble
            tmpCell      = mat2cell(trainFeat, repmat(nrow,1,1), ones(ncol,1));
        else
            tmpCell      = mat2cell(int32(trainFeat), repmat(nrow,1,1), ones(ncol,1));
        end

        % Now, make column names for each cell
        colNames = matlab.lang.makeValidName(cellstr(num2str((1:ncol)')));

        % Next, make a structure out of trainFeat
        tmpStruct = cell2struct(tmpCell, colNames,2);

        % Next, invoke smote NC and provide column names of categorical
        % features mapped from colNames
        SmoteNC = py.imblearn.over_sampling.SMOTENC(colNames(catgLocs)');

        % Now, make a pandas data frame for dataset
        df = py.pandas.DataFrame(py.dict(tmpStruct));

        % Resample dataset
        resampled = SmoteNC.fit_resample(df, py.numpy.array(trainClass));

        % Extract out data
        resampledFeat  = double(py.numpy.array(resampled.cell{1}));
        resampledClass = double(resampled.cell{2});

    case 'smote'
        % Invoke SMOTE
        Smote = py.imblearn.over_sampling.SMOTE;

        % Resample dataset
        if sendDouble
            resampled = Smote.fit_resample(trainFeat, py.numpy.array(trainClass));
        else
            resampled = Smote.fit_resample(int32(trainFeat), py.numpy.array(trainClass));
        end

        % Extract out data
        resampledFeat  = double(resampled.cell{1});
        resampledClass = double(resampled.cell{2});
end