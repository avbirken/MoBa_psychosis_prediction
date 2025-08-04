function [FP, TP, FN, TN, sensitivity, specificity, accuracy, YoudenJ] = checkPerf_extended(truth, prd)
FP = sum(prd(truth == 0) == 1);
TP = sum(prd(truth == 1) == 1);

FN = sum(prd(truth == 1) == 0);
TN = sum(prd(truth == 0) == 0);

sensitivity = TP / (TP + FN);
specificity = TN / (TN + FP);
accuracy    = (sensitivity + specificity)/2;

YoudenJ = sensitivity + specificity - 1;
end