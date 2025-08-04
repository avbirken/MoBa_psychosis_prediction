function [cost, lambda, performanceVal, gridResults] = optimizeSVM_cost_fitclinear(trainFeat, trainClass, trainCovars, covarLocs, numFolds, parentID, stdLocs, seed, optimizeHow)
%% Check inputs
if not(exist('numFolds', 'var')) || isempty(numFolds)
    numFolds = 5;
end

if not(exist('seed', 'var')) || isempty(seed)
    noSeed = true;
else
    noSeed = false;
end

if not(exist('optimizeHow', 'var')) || isempty(optimizeHow)
    doBalAcc = true;
else
    optimizeHow = lower(optimizeHow);
    if not(ismember(optimizeHow, {'balacc', 'brier'}))
        error('Unknown value for optimizeHow; should be either balacc or brier');
    else
        if strcmpi(optimizeHow, 'balacc')
            doBalAcc = true;
        else
            doBalAcc = false;
        end
    end
end

if not(exist('stdLocs', 'var')) || isempty(stdLocs)
    stdLocs = 1:size(trainFeat, 2);
end

if not(exist('trainCovars', 'var')) || isempty(trainCovars)
    toRegress = false;
else
    toRegress = true;
end

if toRegress
    if not(exist('covarLocs', 'var')) || isempty(covarLocs)
        covarLocs = stdLocs;
    end
end

%% Initialize
% Grid of cost values
increments = [1, 2, 5, 10, 50, 100, 250, 500, 750, 1000];

% Make a copy of trainFeat
backup_trainFeat = trainFeat;

% Divide training data into 5 folds
if noSeed
    [trainIDX, testIDX] = makeCV(parentID, trainClass, numFolds);
else
    [trainIDX, testIDX] = makeCV(parentID, trainClass, numFolds, seed);
end

% Grid of lambda values
approxTrainSize = floor(mean(cellfun(@length, trainIDX)));
lambda          = 1/approxTrainSize;

% Where to store results
gridResults = zeros(length(increments), numFolds);

%% Optimize
for folds = 1:numFolds
    % Start with the true copy of the data
    trainFeat = backup_trainFeat;

    % Divide into training and test
    trainLocs = trainIDX{folds};
    testLocs  = testIDX{folds};

    % Training and test features
    trainFts = trainFeat(trainLocs,:);
    testFts  = trainFeat(testLocs,  :);

    % Regress covariates, if required
    if toRegress
        [trainFts(:, covarLocs), tmpCoeff] = regress_covariates(trainFts(:,covarLocs), trainCovars(trainLocs,:));
        testFts(:,   covarLocs)            = regress_covariates(testFts(:, covarLocs), trainCovars(testLocs, :), tmpCoeff);
    end

    % Compute mean and standard deviation of continous variables
    tmp_mean = mean(trainFts(:, stdLocs));
    tmp_std  = std(trainFts(:,  stdLocs));
    
    % Standardize train and test sets    
    trainFts(:, stdLocs) = (trainFts(:, stdLocs) - tmp_mean)./tmp_std;
    testFts(:,  stdLocs) = (testFts(:,  stdLocs) - tmp_mean)./tmp_std;

    % If any std was 0, replace with original data
    ll              = find(tmp_std == 0);
    trainFts(:,ll)  = backup_trainFeat(trainLocs, ll);
    testFts(:, ll)  = backup_trainFeat(testLocs,  ll);

    % Go over all grid values
    for vals = 1:length(increments)

        % Train model
        mdl = fitclinear(trainFts, trainClass(trainLocs),       ...
                         'Learner', 'svm', 'ClassName', [0,1],  ...
                         'Cost', [0 1; increments(vals), 0],    ...
                         'Lambda', lambda, 'ScoreTransform', 'logit', 'Solver', 'BFGS');

        % Predict on test
        [prd, wts] = predict(mdl, testFts);

        % Check performance
        if doBalAcc
            % Balanced accuracy for this fold, this grid value
            [FP, TP, FN, TN]         = checkPerf(trainClass(testLocs), prd);
            sensitivity              = TP./(TP + FN);
            specificity              = TN./(TN + FP);
            gridResults(vals, folds) = (sensitivity + specificity)/2;
        else
            % Brier score for this fold, this grid value
            % Always ensure that we use the correct positive class
            % probabilities
            gridResults(vals, folds) = stratified_brier_score(wts(:,mdl.ClassNames == 0), ...
                                                              wts(:,mdl.ClassNames == 1), ...
                                                              trainClass(testLocs));
        end
    end
end

% Average performance measure
meanPerformance = mean(gridResults, 2);

% Highest performance measure if balanced accuracy; otherwise lowest
if doBalAcc
    [performanceVal, b] = max(meanPerformance);
else
    [performanceVal, b] = min(meanPerformance);
end

% Selected optimal cost value
cost    = [0 1; increments(b(1)), 0];