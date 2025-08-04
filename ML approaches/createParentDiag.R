# Get diagnostic information on parents
library(data.table)
library(haven)

# Set paths
dirNPR    <- "/ess/p697/cluster/users/parekh/2023-08-14_parseNPR"
dirKUHR   <- "/ess/p697/cluster/users/parekh/2023-10-24_KUHR"
dirInfo   <- "/tsd/p697/data/durable/phenotypes/sv_infofiles"
dirPhen   <- "/tsd/p697/data/durable/phenotypes/mobaQ/PDB2445_V12_Q14/2024-03-07"
dirWork   <- "/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/work"
dirSource <- "/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/source"
dirMBRN   <- "/tsd/p697/data/durable/phenotypes/mbrn/"

# dirNPR    <- "Z:/cluster/users/parekh/2023-08-14_parseNPR"
# dirKUHR   <- "Z:/cluster/users/parekh/2023-10-24_KUHR"
# dirInfo   <- "Z:/data/durable/phenotypes/sv_infofiles"
# dirPhen   <- "Z:/data/durable/phenotypes/mobaQ/PDB2445_V12_Q14/2024-03-07"
# dirWork   <- "Z:/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/work"
# dirSource <- "Z:/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/source"
# dirMBRN   <- "Z:/data/durable/phenotypes/mbrn/"

# Read data
dataNPR      <- fread(file.path(dirNPR,     "2024-09-19-MoBa-LinkedNPR-AllSubjects.csv"))
dataKUHR     <- fread(file.path(dirKUHR,    "2024-09-19-MoBa-LinkedKUHR-AllSubjects.csv"))
allIDs       <- fread(file.path(dirWork,    "IDList_ParentID.csv"))
infoCases    <- fread(file.path(dirSource,  "2024-12-17_allCases_diagInfo.csv"))
infoControls <- fread(file.path(dirSource,  "2024-12-17_allControls_diagInfo.csv"))
dataInfo     <- read_sav(file.path(dirInfo, "PDB2445_SV_INFO_V12_20241101.sav"))
Q14resp      <- read_sav(file.path(dirPhen, "PDB2445_Ungdomsskjema_Barn_v12_spesielle.sav"))
dataMBRN     <- read_sav(file.path(dirMBRN, "PDB2445_MFR_541_v12", "PDB2445_MFR_541_v12.sav"))
infoMBRN     <- read_sav(file.path(dirMBRN, "PDB2445_MBRN_541_v12.sav"))

# Create ID_2445
infoMBRN$ID_2445 <- paste0(infoMBRN$PREG_ID_2445, "_", infoMBRN$BARN_NR)
dataMBRN$ID_2445 <- paste0(dataMBRN$PREG_ID_2445, "_", dataMBRN$BARN_NR)
dataNPR$ID_2445  <- paste0(dataNPR$PREG_ID_2445,  "_", dataNPR$ChildNumber)
dataKUHR$ID_2445 <- paste0(dataKUHR$PREG_ID_2445, "_", dataKUHR$ChildNumber)
Q14resp$ID_2445  <- paste0(Q14resp$PREG_ID_2445,  "_", Q14resp$BARN_NR)

# Make sure everyone is in INFO file
Q14resp  <- Q14resp[Q14resp$PREG_ID_2445   %in% dataInfo$PREG_ID_2445, ]
dataMBRN <- dataMBRN[dataMBRN$PREG_ID_2445 %in% dataInfo$PREG_ID_2445, ]
infoMBRN <- infoMBRN[infoMBRN$PREG_ID_2445 %in% dataInfo$PREG_ID_2445, ]

# Make a list of all subjects and their cutoff_predictor dates
infoCases     <- infoCases[,    c("ID_2445", "YOB", "MOB", "Age_mnths_Q14", "cutoff", "cutoff_predictor")]
infoControls  <- infoControls[, c("ID_2445", "YOB", "MOB", "Age_mnths_Q14", "cutoff", "cutoff_predictor")]
infoAllSubjs  <- merge(infoCases, infoControls, all = T)

