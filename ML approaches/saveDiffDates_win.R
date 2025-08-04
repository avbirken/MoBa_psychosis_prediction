library(data.table)
library(tidyverse)
library(haven)
dirNPR   <- "Z:/users/parekh/2023-08-14_parseNPR"
dirKUHR  <- "Z:/users/parekh/2023-10-24_KUHR"
dirWork  <- "Z:/users/parekh/2024-11-11_predictionPsychosis_VB/work"

allIDs   <- fread(file.path(dirWork, "IDList.csv"))

# Read NPR
dataNPR <- fread(file.path(dirNPR, "2024-09-19-MoBa-LinkedNPR-Children.csv"))
dataNPR$ID2445 <- paste0(dataNPR$PREG_ID_2445, "_", dataNPR$ChildNumber)

# Read KUHR
dataKUHR <- fread(file.path(dirKUHR, "2024-09-19-MoBa-LinkedKUHR-Children.csv"))
dataKUHR$ID2445 <- paste0(dataKUHR$PREG_ID_2445, "_", dataKUHR$ChildNumber)

# Subset NPR
dataNPR <- dataNPR[dataNPR$ID2445 %in% allIDs$ID_2445, ]

# Subset KUHR
dataKUHR <- dataKUHR[dataKUHR$ID2445 %in% allIDs$ID_2445, ]

# Codes to keep - NPR
codes <- c("F20", "F21", "F22", "F23", "F24", "F25", "F26", "F27", "F28", "F29")
locs_NPR  <- data.frame(matrix(data = FALSE, nrow=nrow(dataNPR), ncol=length(codes)))
count <- 1
for (cc in codes)
{
  locs_NPR[,count] <- grepl(glob2rx(paste0(cc, "*")), dataNPR$Diagnosis_ICDCode)
  count <- count + 1
}
anyL_NPR <- as.logical(rowSums(locs_NPR))
dataNPR <- dataNPR[anyL_NPR,]

# Codes to keep - KUHR ICD
codes <- c("F20", "F21", "F22", "F23", "F24", "F25", "F26", "F27", "F28", "F29")
locs_KUHR  <- data.frame(matrix(data = FALSE, nrow=nrow(dataKUHR), ncol=length(codes)))
count <- 1
for (cc in codes)
{
  locs_KUHR[,count] <- grepl(glob2rx(paste0(cc, "*")), dataKUHR$Diagnosis) & 
                  !grepl(glob2rx("*ICPC*"), dataKUHR$DiagnosticManual)
  count <- count + 1
}
anyL_KUHR <- as.logical(rowSums(locs_KUHR))
dataKUHR_ICD <- dataKUHR[anyL_KUHR,]

# Codes to keep - ICPC
codes <- c("P72", "P98")
locs_ICPC  <- data.frame(matrix(data = FALSE, nrow=nrow(dataKUHR), ncol=length(codes)))
count <- 1
for (cc in codes)
{
  locs_ICPC[,count] <- grepl(glob2rx(paste0(cc, "*")), dataKUHR$Diagnosis) & 
                      grepl(glob2rx("*ICPC*"), dataKUHR$DiagnosticManual)
  count <- count + 1
}
anyL_ICPC <- as.logical(rowSums(locs_ICPC))
dataKUHR_ICPC <- dataKUHR[anyL_ICPC,]


####
uqKUHR_ICPC <- unique(dataKUHR_ICPC$ID2445)
diffDays_KUHR_ICPC <- data.frame(matrix(nrow = length(uqKUHR_ICPC), ncol = 1))
count <- 1
for (uq in uqKUHR_ICPC)
{
  diffDays_KUHR_ICPC[count,1] <- min(dataKUHR_ICPC$DiffDays[dataKUHR_ICPC$ID2445 %in% uq])
  count <- count + 1
}
diffDays_KUHR_ICPC <- cbind(uqKUHR_ICPC, diffDays_KUHR_ICPC)

colnames(diffDays_KUHR_ICPC)
diffDays_KUHR_ICPC <- diffDays_KUHR_ICPC %>%
  rename("ID_2445" = "uqKUHR_ICPC",
         "diffDays_KUHR_ICPC_variable" = "matrix.nrow...length.uqKUHR_ICPC...ncol...1.")

##
uqNPR <- unique(dataNPR$ID2445)
diffDays_NPR <- data.frame(matrix(nrow = length(uqNPR), ncol = 1))
count <- 1
for (uq in uqNPR)
{
  diffDays_NPR[count,1] <- min(dataNPR$DiffDays_Admission[dataNPR$ID2445 %in% uq])
  count <- count + 1
}
diffDays_NPR <- cbind(uqNPR, diffDays_NPR)

diffDays_NPR <- diffDays_NPR %>%
  rename("ID_2445" = "uqNPR",
         "diffDays_NPR_ICD_variable" = "matrix.nrow...length.uqNPR...ncol...1.")

