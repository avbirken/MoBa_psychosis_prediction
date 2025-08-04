library(haven)
library(data.table)

setwd("/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/source")
listFiles <- as.list(dir(pattern = ".Rda"))

# Remove irrelevant files
listFiles <- setdiff(listFiles, c("diagnostic_predictors.Rda", "any_ICD_or_ICPC_psychosis.Rda", "BUP_subset.Rda"))
for (entries in listFiles)
{
  load(entries)
}

# Read diagnostic predictor subject list
allCases    <- read.csv("/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/source/2024-12-17_allCases.csv")
allControls <- read.csv("/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/source/2024-12-17_allControls.csv")

# Create a large list of IDs
allIDs <- c(cape_9_complete_cases$ID_2445,     allCases$ID_2445, allControls$ID_2445,
            pre_perinatal_predictors$ID_2445,  PRS_ADHD$ID_2445, 
            PRS_ASD$ID_2445,                   PRS_BIP$ID_2445,
            PRS_MDD$ID_2445,                   PRS_SCZ$ID_2445, 
            Q14_adolescent_predictors$ID_2445)

# Subset to unique
uniqueIDs <- unique(allIDs)

# Split into child ID and PREG_ID_2445
tmp  <- strsplit(uniqueIDs, split = "_")
tmp1 <- sapply(tmp, "[")

# Put together
data <- as.data.frame(cbind(uniqueIDs, tmp1[1,], tmp1[2,]))
colnames(data) <- c("ID_2445", "PREG_ID_2445", "ChildNumber")

# Clear up workspace
workspace <- ls()
workspace <- workspace[workspace != "data"]
rm(list = workspace)
gc()

# Read the consent file
info <- read_sav("/tsd/p697/data/durable/phenotypes/sv_infofiles/PDB2445_SV_INFO_V12_20241101.sav")

# Fuse consent and participant list
toUse <- merge(data, info, by = "PREG_ID_2445")

# Read the file with birth number
infoBirth <- read_sav("/tsd/p697/data/durable/phenotypes/npr/2024-08-06/PDB2445_kobling_NPR_MoBa_20240605/PDB2445_DELTAKERLISTE_GYLDIG_FNR_SAMTYKKE.sav")

# Read kobling file for NPR
kobling_FID   <- read_sav("/tsd/p697/data/durable/phenotypes/npr/2024-08-06/PDB2445_kobling_NPR_MoBa_20240605/Far_ID_2445_20240528.sav")
kobling_MID   <- read_sav("/tsd/p697/data/durable/phenotypes/npr/2024-08-06/PDB2445_kobling_NPR_MoBa_20240605/Mor_ID_2445_20240528.sav")
kobling_Child <- read_sav("/tsd/p697/data/durable/phenotypes/npr/2024-08-06/PDB2445_kobling_NPR_MoBa_20240605/Barn_ID_2445_20240528.sav")

# Create ID2445 for children
kobling_Child$ID_2445 <- paste0(kobling_Child$PREG_ID_2445, "_", kobling_Child$BARN_NR)

# Find out the people who do not have valid birth number
linked_FID   <- merge(kobling_FID,   infoBirth, by.x = "PID_2445", by.y = "pid_2445")
linked_MID   <- merge(kobling_MID,   infoBirth, by.x = "PID_2445", by.y = "pid_2445")
linked_Child <- merge(kobling_Child, infoBirth, by.x = "PID_2445", by.y = "pid_2445") 

# Only fathers have invalid birth number!
wch_FID <- linked_FID$F_ID_2445[linked_FID$Gyldig_fnr == 0]

# Who are the children of these fathers
wch_Children <- toUse$ID_2445[toUse$F_ID_2445 %in% wch_FID]

# Remove these children
toUse <- toUse[!(toUse$ID_2445 %in% wch_Children),]

# 2025-02-05: marking any subject for whom we do not have info after 18 years
dirNPR      <- '/ess/p697/cluster/users/parekh/2023-08-14_parseNPR'
dirKUHR     <- '/ess/p697/cluster/users/parekh/2023-10-24_KUHR'
colsToRead  <- c("ID_2445", "Role","PREG_ID_2445", "ChildNumber", "WithdrawnConsent18years")
dataNPR     <- fread(file = file.path(dirNPR, "2024-09-19-MoBa-ParsedNPR_majorCodes.csv"), sep = "\t", header = TRUE, 
                     select = colsToRead, data.table = FALSE)
dataKUHR   <- fread(file = file.path(dirKUHR, "2024-09-19-MoBa-ParsedKUHR-ICD10-majorCodes.csv"), sep = "\t", header = TRUE, 
                     select = colsToRead, data.table = FALSE)

# Shrink dataNPR
dataNPR  <- dataNPR[dataNPR$ID_2445 %in% toUse$ID_2445,]
dataKUHR <- dataKUHR[dataKUHR$ID_2445 %in% toUse$ID_2445,]

# Add a column to toUse for NPR consent
toUse_xx <- merge(toUse, dataNPR,  all.x = T)
toUse_yy <- merge(toUse, dataKUHR, all.x = T)

# Rename column
colnames(toUse_xx)[colnames(toUse_xx) == "WithdrawnConsent18years"] <- "Consent_NPR"
colnames(toUse_yy)[colnames(toUse_yy) == "WithdrawnConsent18years"] <- "Consent_KUHR"

# Merge these two
toUse <- merge(toUse_xx, toUse_yy, all.x = T)

# 2024-Dec-17 - note that:
# 1) There are 104 PREG_ID_2445 that are not in MBRN
# 2) There are 106 ID_2445 that are not in MBRN
# 3) For PREG_ID_2445 85265, 85265_2 is missing
# 4) For PREG_ID_2445 92263, 92263_0 is missing

# Get birth related information
dirMBRN   <- "/tsd/p697/data/durable/phenotypes/mbrn/"
dataMBRN  <- read_sav(file.path(dirMBRN, "PDB2445_MFR_541_v12", "PDB2445_MFR_541_v12.sav"))
infoMBRN  <- read_sav(file.path(dirMBRN, "PDB2445_MBRN_541_v12.sav"))

# ID_2445
infoMBRN$ID_2445 <- paste0(infoMBRN$PREG_ID_2445, "_", infoMBRN$BARN_NR)
dataMBRN$ID_2445 <- paste0(dataMBRN$PREG_ID_2445, "_", dataMBRN$BARN_NR)

# Ensure that all people in toUse are actually in the MBRN
# There are 106 ID_2445 that are not in MBRN (or 104 pregnancy IDs)
toUse <- toUse[toUse$ID_2445 %in% infoMBRN$ID_2445,]

# Read the before Q14 case list and make sure they are not present
allBefore <- read.csv("/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/source/2024-12-17_diagBeforeQ14.csv")

toRetain <- setdiff(toUse$ID_2445, allBefore$ID_2445)
toUse    <- toUse[toUse$ID_2445 %in% toRetain,]

# Save
write.csv(toUse, "/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/work/IDList.csv", row.names = F)