# There are 17 kids in infoAllSubjs who are not in allIDs - likely due to fathers having invalid FNR
# These will get removed down the line
# For the kids not in infoAllSubjs but in allIDs, create cutoff dates: no one
# 23 of these 60 kids have responded to Q14, remaining have not
remChildren <- setdiff(allIDs$ID_2445, infoAllSubjs$ID_2445)

# Put information together for these remChildren
infoRemChildren <- data.frame(matrix(data = NA, nrow=length(remChildren), ncol = 4))
colnames(infoRemChildren) <- c("ID_2445", "YOB", "MOB", "Age_mnths_Q14")
count <- 1
for (ids in remChildren)
{
  infoRemChildren$ID_2445[count]       <- ids
  infoRemChildren$YOB[count]           <- infoMBRN$FAAR[infoMBRN$ID_2445 %in% ids]
  infoRemChildren$MOB[count]           <- dataMBRN$FMND[dataMBRN$ID_2445 %in% ids]
  if (sum(Q14resp$ID_2445 %in% ids) > 0)
  {
    infoRemChildren$Age_mnths_Q14[count] <- Q14resp$AGE_MTHS_UB[Q14resp$ID_2445 %in% ids]
  }
  count <- count + 1
}

# Cast MOB as integer
infoRemChildren$MOB <- as.integer(infoRemChildren$MOB)

# For subjects who responded to Q14, create Q14+6mnths period; the ones who did not, 14 years
locs <- is.na(infoRemChildren$Age_mnths_Q14)
infoRemChildren$cutoff[!locs] <- (infoRemChildren$Age_mnths_Q14[!locs] + 6)/12 * 365
infoRemChildren$cutoff[locs]  <- 14*365
infoRemChildren$cutoff_predictor <- infoRemChildren$cutoff - (6/12*365)

# Merge infoRemChildren and infoAllSubjs
# Nothing to merge
if(nrow(infoRemChildren > 0))
{
  infoAllSubjs <- merge(infoAllSubjs, infoRemChildren, all = T)
}

# Merge infoAllSubjs to allIDs - lose 17 children
allIDs <- merge(allIDs, infoAllSubjs, by = "ID_2445")

# Add case status to allIDs
allIDs$caseStatus <- 0
allIDs$caseStatus[allIDs$ID_2445 %in% infoCases$ID_2445] <- 1

# Create a parent predictor cut off year
allIDs$cutoff_parent_predictor_Year <- round(allIDs$cutoff_predictor/365) + allIDs$YOB

# Save this information
fwrite(allIDs, "/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/work/IDList_ParentID_cutoffInfo.csv")


# From NPR, get rid of NCMP, NCSP, and empty diagnostic rows
dataNPR <- dataNPR[!(dataNPR$Diagnosis_ICDCode == "" | dataNPR$ManualName == "NCMP" | dataNPR$ManualName == "NCSP"),]

# From KUHR, get rid of empty diagnostic rows
dataKUHR <- dataKUHR[!dataKUHR$Diagnosis == "",]

# In KUHR, there are rows having various diagnostic codes but no manual specified: ignoring these
dataKUHR <- dataKUHR[!dataKUHR$DiagnosticManual == "", ]

# Within KUHR, remove "2.16.578.1.12.4.1.1.71.7170" and ICD-9
dataKUHR <- dataKUHR[!(dataKUHR$DiagnosticManual == "ICD-9" | dataKUHR$DiagnosticManual == "2.16.578.1.12.4.1.1.71.7170"),]

# Get rid of rows where M_ID_2445 or F_ID_2445 are empty (children)
dataNPR  <- dataNPR[!(dataNPR$M_ID_2445   == "" & dataNPR$F_ID_2445 == ""), ]
dataKUHR <- dataKUHR[!(dataKUHR$M_ID_2445 == "" & dataKUHR$F_ID_2445 == ""),]

