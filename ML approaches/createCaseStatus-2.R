library(data.table)
library(haven)

# Set paths
dirNPR   <- "/ess/p697/cluster/users/parekh/2023-08-14_parseNPR"
dirKUHR  <- "/ess/p697/cluster/users/parekh/2023-10-24_KUHR"
dirPhen  <- "/tsd/p697/data/durable/phenotypes/mobaQ/PDB2445_V12_Q14/2024-03-07"
dirMBRN  <- "/tsd/p697/data/durable/phenotypes/mbrn/"
dirInfo  <- "/tsd/p697/data/durable/phenotypes/sv_infofiles"

# Read data
dataNPR  <- fread(file.path(dirNPR, "2024-09-19-MoBa-LinkedNPR-AllSubjects.csv"))
dataKUHR <- fread(file.path(dirKUHR, "2024-09-19-MoBa-LinkedKUHR-Children.csv"))
Q14resp  <- read_sav(file.path(dirPhen, "PDB2445_Ungdomsskjema_Barn_v12_spesielle.sav"))
dataMBRN <- read_sav(file.path(dirMBRN, "PDB2445_MFR_541_v12", "PDB2445_MFR_541_v12.sav"))
infoMBRN <- read_sav(file.path(dirMBRN, "PDB2445_MBRN_541_v12.sav"))
dataInfo <- read_sav(file.path(dirInfo, "PDB2445_SV_INFO_V12_20241101.sav"))

# Make sure everyone is in info file
dataNPR  <- dataNPR[dataNPR$PREG_ID_2445 %in% dataInfo$PREG_ID_2445, ]
dataKUHR <- dataKUHR[dataKUHR$PREG_ID_2445 %in% dataInfo$PREG_ID_2445, ]
Q14resp  <- Q14resp[Q14resp$PREG_ID_2445 %in% dataInfo$PREG_ID_2445, ]
dataMBRN <- dataMBRN[dataMBRN$PREG_ID_2445 %in% dataInfo$PREG_ID_2445, ]
infoMBRN <- infoMBRN[infoMBRN$PREG_ID_2445 %in% dataInfo$PREG_ID_2445, ]

# Create ID_2445
infoMBRN$ID_2445 <- paste0(infoMBRN$PREG_ID_2445, "_", infoMBRN$BARN_NR)
dataMBRN$ID_2445 <- paste0(dataMBRN$PREG_ID_2445, "_", dataMBRN$BARN_NR)
Q14resp$ID_2445  <- paste0(Q14resp$PREG_ID_2445,  "_", Q14resp$BARN_NR)
dataNPR$ID_2445  <- paste0(dataNPR$PREG_ID_2445,  "_", dataNPR$ChildNumber)
dataKUHR$ID_2445 <- paste0(dataKUHR$PREG_ID_2445, "_", dataKUHR$ChildNumber)

# From NPR, get rid of NCMP, NCSP, and empty diagnostic rows
dataNPR <- dataNPR[!(dataNPR$Diagnosis_ICDCode == "" | dataNPR$ManualName == "NCMP" | dataNPR$ManualName == "NCSP"),]

# From KUHR, get rid of empty diagnostic rows
dataKUHR <- dataKUHR[!dataKUHR$Diagnosis == "",]

# In KUHR, there are about 4524 rows having various diagnostic codes but no manual specified
# Ignoring these - the PracticeType includes:
# "Spesialist \xf8re-nese-hals"
# "Spesialist \xf8yelege"
# "Fastlege"                   
# "Spesialist"
# "Fastl\xf8nnet"
# "Legevakt"                   
# "Spesialist barnesykdommer" 
# Several F27 codes from eye specialists; a couple of F29
# Some P chapter codes; couple of P99s
dataKUHR <- dataKUHR[!dataKUHR$DiagnosticManual == "", ]

# Within KUHR, remove "2.16.578.1.12.4.1.1.71.7170" and one child with ICD-9
dataKUHR <- dataKUHR[!(dataKUHR$DiagnosticManual == "ICD-9" | dataKUHR$DiagnosticManual == "2.16.578.1.12.4.1.1.71.7170"),]

