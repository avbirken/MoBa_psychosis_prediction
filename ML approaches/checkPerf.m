function [FP, TP, FN, TN] = checkPerf(truth, prd)
FP = sum(prd(truth == 0) == 1);
TP = sum(prd(truth == 1) == 1);

FN = sum(prd(truth == 1) == 0);
TN = sum(prd(truth == 0) == 0);
end