# Further reduce the memory burden
dataKUHR <- dataKUHR[, c("PracticeType", "DiffDays", "Diagnosis", "DiagnosticManual", "Year", "M_ID_2445", "F_ID_2445")]
dataNPR  <- dataNPR[,  c("Year", "DiffDays_Admission", "DiffDays_Discharge", "InstitutionID", "ManualName", "ManualType", "Diagnosis_ICDCode", "M_ID_2445", "F_ID_2445")]

# Make a list of all fathers and all mothers to work with
allMothers <- allIDs$M_ID_2445
allFathers <- allIDs$F_ID_2445
allMothers <- allMothers[allMothers != ""]
allFathers <- allFathers[allFathers != ""]

# Retain data on consenting individuals and split into mothers and fathers
locs_NPR_M <- dataNPR$M_ID_2445 %in% dataInfo$M_ID_2445
locs_NPR_F <- dataNPR$F_ID_2445 %in% dataInfo$F_ID_2445

locs_KUHR_M <- dataKUHR$M_ID_2445 %in% dataInfo$M_ID_2445
locs_KUHR_F <- dataKUHR$F_ID_2445 %in% dataInfo$F_ID_2445

dataNPR_M  <- dataNPR[locs_NPR_M,]
dataNPR_F  <- dataNPR[locs_NPR_F,]
dataKUHR_M <- dataKUHR[locs_KUHR_M,]
dataKUHR_F <- dataKUHR[locs_KUHR_F,]

# Remove NPR and KUHR info for parents that are not relevant to present study
dataNPR_M <- dataNPR_M[dataNPR_M$M_ID_2445 %in% allMothers,]
dataNPR_F <- dataNPR_F[dataNPR_F$F_ID_2445 %in% allFathers,]

dataKUHR_M <- dataKUHR_M[dataKUHR_M$M_ID_2445 %in% allMothers,]
dataKUHR_F <- dataKUHR_F[dataKUHR_F$F_ID_2445 %in% allFathers,]

# Get rid of any ICD diagnoses outside of F chapter
dataNPR_F <- dataNPR_F[grepl(glob2rx("*F*"), dataNPR_F$Diagnosis_ICDCode), ]
dataNPR_M <- dataNPR_M[grepl(glob2rx("*F*"), dataNPR_M$Diagnosis_ICDCode), ]

# Get rid of any ICD diagnoses outside of F chapter if non-ICPC and outside P chapter if outside ICD
loc1 <- grepl(glob2rx("*F*"), dataKUHR_F$Diagnosis) & !grepl(glob2rx("*ICPC*"), dataKUHR_F$DiagnosticManual)
loc2 <- grepl(glob2rx("*P*"), dataKUHR_F$Diagnosis) &  grepl(glob2rx("*ICPC*"), dataKUHR_F$DiagnosticManual)
dataKUHR_F <- dataKUHR_F[loc1 | loc2, ]
loc1 <- grepl(glob2rx("*F*"), dataKUHR_M$Diagnosis) & !grepl(glob2rx("*ICPC*"), dataKUHR_M$DiagnosticManual)
loc2 <- grepl(glob2rx("*P*"), dataKUHR_M$Diagnosis) &  grepl(glob2rx("*ICPC*"), dataKUHR_M$DiagnosticManual)
dataKUHR_M <- dataKUHR_M[loc1 | loc2, ]

# Clear up RAM
rm(dataNPR)
rm(dataKUHR)
rm(list = c("locs_NPR_M", "locs_NPR_F", "locs_KUHR_M", "locs_KUHR_F"))
rm(list = c("dataInfo", "dataMBRN", "infoAllSubjs", "infoCases", "infoControls", "infoMBRN", "infoRemChildren"))
rm(remChildren)
rm(Q14resp)
gc()

# For every parent, put together all diagnoses before and including the year of cutoff
# Instead of looping over every parent, loop over years and lump info
diagInfo_Mothers <- data.frame(matrix(data = NA, nrow=nrow(allIDs), ncol = 7))
colnames(diagInfo_Mothers) <- c("M_ID_2445", "Diag_F_NPR", "Diag_Fmajor_NPR", "Diag_F_KUHR", "Diag_Fmajor_KUHR", "Diag_P_ICPC", "Diag_Pmajor_ICPC")