# Further reduce the memory burden
dataKUHR <- dataKUHR[, c("PracticeType", "DiffDays", "Diagnosis", "DiagnosticManual", "Year", "PREG_ID_2445", "ChildNumber", "WithdrawnConsent18years", "ID_2445")]
dataNPR  <- dataNPR[,  c("Year", "DiffDays_Admission", "DiffDays_Discharge", "InstitutionID", "ManualName", "ManualType", "Diagnosis_ICDCode", "PREG_ID_2445", "ChildNumber", "WithdrawnConsent18years", "M_ID_2445", "F_ID_2445", "ID_2445")]

# Let's identify cases: F20-F25, F28-F29, P72, P98
# NPR
allCodes_ICD <- c("F20", "F21", "F22", "F23", "F24", "F25", "F28", "F29")
locs_NPR     <- data.frame(matrix(data = FALSE, nrow=nrow(dataNPR), ncol=length(allCodes_ICD)))
count <- 1
for (cc in allCodes_ICD)
{
  locs_NPR[,count] <- grepl(glob2rx(paste0("*", cc, "*")), dataNPR$Diagnosis_ICDCode)
  count <- count + 1
}
anyL_NPR <- as.logical(rowSums(locs_NPR))

#KUHR - ICD
locs_KUHR  <- data.frame(matrix(data = FALSE, nrow=nrow(dataKUHR), ncol=length(allCodes_ICD)))
count <- 1
for (cc in allCodes_ICD)
{
  locs_KUHR[,count] <- grepl(glob2rx(paste0("*", cc, "*")), dataKUHR$Diagnosis) &
                      !grepl(glob2rx("*ICPC*"), dataKUHR$DiagnosticManual)
  count <- count + 1
}
anyL_KUHR <- as.logical(rowSums(locs_KUHR))

# Codes to keep - ICPC
allCodes_ICPC <- c("P72", "P98")
locs_ICPC  <- data.frame(matrix(data = FALSE, nrow=nrow(dataKUHR), ncol=length(allCodes_ICPC)))
count <- 1
for (cc in allCodes_ICPC)
{
  locs_ICPC[,count] <- grepl(glob2rx(paste0("*", cc, "*")), dataKUHR$Diagnosis) & 
                       grepl(glob2rx("*ICPC*"), dataKUHR$DiagnosticManual)
  count <- count + 1
}
anyL_ICPC <- as.logical(rowSums(locs_ICPC))

# For all subjects, put together basic information
# Losing 48212_1 because this subject is not in full MBRN
allSubjs <- data.frame(matrix(data = NA, nrow=nrow(infoMBRN), ncol = 4))
colnames(allSubjs) <- c("ID_2445", "YOB", "MOB", "Age_mnths_Q14")
count <- 1
for (ids in infoMBRN$ID_2445)
{
  allSubjs$ID_2445[count]       <- ids
  allSubjs$YOB[count]           <- infoMBRN$FAAR[infoMBRN$ID_2445 %in% ids]
  allSubjs$MOB[count]           <- dataMBRN$FMND[dataMBRN$ID_2445 %in% ids]
  if (sum(Q14resp$ID_2445 %in% ids) > 0)
  {
    allSubjs$Age_mnths_Q14[count] <- Q14resp$AGE_MTHS_UB[Q14resp$ID_2445 %in% ids]
  }
  count <- count + 1
}

# When did subjects get any of the relevant diagnoses?
tmp_cases <- unique(c(dataNPR$ID_2445[anyL_NPR], dataKUHR$ID_2445[anyL_KUHR], dataKUHR$ID_2445[anyL_ICPC]))
tmp_NPR   <- dataNPR[anyL_NPR,]
tmp_KUHR  <- dataKUHR[anyL_KUHR]
tmp_ICPC  <- dataKUHR[anyL_ICPC]
whenDiag  <- data.frame(matrix(data = NA, nrow=length(tmp_cases), ncol = 12))
colnames(whenDiag) <- c("ID_2445", "When_NPR_diff",  "When_NPR_Year",  "Where_NPR",
                                   "When_KUHR_diff", "When_KUHR_Year", "Where_KUHR", 
                                   "When_ICPC_diff", "When_ICPC_Year", "Where_ICPC",
                                   "When_any_diff",  "When_any_Year")
