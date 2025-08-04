function [Brier_score, Brier_score_0, Brier_score_1] = stratified_brier_score(predicted_prob_c0, predicted_prob_c1, class_labels)
% Function to return stratified Brier score based on predicted
% probabilities of both the classes and given true class labels 
%% Inputs:
% predicted_prob_c0:    vector of probabilities output from some ML method
%                       for the negative class
% 
% predicted_prob_c1:    vector of probabilities output from some ML method
%                       for the positive class 
% 
% class_labels:         vector of 0's and 1's indicating if that instance
%                       belongs to class 0 or class 1
%                       
%% Output:
% brier_score:          calculated Brier score
% 
%% Notes:
% Calculation of Brier score is based on Wikipedia article: 
% https://en.wikipedia.org/wiki/Brier_score
% Brier Score = sum((predicted_prob - class_labels).^2)/N
% 
% Stratified Brier score is defined here: https://ieeexplore.ieee.org/document/6413859
% and also here: https://www.sciencedirect.com/science/article/pii/S092523121731456X?via%3Dihub
%
% See, also: https://stats.stackexchange.com/questions/489106/brier-score-and-extreme-class-imbalance
%
% A worked example is here (the denominator for negative class is incorrectly normalized by Npos instead of Nneg):
% https://yuyangyy.com/assets/courses/files/vignette-imbcalib.html
% 
%% Author(s):
% Parekh, Pravesh
% October 13, 2019
% MBIAL
%
% Updated to stratfied Brier score
% Parekh, Pravesh
% August 01, 2024
% UiO

%% Validate input
% Check predicted_prob for negative class
if ~exist('predicted_prob_c0', 'var') || isempty(predicted_prob_c0)
    error('Please provide a vector of probabilities for negative class');
else
    N = length(predicted_prob_c0);
end

% Check predicted_prob for positive class
if ~exist('predicted_prob_c1', 'var') || isempty(predicted_prob_c1)
    error('Please provide a vector of probabilities for positive class');
else
    if length(predicted_prob_c1) ~= N
        error('Number of entries in predicted_prob of positive class does not match the number of entries in predicted_prob of negative class');
    end
end

% Check class_labels
if ~exist('class_labels', 'var') || isempty(class_labels)
    error('Please provide class label vector');
else
    if length(class_labels) ~= N
        error('predicted_prob and class_labels should have same number of entries');
    else
        if sum(class_labels ~= 0 & class_labels ~= 1) ~= 0
            error('Class labels should be either 0 or 1');
        end
    end
end

%% Location of class labels
loc_0 = class_labels == 0;
loc_1 = class_labels == 1;

%% Calculate Brier score for class 0
Brier_score_0 = sum((predicted_prob_c0(loc_0) - class_labels(loc_0)).^2)/sum(loc_0);

%% Calculate Brier score for class 1
Brier_score_1 = sum((predicted_prob_c1(loc_1) - class_labels(loc_1)).^2)/sum(loc_1);

%% Average them?
Brier_score = (Brier_score_0 + Brier_score_1)/2;