diagInfo_Fathers <- data.frame(matrix(data = NA, nrow=nrow(allIDs), ncol = 7))
colnames(diagInfo_Fathers) <- c("F_ID_2445", "Diag_F_NPR", "Diag_Fmajor_NPR", "Diag_F_KUHR", "Diag_Fmajor_KUHR", "Diag_P_ICPC", "Diag_Pmajor_ICPC")

count <- 1
# Work on parents
for (count in 1:nrow(allIDs))
{
  if(count %% 100 == 0)
  {
    print(paste0("count = ", count, "; ", Sys.time()))
  }
  
  # Mother and father ID for this subject
  tmp_M_ID <- allIDs$M_ID_2445[count]
  tmp_F_ID <- allIDs$F_ID_2445[count]
  
  diagInfo_Mothers$M_ID_2445[count] <- tmp_M_ID
  diagInfo_Fathers$F_ID_2445[count] <- tmp_F_ID
  
  # First, work on mothers
  if (tmp_M_ID %in% dataNPR_M$M_ID_2445)
  {
    # Subset NPR
    tmp_info <- unique(dataNPR_M$Diagnosis_ICDCode[dataNPR_M$M_ID_2445 %in% tmp_M_ID & dataNPR_M$Year <= allIDs$cutoff_parent_predictor_Year[count]])
    tmp_info <- tmp_info[nzchar(tmp_info)]
    
    # Save this information - NPR
    if (length(tmp_info) > 0)
    {
      diagInfo_Mothers$Diag_F_NPR[count]      <- paste(tmp_info, collapse = " ")
      # diagInfo_Mothers$Diag_Fmajor_NPR[count] <- paste(unique(substr(tmp_info[grepl("^F", tmp_info)], 1, 3)), collapse = " ")
    }
  }
  
  if (tmp_M_ID %in% dataKUHR_M$M_ID_2445)
  {
    # Subset KUHR
    tmpKUHR_M <- dataKUHR_M[dataKUHR_M$M_ID_2445 %in% tmp_M_ID,]
    tmp_info  <- unique(tmpKUHR_M$Diagnosis[!grepl(glob2rx("*ICPC*"), tmpKUHR_M$DiagnosticManual) & 
                                              tmpKUHR_M$Year <= allIDs$cutoff_parent_predictor_Year[count]])
    tmp_info <- tmp_info[nzchar(tmp_info)]
    tmp_info <- unique(gsub("^ ", "", unlist(strsplit(tmp_info, ","))))
    tmp_info <- tmp_info[grepl("^F", tmp_info)]
    
    # Save this information - KUHR
    if (length(tmp_info) > 0)
    {
      diagInfo_Mothers$Diag_F_KUHR[count]      <- paste(tmp_info, collapse = " ")
      # diagInfo_Mothers$Diag_Fmajor_KUHR[count] <- paste(unique(substr(tmp_info[grepl("^F", tmp_info)], 1, 3)), collapse = " ")
    }
    
    # Subset ICPC
    tmp_info  <- unique(tmpKUHR_M$Diagnosis[grepl(glob2rx("*ICPC*"), tmpKUHR_M$DiagnosticManual) & 
                                              tmpKUHR_M$Year <= allIDs$cutoff_parent_predictor_Year[count]])
    tmp_info <- tmp_info[nzchar(tmp_info)]
    tmp_info <- unique(gsub("^ ", "", unlist(strsplit(tmp_info, ","))))
    tmp_info <- tmp_info[grepl("^P", tmp_info)]
    
    # Save this information - ICPC
    if (length(tmp_info) > 0)
    {
      diagInfo_Mothers$Diag_P_ICPC[count]      <- paste(tmp_info, collapse = " ")
      # diagInfo_Mothers$Diag_Pmajor_ICPC[count] <- paste(unique(substr(tmp_info[grepl("^P", tmp_info)], 1, 3)), collapse = " ")
    }
  }
  
  # Now work on fathers
  if (tmp_F_ID %in% dataNPR_F$F_ID_2445)
  {
    # Subset NPR
    tmp_info <- unique(dataNPR_F$Diagnosis_ICDCode[dataNPR_F$F_ID_2445 %in% tmp_F_ID & dataNPR_F$Year <= allIDs$cutoff_parent_predictor_Year[count]])
    tmp_info <- tmp_info[nzchar(tmp_info)]
    
    # Save this information - NPR
    if (length(tmp_info) > 0)
    {
      diagInfo_Fathers$Diag_F_NPR[count]      <- paste(tmp_info, collapse = " ")
      # diagInfo_Fathers$Diag_Fmajor_NPR[count] <- paste(unique(substr(tmp_info[grepl("^F", tmp_info)], 1, 3)), collapse = " ")
    }
  }
  
  if (tmp_F_ID %in% dataKUHR_F$F_ID_2445)
  {
    # Subset KUHR
    tmpKUHR_F <- dataKUHR_F[dataKUHR_F$F_ID_2445 %in% tmp_F_ID,]
    tmp_info  <- unique(tmpKUHR_F$Diagnosis[!grepl(glob2rx("*ICPC*"), tmpKUHR_F$DiagnosticManual) & 
                                              tmpKUHR_F$Year <= allIDs$cutoff_parent_predictor_Year[count]])
    tmp_info <- tmp_info[nzchar(tmp_info)]
    tmp_info <- unique(gsub("^ ", "", unlist(strsplit(tmp_info, ","))))
    tmp_info <- tmp_info[grepl("^F", tmp_info)]
    
    # Save this information - KUHR
    if (length(tmp_info) > 0)
    {
      diagInfo_Fathers$Diag_F_KUHR[count]      <- paste(tmp_info, collapse = " ")
      # diagInfo_Fathers$Diag_Fmajor_KUHR[count] <- paste(unique(substr(tmp_info[grepl("^F", tmp_info)], 1, 3)), collapse = " ")
    }
    
    # Subset ICPC
    tmp_info  <- unique(tmpKUHR_F$Diagnosis[grepl(glob2rx("*ICPC*"), tmpKUHR_F$DiagnosticManual) & 
                                              tmpKUHR_F$Year <= allIDs$cutoff_parent_predictor_Year[count]])
    tmp_info <- tmp_info[nzchar(tmp_info)]
    tmp_info <- unique(gsub("^ ", "", unlist(strsplit(tmp_info, ","))))
    tmp_info <- tmp_info[grepl("^P", tmp_info)]
    
    # Save this information - ICPC
    if (length(tmp_info) > 0)
    {
      diagInfo_Fathers$Diag_P_ICPC[count]      <- paste(tmp_info, collapse = " ")
      # diagInfo_Fathers$Diag_Pmajor_ICPC[count] <- paste(unique(substr(tmp_info[grepl("^P", tmp_info)], 1, 3)), collapse = " ")
    }
  }
}