count <- 1
for (ids in tmp_cases)
{
  # Save subject ID
  whenDiag$ID_2445[count] <- ids
  
  # Check if NPR diagnoses
  if (sum(tmp_NPR$ID_2445 %in% ids) > 0)
  {
    tmp <- tmp_NPR[tmp_NPR$ID_2445 %in% ids,]
    whenDiag$When_NPR_diff[count] <- min(c(tmp$DiffDays_Admission, tmp$DiffDays_Discharge), na.rm = T)
    whenDiag$When_NPR_Year[count] <- min(tmp$Year)
    whenDiag$Where_NPR[count]     <- paste(unique(tmp$InstitutionID), collapse = ' ')
  }
  
  # Check if KUHR diagnoses
  if (sum(tmp_KUHR$ID_2445 %in% ids) > 0)
  {
    tmp <- tmp_KUHR[tmp_KUHR$ID_2445 %in% ids,]
    whenDiag$When_KUHR_diff[count] <- min(tmp$DiffDays)
    whenDiag$When_KUHR_Year[count] <- min(tmp$Year)
    whenDiag$Where_KUHR[count]     <- paste(unique(tmp$PracticeType), collapse = ' ')
  }
  
  # Check if ICPC diagnoses
  if (sum(tmp_ICPC$ID_2445 %in% ids) > 0)
  {
    tmp <- tmp_ICPC[tmp_ICPC$ID_2445 %in% ids,]
    whenDiag$When_ICPC_diff[count] <- min(tmp$DiffDays)
    whenDiag$When_ICPC_Year[count] <- min(tmp$Year)
    whenDiag$Where_ICPC[count]     <- paste(unique(tmp$PracticeType), collapse = ' ')
  }
  
  # Overall min
  whenDiag$When_any_diff[count] <- min(c(whenDiag$When_NPR_diff[count],
                                         whenDiag$When_KUHR_diff[count],
                                         whenDiag$When_ICPC_diff[count]), na.rm = T)
  whenDiag$When_any_Year[count] <- min(c(whenDiag$When_NPR_Year[count],
                                         whenDiag$When_KUHR_Year[count],
                                         whenDiag$When_ICPC_Year[count]), na.rm = T)
  
  count <- count + 1
}

# Merge whenDiag with allSubjs
# Losing 56309_1 at this stage - this subject does not seem to be in MBRN
allCaseInfo <- merge(whenDiag, allSubjs)

# For subjects who responded to Q14, create Q14+6mnths period; the ones who did not, 14 years
locs <- is.na(allCaseInfo$Age_mnths_Q14)
allCaseInfo$cutoff[!locs] <- (allCaseInfo$Age_mnths_Q14[!locs] + 6)/12 * 365
allCaseInfo$cutoff[locs]  <- 14*365
allCaseInfo$cutoff_predictor <- allCaseInfo$cutoff - (6/12*365)

# Identify people who had a diagnosis before Q14/14 years - to be eliminated
diagBeforeQ14 <- allCaseInfo[allCaseInfo$When_any_diff <= allCaseInfo$cutoff, ]

# Identify people who got a diagnosis after Q14/14 years - actual cases
allCases  <- allCaseInfo[allCaseInfo$When_any_diff > allCaseInfo$cutoff, ]

# Free up more memory
rm(allCaseInfo)
rm(dataMBRN)
rm(infoMBRN)

# Identify controls - everyone left over
allControls <- allSubjs[allSubjs$ID_2445 %in% setdiff(allSubjs$ID_2445, c(diagBeforeQ14$ID_2445, allCases$ID_2445)), ]