##
uqKUHR <- unique(dataKUHR_ICD$ID2445)
diffDays_KUHR <- data.frame(matrix(nrow = length(uqKUHR), ncol = 1))
count <- 1
for (uq in uqKUHR)
{
  diffDays_KUHR[count,1] <- min(dataKUHR_ICD$DiffDays[dataKUHR_ICD$ID2445 %in% uq])
  count <- count + 1
}
diffDays_KUHR <- cbind(uqKUHR, diffDays_KUHR)
## after a quick look, it's apparent that all instances of diffdates 
#in this dataframe that are under 2109 are F27 diagnoses given by eye-doctors
# these diagnoses need to go out

diffDays_KUHR <- diffDays_KUHR %>%
  rename("ID_2445" = "uqKUHR",
         "diffDays_KUHR_ICD_variable" = "matrix.nrow...length.uqKUHR...ncol...1.")


# Saving all files --------------------------------------------------------
setwd(dirWork  <- "Z:/users/parekh/2024-11-11_predictionPsychosis_VB/scripts/saveDiffDates")
save("dataKUHR_ICPC", file = "dataKUHR_ICPC.csv")
save("dataNPR", file = "dataNPR.csv")
save("dataKUHR_ICD", file = "dataKUHR_ICD.csv")

save("diffDays_KUHR_ICPC", file = "diffDays_KUHR_ICPC.csv")
save("diffDays_NPR", file = "diffDays_NPR.csv")
save("diffDays_KUHR", file = "diffDays_KUHR.csv")


# One, merged file --------------------------------------------------------
load("diffDays_KUHR_ICPC.csv")
load("diffDays_NPR.csv")
load("diffDays_KUHR.csv")


#subset DFs with individuals over 14 years
ICPC_filtered <- subset(diffDays_KUHR_ICPC, diffDays_KUHR_ICPC_variable > 5475) 
NPR_filtered <- subset(diffDays_NPR, diffDays_NPR_ICD_variable > 5475) 
KUHR_filtered <- subset(diffDays_KUHR, diffDays_KUHR_ICD_variable > 5475) 
#351

tmp1 <- merge(ICPC_filtered, NPR_filtered, by = "ID_2445", all = T)
tmp2 <- merge(tmp1, KUHR_filtered, by = "ID_2445", all = T)


# Merge with Q14 response date --------------------------------------------
Q14_response   <- read_sav("N:/durable/phenotypes/mobaQ/PDB2445_V12_Q14/2024-03-07/PDB2445_Ungdomsskjema_Barn_v12_spesielle.sav")
Q14_response$ID_2445 <- paste0(Q14_response$PREG_ID_2445, "_", Q14_response$BARN_NR)

Q14_response <- Q14_response %>%
  select(c("ID_2445", "AGE_MTHS_UB" ))

tmp3 <- merge(tmp2, Q14_response, by = "ID_2445", all.x = T)
colnames(tmp3)

tmp4 <- tmp3 %>%
  mutate(age_yrs_NPR_ICD = (diffDays_NPR_ICD_variable/365),
        age_yrs_KUHR_ICD = (diffDays_KUHR_ICD_variable/365),
        age_yrs_KUHR_ICPC = (diffDays_KUHR_ICPC_variable/365),
        age_yrs_Q14 = (AGE_MTHS_UB/12)) %>%
  mutate(diff_Q14_NPR_ICD = (age_yrs_NPR_ICD - age_yrs_Q14),
         diff_Q14_KUHR_ICD = (age_yrs_KUHR_ICD - age_yrs_Q14),
         diff_Q14_KUHR_ICPC = (age_yrs_KUHR_ICPC - age_yrs_Q14))

#filter out these with diff smaller than 6 months (0.5 cut-off) between Q14 response and time of diagnosis
less_than_6months <- subset(tmp4, diff_Q14_NPR_ICD < 0.5 | diff_Q14_KUHR_ICD < 0.5 | diff_Q14_KUHR_ICPC < 0.5)
    #5 observations

# ICPC diagnoses under 15 years 
#ICPC_under_15 <- subset(tmp4, diffDays_KUHR_ICPC_variable < 5475) 
   #54 observations

#problematic KUHR ICD (eye doctor diagnoses)
#problem_KUHR <- subset(tmp4, diffDays_KUHR_ICD_variable < 2109) 
    #0 observations

#remove IDs with less than 6 months between response and diagnosis
cases_correct_age <- tmp4[!(tmp4$ID_2445 %in% less_than_6months$ID_2445),]
    #346

setwd("Z:/users/parekh/2024-11-11_predictionPsychosis_VB/scripts/saveDiffDates")
save("cases_correct_age", file = "cases_correct_age.csv")


# Create new list of cases ------------------------------------------------
cases_ICD_and_ICPC <- cases_correct_age %>%
  select(ID_2445) %>%
  mutate(ICD_or_ICPC_psychosis = 1)

setwd("Z:/users/parekh/2024-11-11_predictionPsychosis_VB/scripts/saveDiffDates")
save("cases_ICD_and_ICPC", file = "cases_ICD_and_ICPC.csv")