ff <- function(x) paste(substr(x, 1, 3), collapse = " ")
diagInfo_Mothers$Diag_Fmajor_NPR  <- lapply(strsplit(x = diagInfo_Mothers$Diag_F_NPR,  split = " "), ff)
diagInfo_Mothers$Diag_Fmajor_KUHR <- lapply(strsplit(x = diagInfo_Mothers$Diag_F_KUHR, split = " "), ff)
diagInfo_Mothers$Diag_Pmajor_ICPC <- lapply(strsplit(x = diagInfo_Mothers$Diag_P_ICPC, split = " "), ff)

diagInfo_Fathers$Diag_Fmajor_NPR  <- lapply(strsplit(x = diagInfo_Fathers$Diag_F_NPR,  split = " "), ff)
diagInfo_Fathers$Diag_Fmajor_KUHR <- lapply(strsplit(x = diagInfo_Fathers$Diag_F_KUHR, split = " "), ff)
diagInfo_Fathers$Diag_Pmajor_ICPC <- lapply(strsplit(x = diagInfo_Fathers$Diag_P_ICPC, split = " "), ff)


fwrite(diagInfo_Mothers, file = "/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/source/2024-12-17_diagInfo-Mothers.csv", row.names = F)
fwrite(diagInfo_Fathers, file = "/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/source/2024-12-17_diagInfo-Fathers.csv", row.names = F)