fwrite(diagBeforeQ14, file = "/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/source/2024-12-17_diagBeforeQ14.csv", row.names = F)
fwrite(allControls, file = "/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/source/2024-12-17_allControls.csv", row.names = F)
fwrite(allCases, file = "/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/source/2024-12-17_allCases.csv", row.names = F)

# Cutoff date for controls
locs <- is.na(allControls$Age_mnths_Q14)
allControls$cutoff[!locs] <- (allControls$Age_mnths_Q14[!locs] + 6)/12 * 365
allControls$cutoff[locs]  <- 14*365
allControls$cutoff_predictor <- allControls$cutoff - (6/12*365)


# Get rid of any ICD diagnoses outside of F chapter
dataNPR <- dataNPR[grepl(glob2rx("*F*"), dataNPR$Diagnosis_ICDCode), ]

# Get rid of any ICD diagnoses outside of F chapter if non-ICPC and outside P chapter if outside ICD
loc1 <- grepl(glob2rx("*F*"), dataKUHR$Diagnosis) & !grepl(glob2rx("*ICPC*"), dataKUHR$DiagnosticManual)
loc2 <- grepl(glob2rx("*P*"), dataKUHR$Diagnosis) &  grepl(glob2rx("*ICPC*"), dataKUHR$DiagnosticManual)
dataKUHR <- dataKUHR[loc1 | loc2, ]


# For all the cases, make a list of all diagnoses before cutoff and after cutoff
allCases$NPR_FChapterBeforeCutoff   <- NA
allCases$NPR_FChapterAfterCutoff    <- NA

allCases$NPR_majorFChapterBeforeCutoff   <- NA
allCases$NPR_majorFChapterAfterCutoff    <- NA

allCases$NPR_FChapterBeforePredCutoff <- NA
allCases$NPR_majorFChapterBeforePredCutoff <- NA

allCases$KUHR_FChapterBeforeCutoff  <- NA
allCases$KUHR_FChapterAfterCutoff   <- NA

allCases$KUHR_majorFChapterBeforeCutoff  <- NA
allCases$KUHR_majorFChapterAfterCutoff   <- NA

allCases$KUHR_FChapterBeforePredCutoff <- NA
allCases$KUHR_majorFChapterBeforePredCutoff <- NA

allCases$ICPC_PChapterBeforeCutoff  <- NA
allCases$ICPC_PChapterAfterCutoff   <- NA

allCases$ICPC_majorPChapterBeforeCutoff  <- NA
allCases$ICPC_majorPChapterAfterCutoff   <- NA

