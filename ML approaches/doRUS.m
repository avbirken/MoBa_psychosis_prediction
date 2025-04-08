function [trainPrd, trainWts, testPrd, testWts, LearnRate, NumLearningCycles, performanceVal] =  ...
         doRUS(trainFeat, testFeat, trainClass, trainCovars, testCovars,  covarLocs, stdLocs, ...
               numFolds,  parentID, seed,       optimizeHow, doOpt)

% This function is intended to be called within CV
%% Some initialization
if not(exist('doOpt', 'var')) || isempty(doOpt)
    doOpt = false;
else
    if not(islogical(doOpt))
        error('doOpt should be either true or false');
    end
end

if not(exist('stdLocs', 'var')) || isempty(stdLocs)
    stdLocs = 1:size(trainFeat, 2);
    catgNames = [];
else
    catgNames = setdiff(1:size(trainFeat, 2), stdLocs);
end

if not(exist('trainCovars', 'var')) || isempty(trainCovars)
    trainCovars = [];
    testCovars  = [];
    covarLocs   = [];
    toRegress   = false;
else
    if not(exist('testCovars', 'var'))
        error('test covariates must be specified when training covariates are provided');
    else
        toRegress = true;
        if not(exist('covarLocs', 'var'))
            covarLocs = stdLocs;
        end
    end
end

if not(exist('numFolds', 'var'))
    numFolds = 5;
end

if not(exist('seed', 'var'))
    seed = [];
end

if not(exist('optimizeHow', 'var')) || isempty(optimizeHow)
    optimizeHow = 'balacc';
end

%% Optimize learnRate and numLearningCycles, if required
if doOpt
    [LearnRate, NumLearningCycles, performanceVal] = optimizeRUS(trainFeat, trainClass, trainCovars, covarLocs, numFolds, parentID, stdLocs, seed, optimizeHow);
else
    LearnRate         = 0.1;
    NumLearningCycles = 100;
end

%% Make a copy of trainFeat and testFeat
backup_trainFeat = trainFeat;
backup_testFeat  = testFeat;

%% Regress covariates, if required
if toRegress
    [trainFeat(:,covarLocs), tmpCoeff] = regress_covariates(trainFeat(:,covarLocs), trainCovars);
    testFeat(:,  covarLocs)            = regress_covariates(testFeat(:, covarLocs), testCovars, tmpCoeff);
end

%% Standardize
% Compute mean and standard deviation of continous variables
tmp_mean = mean(trainFeat(:, stdLocs));
tmp_std  = std(trainFeat(:,  stdLocs));

% Standardize train and test sets
trainFeat(:, stdLocs) = (trainFeat(:, stdLocs) - tmp_mean)./tmp_std;
testFeat(:,  stdLocs) = (testFeat(:,  stdLocs) - tmp_mean)./tmp_std;

% If any std was 0, replace with original data
ll               = find(tmp_std == 0);
trainFeat(:,ll)  = backup_trainFeat(:,ll);
testFeat(:, ll)  = backup_testFeat(:, ll);

%% Actual fitting
template = templateTree('Reproducible',true);
mdl      = fitcensemble(trainFeat, trainClass, 'Method', 'RUSBoost', 'LearnRate', LearnRate,     ...
                        'NumLearningCycles', NumLearningCycles, 'Learners', template, 'CategoricalPredictors', ...
                        catgNames, 'ScoreTransform', 'none');

%% Predict
[trainPrd, trainWts] = predict(mdl, trainFeat);
[testPrd,  testWts]  = predict(mdl, testFeat);