# # Work on parents
# for (ids in allIDs$ID_2445)
# {
#   if(count %% 100 == 0)
#   {
#     print(paste0("count = ", count))
#   }
#   
#   # Mother and father ID for this subject
#   tmp_M_ID <- allIDs$M_ID_2445[count]
#   tmp_F_ID <- allIDs$F_ID_2445[count]
#   
#   # First, work on mothers
#   if (tmp_M_ID %in% dataNPR_M$M_ID_2445)
#   {
#     # Subset NPR
#     tmp_info <- unique(dataNPR_M$Diagnosis_ICDCode[dataNPR_M$M_ID_2445 %in% tmp_M_ID & dataNPR_M$Year <= allIDs$cutoff_parent_predictor_Year[count]])
#     tmp_info <- tmp_info[nzchar(tmp_info)]
#     
#     # Save this information - NPR
#     if (length(tmp_info) > 0)
#     {
#       diagInfo_Mothers$Diag_NPR[count]        <- paste(tmp_info, collapse = " ")
#       diagInfo_Mothers$Diag_F_NPR[count]      <- paste(tmp_info[grepl("^F", tmp_info)], collapse = " ")
#       diagInfo_Mothers$Diag_Fmajor_NPR[count] <- paste(unique(substr(tmp_info[grepl("^F", tmp_info)], 1, 3)), collapse = " ")
#     }
#   }
#   
#   if (tmp_M_ID %in% dataKUHR_M$M_ID_2445)
#   {
#     # Subset KUHR
#     tmpKUHR_M <- dataKUHR_M[dataKUHR_M$M_ID_2445 %in% tmp_M_ID,]
#     tmp_info  <- unique(tmpKUHR_M$Diagnosis[!grepl(glob2rx("*ICPC*"), tmpKUHR_M$DiagnosticManual) & 
#                                             tmpKUHR_M$Year <= allIDs$cutoff_parent_predictor_Year[count]])
#     tmp_info <- tmp_info[nzchar(tmp_info)]
#     tmp_info <- unique(gsub("^ ", "", unlist(strsplit(tmp_info, ","))))
#     tmp_info <- tmp_info[grepl("^[A-Z]", tmp_info)]
#     
#     # Save this information - KUHR
#     if (length(tmp_info) > 0)
#     {
#       diagInfo_Mothers$Diag_KUHR[count]        <- paste(tmp_info, collapse = " ")
#       diagInfo_Mothers$Diag_F_KUHR[count]      <- paste(tmp_info[grepl("^F", tmp_info)], collapse = " ")
#       diagInfo_Mothers$Diag_Fmajor_KUHR[count] <- paste(unique(substr(tmp_info[grepl("^F", tmp_info)], 1, 3)), collapse = " ")
#     }
#     
#     # Subset ICPC
#     tmp_info  <- unique(tmpKUHR_M$Diagnosis[grepl(glob2rx("*ICPC*"), tmpKUHR_M$DiagnosticManual) & 
#                                             tmpKUHR_M$Year <= allIDs$cutoff_parent_predictor_Year[count]])
#     tmp_info <- tmp_info[nzchar(tmp_info)]
#     tmp_info <- unique(gsub("^ ", "", unlist(strsplit(tmp_info, ","))))
#     tmp_info <- tmp_info[grepl("^[A-Z]", tmp_info)]
#     
#     # Save this information - ICPC
#     if (length(tmp_info) > 0)
#     {
#       diagInfo_Mothers$Diag_ICPC[count]        <- paste(tmp_info, collapse = " ")
#       diagInfo_Mothers$Diag_P_ICPC[count]      <- paste(tmp_info[grepl("^P", tmp_info)], collapse = " ")
#       diagInfo_Mothers$Diag_Pmajor_ICPC[count] <- paste(unique(substr(tmp_info[grepl("^P", tmp_info)], 1, 3)), collapse = " ")
#     }
#   }
#   
#   # Now work on fathers
#   if (tmp_F_ID %in% dataNPR_F$F_ID_2445)
#   {
#     # Subset NPR
#     tmp_info <- unique(dataNPR_F$Diagnosis_ICDCode[dataNPR_F$F_ID_2445 %in% tmp_F_ID & dataNPR_F$Year <= allIDs$cutoff_parent_predictor_Year[count]])
#     tmp_info <- tmp_info[nzchar(tmp_info)]
#     
#     # Save this information - NPR
#     if (length(tmp_info) > 0)
#     {
#       diagInfo_Fathers$Diag_NPR[count]        <- paste(tmp_info, collapse = " ")
#       diagInfo_Fathers$Diag_F_NPR[count]      <- paste(tmp_info[grepl("^F", tmp_info)], collapse = " ")
#       diagInfo_Fathers$Diag_Fmajor_NPR[count] <- paste(unique(substr(tmp_info[grepl("^F", tmp_info)], 1, 3)), collapse = " ")
#     }
#   }
#   
#   if (tmp_F_ID %in% dataKUHR_F$F_ID_2445)
#   {
#     # Subset KUHR
#     tmpKUHR_F <- dataKUHR_F[dataKUHR_F$F_ID_2445 %in% tmp_F_ID,]
#     tmp_info  <- unique(tmpKUHR_F$Diagnosis[!grepl(glob2rx("*ICPC*"), tmpKUHR_F$DiagnosticManual) & 
#                                               tmpKUHR_F$Year <= allIDs$cutoff_parent_predictor_Year[count]])
#     tmp_info <- tmp_info[nzchar(tmp_info)]
#     tmp_info <- unique(gsub("^ ", "", unlist(strsplit(tmp_info, ","))))
#     tmp_info <- tmp_info[grepl("^[A-Z]", tmp_info)]
#     
#     # Save this information - KUHR
#     if (length(tmp_info) > 0)
#     {
#       diagInfo_Fathers$Diag_KUHR[count]        <- paste(tmp_info, collapse = " ")
#       diagInfo_Fathers$Diag_F_KUHR[count]      <- paste(tmp_info[grepl("^F", tmp_info)], collapse = " ")
#       diagInfo_Fathers$Diag_Fmajor_KUHR[count] <- paste(unique(substr(tmp_info[grepl("^F", tmp_info)], 1, 3)), collapse = " ")
#     }
#     
#     # Subset ICPC
#     tmp_info  <- unique(tmpKUHR_F$Diagnosis[grepl(glob2rx("*ICPC*"), tmpKUHR_F$DiagnosticManual) & 
#                                               tmpKUHR_F$Year <= allIDs$cutoff_parent_predictor_Year[count]])
#     tmp_info <- tmp_info[nzchar(tmp_info)]
#     tmp_info <- unique(gsub("^ ", "", unlist(strsplit(tmp_info, ","))))
#     tmp_info <- tmp_info[grepl("^[A-Z]", tmp_info)]
#     
#     # Save this information - ICPC
#     if (length(tmp_info) > 0)
#     {
#       diagInfo_Fathers$Diag_ICPC[count]        <- paste(tmp_info, collapse = " ")
#       diagInfo_Fathers$Diag_P_ICPC[count]      <- paste(tmp_info[grepl("^P", tmp_info)], collapse = " ")
#       diagInfo_Fathers$Diag_Pmajor_ICPC[count] <- paste(unique(substr(tmp_info[grepl("^P", tmp_info)], 1, 3)), collapse = " ")
#     }
#   }
#   
#   # Update count
#   count <- count + 1
# }