count <- 1
for (ids in allCases$ID_2445)
{
  if(count %% 100 == 0)
  {
    print(paste0("count = ", count, "; ", Sys.time()))
  }
  
  if (sum(dataNPR$ID_2445 %in% ids) > 0)
  {
    tmp       <- dataNPR[dataNPR$ID_2445 %in% ids, ]
    allBefore <- unique(tmp$Diagnosis_ICDCode[pmin(tmp$DiffDays_Admission, tmp$DiffDays_Discharge) <= allCases$cutoff[count]])
    allAfter  <- unique(tmp$Diagnosis_ICDCode[pmin(tmp$DiffDays_Admission, tmp$DiffDays_Discharge) >  allCases$cutoff[count]])
    allBefore <- allBefore[nzchar(allBefore)]
    allAfter  <- allAfter[nzchar(allAfter)]
    
    if (length(allBefore) > 0)
    {
      allCases$NPR_FChapterBeforeCutoff[count]       <- paste(allBefore, collapse = " ")
      # allCases$NPR_majorFChapterBeforeCutoff[count]  <- paste(unique(substr(allBefore, 1, 3)), collapse = " ")
    }
    
   if (length(allAfter) > 0)
   {
     allCases$NPR_FChapterAfterCutoff[count]       <- paste(allAfter, collapse = " ")
     # allCases$NPR_majorFChapterAfterCutoff[count]  <- paste(unique(substr(allAfter, 1, 3)), collapse = " ")
   }
  }
  
  allBefore <- unique(tmp$Diagnosis_ICDCode[pmin(tmp$DiffDays_Admission, tmp$DiffDays_Discharge) <= allCases$cutoff_predictor[count]])
  allBefore <- allBefore[nzchar(allBefore)]
  if (length(allBefore) > 0)
  {
    allCases$NPR_FChapterBeforePredCutoff[count]       <- paste(allBefore, collapse = " ")
    # allCases$NPR_majorFChapterBeforePredCutoff[count]  <- paste(unique(substr(allBefore, 1, 3)), collapse = " ")
  }
  
  # KUHR - ICD
  if (sum(dataKUHR$ID_2445 %in% ids) > 0)
  {
    tmp  <- dataKUHR[dataKUHR$ID_2445 %in% ids, ]
    
    allBefore <- unique(tmp$Diagnosis[tmp$DiffDays <= allCases$cutoff[count] & !grepl(glob2rx("*ICPC*"), tmp$DiagnosticManual)])
    allAfter  <- unique(tmp$Diagnosis[tmp$DiffDays >  allCases$cutoff[count] & !grepl(glob2rx("*ICPC*"), tmp$DiagnosticManual)])
    allBefore <- allBefore[nzchar(allBefore)]
    allAfter  <- allAfter[nzchar(allAfter)]
    allBefore <- unique(gsub("^ ", "", unlist(strsplit(allBefore, ","))))
    allAfter  <- unique(gsub("^ ", "", unlist(strsplit(allAfter, ","))))
    allBefore <- allBefore[grepl("^F", allBefore)]
    allAfter  <- allAfter[grepl("^F", allAfter)]
    
    if (length(allBefore) > 0)
    {
      allCases$KUHR_FChapterBeforeCutoff[count]      <- paste(allBefore, collapse = " ")
     # allCases$KUHR_majorFChapterBeforeCutoff[count] <- paste(unique(substr(allBefore, 1, 3)), collapse = " ")
    }
    
    if (length(allAfter) > 0)
    {
      allCases$KUHR_FChapterAfterCutoff[count]      <- paste(allAfter, collapse = " ")
      # allCases$KUHR_majorFChapterAfterCutoff[count] <- paste(unique(substr(allAfter, 1, 3)), collapse = " ")
    }
    
    allBefore <- unique(tmp$Diagnosis[tmp$DiffDays <= allCases$cutoff_predictor[count] & !grepl(glob2rx("*ICPC*"), tmp$DiagnosticManual)])
    allBefore <- allBefore[nzchar(allBefore)]
    allBefore <- unique(gsub("^ ", "", unlist(strsplit(allBefore, ","))))
    allBefore <- allBefore[grepl("^F", allBefore)]
    
    if (length(allBefore) > 0)
    {
      allCases$KUHR_FChapterBeforePredCutoff[count]       <- paste(allBefore, collapse = " ")
      # allCases$KUHR_majorFChapterBeforePredCutoff[count]  <- paste(unique(substr(allBefore, 1, 3)), collapse = " ")
    }
  
    # KUHR - ICPC
    allBefore <- unique(tmp$Diagnosis[tmp$DiffDays <= allCases$cutoff[count] & grepl(glob2rx("*ICPC*"), tmp$DiagnosticManual)])
    allAfter  <- unique(tmp$Diagnosis[tmp$DiffDays >  allCases$cutoff[count] & grepl(glob2rx("*ICPC*"), tmp$DiagnosticManual)])
    allBefore <- allBefore[nzchar(allBefore)]
    allAfter  <- allAfter[nzchar(allAfter)]
    allBefore <- unique(gsub("^ ", "", unlist(strsplit(allBefore, ","))))
    allAfter  <- unique(gsub("^ ", "", unlist(strsplit(allAfter, ","))))
    allBefore <- allBefore[grepl("^P", allBefore)]
    allAfter  <- allAfter[grepl("^P", allAfter)]
    
    if (length(allBefore) > 0)
    {
      allCases$ICPC_PChapterBeforeCutoff[count]       <- paste(allBefore, collapse = " ")
      # allCases$ICPC_majorPChapterBeforeCutoff[count]  <- paste(unique(substr(allBefore, 1, 3)), collapse = " ")
    }
    
    if (length(allAfter) > 0)
    {
      allCases$ICPC_PChapterAfterCutoff[count]       <- paste(allAfter, collapse = " ")
      # allCases$ICPC_majorPChapterAfterCutoff[count]  <- paste(unique(substr(allAfter, 1, 3)), collapse = " ")
    }
  }
  count <- count + 1
}

# ff_before_ICD <- function(ids, cutoff) unique(dataNPR$Diagnosis_ICDCode[dataNPR$ID_2445 %in% ids & pmin(dataNPR$DiffDays_Admission, dataNPR$DiffDays_Discharge) <= cutoff])

# Now create the substring of major codes
ff <- function(x) paste(substr(x, 1, 3), collapse = " ")
allCases$NPR_majorFChapterBeforeCutoff <- lapply(strsplit(x = allCases$NPR_FChapterBeforeCutoff, split = " "), ff)
allCases$NPR_majorFChapterAfterCutoff  <- lapply(strsplit(x = allCases$NPR_FChapterAfterCutoff, split = " "), ff)
allCases$NPR_majorFChapterBeforePredCutoff  <- lapply(strsplit(x = allCases$NPR_FChapterBeforePredCutoff, split = " "), ff)

allCases$KUHR_majorFChapterBeforeCutoff  <- lapply(strsplit(x = allCases$KUHR_FChapterBeforeCutoff, split = " "), ff)
allCases$KUHR_majorFChapterAfterCutoff  <- lapply(strsplit(x = allCases$KUHR_FChapterAfterCutoff, split = " "), ff)
allCases$KUHR_majorFChapterBeforePredCutoff  <- lapply(strsplit(x = allCases$KUHR_FChapterBeforePredCutoff, split = " "), ff)

allCases$ICPC_majorPChapterBeforeCutoff  <- lapply(strsplit(x = allCases$ICPC_PChapterBeforeCutoff, split = " "), ff)
allCases$ICPC_majorPChapterAfterCutoff  <- lapply(strsplit(x  = allCases$ICPC_PChapterAfterCutoff, split = " "), ff)

fwrite(allCases, file = "/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/source/2024-12-17_allCases_diagInfo.csv", row.names = F)


# Get rid of cases from data
dataNPR  <- dataNPR[!(dataNPR$ID_2445 %in% allCases$ID_2445), ]
dataKUHR <- dataKUHR[!(dataKUHR$ID_2445 %in% allCases$ID_2445), ]


# For all the controls, make a list of all diagnoses before cutoff and after cutoff
allControls$NPR_FChapterBeforeCutoff   <- NA
allControls$NPR_FChapterAfterCutoff    <- NA

allControls$NPR_majorFChapterBeforeCutoff   <- NA
allControls$NPR_majorFChapterAfterCutoff    <- NA

allControls$NPR_FChapterBeforePredCutoff <- NA
allControls$NPR_majorFChapterBeforePredCutoff <- NA

allControls$KUHR_FChapterBeforeCutoff  <- NA
allControls$KUHR_FChapterAfterCutoff   <- NA

allControls$KUHR_majorFChapterBeforeCutoff  <- NA
allControls$KUHR_majorFChapterAfterCutoff   <- NA

allControls$KUHR_FChapterBeforePredCutoff <- NA
allControls$KUHR_majorFChapterBeforePredCutoff <- NA

allControls$ICPC_PChapterBeforeCutoff  <- NA
allControls$ICPC_PChapterAfterCutoff   <- NA

allControls$ICPC_majorPChapterBeforeCutoff  <- NA
allControls$ICPC_majorPChapterAfterCutoff   <- NA

count <- 1
for (ids in allControls$ID_2445)
{
  if(count %% 100 == 0)
  {
    print(paste0("count = ", count, "; ", Sys.time()))
  }
  
  if (sum(dataNPR$ID_2445 %in% ids) > 0)
  {
    tmp       <- dataNPR[dataNPR$ID_2445 %in% ids, ]
    allBefore <- unique(tmp$Diagnosis_ICDCode[pmin(tmp$DiffDays_Admission, tmp$DiffDays_Discharge) <= allControls$cutoff[count]])
    allAfter  <- unique(tmp$Diagnosis_ICDCode[pmin(tmp$DiffDays_Admission, tmp$DiffDays_Discharge) >  allControls$cutoff[count]])
    allBefore <- allBefore[nzchar(allBefore)]
    allAfter  <- allAfter[nzchar(allAfter)]
    
    if (length(allBefore) > 0)
    {
      allControls$NPR_FChapterBeforeCutoff[count] <- paste(allBefore, collapse = " ")
      # allControls$NPR_majorFChapterBeforeCutoff[count]  <- paste(unique(substr(allBefore, 1, 3)), collapse = " ")
    }
    
    if (length(allAfter) > 0)
    {
      allControls$NPR_FChapterAfterCutoff[count]   <- paste(allAfter, collapse = " ")
      # allControls$NPR_majorFChapterAfterCutoff[count]  <- paste(unique(substr(allAfter, 1, 3)), collapse = " ")
    }
  }
  
  allBefore <- unique(tmp$Diagnosis_ICDCode[pmin(tmp$DiffDays_Admission, tmp$DiffDays_Discharge) <= allControls$cutoff_predictor[count]])
  allBefore <- allBefore[nzchar(allBefore)]
  if (length(allBefore) > 0)
  {
    allControls$NPR_FChapterBeforePredCutoff[count]  <- paste(allBefore, collapse = " ")
    # allControls$NPR_majorFChapterBeforePredCutoff[count]  <- paste(unique(substr(allBefore[grepl("^F", allBefore)], 1, 3)), collapse = " ")
  }
  
  if (sum(dataKUHR$ID_2445 %in% ids) > 0)
  {
    tmp  <- dataKUHR[dataKUHR$ID_2445 %in% ids, ]
    
    allBefore <- unique(tmp$Diagnosis[tmp$DiffDays <= allControls$cutoff[count] & !grepl(glob2rx("*ICPC*"), tmp$DiagnosticManual)])
    allAfter  <- unique(tmp$Diagnosis[tmp$DiffDays >  allControls$cutoff[count] & !grepl(glob2rx("*ICPC*"), tmp$DiagnosticManual)])
    allBefore <- allBefore[nzchar(allBefore)]
    allAfter  <- allAfter[nzchar(allAfter)]
    allBefore <- unique(gsub("^ ", "", unlist(strsplit(allBefore, ","))))
    allAfter  <- unique(gsub("^ ", "", unlist(strsplit(allAfter, ","))))
    allBefore <- allBefore[grepl("^F", allBefore)]
    allAfter  <- allAfter[grepl("^F", allAfter)]
    
    if (length(allBefore) > 0)
    {
      allControls$KUHR_FChapterBeforeCutoff[count]  <- paste(allBefore, collapse = " ")
      # allControls$KUHR_majorFChapterBeforeCutoff[count]  <- paste(unique(substr(allBefore, 1, 3)), collapse = " ")
    }
    
    if (length(allAfter) > 0)
    {
      allControls$KUHR_FChapterAfterCutoff[count]   <- paste(allAfter, collapse = " ")
      # allControls$KUHR_majorFChapterAfterCutoff[count]  <- paste(unique(substr(allAfter, 1, 3)), collapse = " ")
    }
    
    allBefore <- unique(tmp$Diagnosis[tmp$DiffDays <= allControls$cutoff_predictor[count] & !grepl(glob2rx("*ICPC*"), tmp$DiagnosticManual)])
    allBefore <- allBefore[nzchar(allBefore)]
    allBefore <- unique(gsub("^ ", "", unlist(strsplit(allBefore, ","))))
    allBefore <- allBefore[grepl("^F", allBefore)]
    
    if (length(allBefore) > 0)
    {
      allControls$KUHR_FChapterBeforePredCutoff[count]       <- paste(allBefore, collapse = " ")
      # allControls$KUHR_majorFChapterBeforePredCutoff[count]  <- paste(unique(substr(allBefore[grepl("^F", allBefore)], 1, 3)), collapse = " ")
    }
    
    allBefore <- unique(tmp$Diagnosis[tmp$DiffDays <= allControls$cutoff[count] & grepl(glob2rx("*ICPC*"), tmp$DiagnosticManual)])
    allAfter  <- unique(tmp$Diagnosis[tmp$DiffDays >  allControls$cutoff[count] & grepl(glob2rx("*ICPC*"), tmp$DiagnosticManual)])
    allBefore <- allBefore[nzchar(allBefore)]
    allAfter  <- allAfter[nzchar(allAfter)]
    allBefore <- unique(gsub("^ ", "", unlist(strsplit(allBefore, ","))))
    allAfter  <- unique(gsub("^ ", "", unlist(strsplit(allAfter, ","))))
    allBefore <- allBefore[grepl("^P", allBefore)]
    allAfter  <- allAfter[grepl("^P", allAfter)]
    
    if (length(allBefore) > 0)
    {
      allControls$ICPC_PChapterBeforeCutoff[count]  <- paste(allBefore, collapse = " ")
      # allControls$ICPC_majorPChapterBeforeCutoff[count]  <- paste(unique(substr(allBefore, 1, 3)), collapse = " ")
    }
    
    if (length(allAfter) > 0)
    {
      allControls$ICPC_PChapterAfterCutoff[count]   <- paste(allAfter, collapse = " ")
      # allControls$ICPC_majorPChapterAfterCutoff[count]  <- paste(unique(substr(allAfter, 1, 3)), collapse = " ")
    }
  }
  count <- count + 1
}

ff <- function(x) paste(substr(x, 1, 3), collapse = " ")
allControls$NPR_majorFChapterBeforeCutoff <- lapply(strsplit(x = allControls$NPR_FChapterBeforeCutoff, split = " "), ff)
allControls$NPR_majorFChapterAfterCutoff  <- lapply(strsplit(x = allControls$NPR_FChapterAfterCutoff, split = " "), ff)
allControls$NPR_majorFChapterBeforePredCutoff  <- lapply(strsplit(x = allControls$NPR_FChapterBeforePredCutoff, split = " "), ff)

allControls$KUHR_majorFChapterBeforeCutoff  <- lapply(strsplit(x = allControls$KUHR_FChapterBeforeCutoff, split = " "), ff)
allControls$KUHR_majorFChapterAfterCutoff  <- lapply(strsplit(x = allControls$KUHR_FChapterAfterCutoff, split = " "), ff)
allControls$KUHR_majorFChapterBeforePredCutoff  <- lapply(strsplit(x = allControls$KUHR_FChapterBeforePredCutoff, split = " "), ff)

allControls$ICPC_majorPChapterBeforeCutoff  <- lapply(strsplit(x = allControls$ICPC_PChapterBeforeCutoff, split = " "), ff)
allControls$ICPC_majorPChapterAfterCutoff  <- lapply(strsplit(x = allControls$ICPC_PChapterAfterCutoff, split = " "), ff)


fwrite(allControls, file = "/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/source/2024-12-17_allControls_diagInfo.csv", row.names = F)

# For the cases:
# 1) anyone with a F2* diagonses + ICPC after (Q14 response + 6 months)
# 2) for the ones without Q14 response, consider 14*365: diagnoses after this day
# 3) anyone with a F2* diagnoses + ICPC before Q14 response needs to be eliminated
# 4) for the ones without Q14 response, consider 14*365: diagnoses prior to this day needs to be eliminated

# For the controls:
# anyone left over

# NPR predictors:
# (Age 14 - 6 months) | (Q14 response): any F chapter diagnoses
# (Age 14 - 6 months) | (Q14 response): any F chapter diagnoses in parents before this date
