###Data sources: 
###Diagnostic registries NPR and KUHR

library(data.table)
library(tidyverse)
library(haven)

# Run NPR script ----------------------------------------------------------
setwd("N:/durable/users/avbirken/Paper_3/complete_QC_data/getDiagInfo_script/firstDiag")
load("df_NPR.Rda")

#### NB #####
#### if diagnostic data is updated, then the original detDiagInfo script must be rerun
children_NPR <- df_NPR %>%
  rename("ID_2445" = ID2445)

# Remove IDs starting with "F" or "M"
children_NPR <- subset(children_NPR, !(substr(ID_2445, 1, 1) %in% c("F", "M")))
colnames(children_NPR)

#complete participant list
complete_IDs <- read.delim(
  "Z:/users/parekh/2023-08-14_parseNPR/2024-08-09-MoBa-CompleteParticipantList.csv", sep = "\t")

# merge complete list and MBRN to get parent IDs and unique IDs
MBRN <- read_sav("N:/durable/phenotypes/mbrn/PDB2445_MBRN_541_v12.sav")
MBRN <- MBRN %>%
  rename("ChildNumber" = BARN_NR) 
tmp1 <- merge(complete_IDs, MBRN[, c("PREG_ID_2445", "FAAR", "ChildNumber")], by = "PREG_ID_2445", all.x = T)

#create unique child ID
tmp1$ID_2445 <- paste(tmp1$PREG_ID_2445, tmp1$ChildNumber, sep = "_")

# merge with children_NPR diagnoses 
children_NPR2 <- merge(children_NPR, tmp1[, c("ID_2445", "PREG_ID_2445", "FAAR", "ChildNumber")], by = "ID_2445", all = T)

#add variable indicating when the child turned 14 years ----
children_NPR2$turned_14 <- (children_NPR2$FAAR + 14)

# creating new variable - diagnosis_before_after_14years -----------------
children_NPR3 <-  children_NPR2 %>%
  mutate(F10_before_after_14years = ifelse(F10 < turned_14,
                                           "before", "after"),
         F11_before_after_14years = ifelse(F11 < turned_14,
                                           "before", "after"),
         F12_before_after_14years = ifelse(F12 < turned_14,
                                           "before", "after"),
         F13_before_after_14years = ifelse(F13 < turned_14,
                                           "before", "after"),
         F14_before_after_14years = ifelse(F14 < turned_14,
                                           "before", "after"),
         F15_before_after_14years = ifelse(F15 < turned_14,
                                           "before", "after"),
         F16_before_after_14years = ifelse(F16 < turned_14,
                                           "before", "after"),
         F17_before_after_14years = ifelse(F17 < turned_14,
                                           "before", "after"),
         F18_before_after_14years = ifelse(F18 < turned_14,
                                           "before", "after"),
         F19_before_after_14years = ifelse(F19 < turned_14,
                                           "before", "after"),
         F20_before_after_14years = ifelse(F20 < turned_14,
                                           "before", "after"),
         F21_before_after_14years = ifelse(F21 < turned_14,
                                           "before", "after"),
         F22_before_after_14years = ifelse(F22 < turned_14,
                                           "before", "after"),
         F23_before_after_14years = ifelse(F23 < turned_14,
                                           "before", "after"),
         F24_before_after_14years = ifelse(F24 < turned_14,
                                           "before", "after"),
         F25_before_after_14years = ifelse(F25 < turned_14,
                                           "before", "after"),
         F28_before_after_14years = ifelse(F28 < turned_14,
                                           "before", "after"),
         F29_before_after_14years = ifelse(F29 < turned_14,
                                           "before", "after"),
         F31_before_after_14years = ifelse(F31 < turned_14,
                                           "before", "after"),
         F32_before_after_14years = ifelse(F32 < turned_14,
                                           "before", "after"),
         F33_before_after_14years = ifelse(F33 < turned_14,
                                           "before", "after"),
         F34_before_after_14years = ifelse(F33 < turned_14,
                                           "before", "after"),
         F38_before_after_14years = ifelse(F33 < turned_14,
                                           "before", "after"),
         F39_before_after_14years = ifelse(F33 < turned_14,
                                           "before", "after"),
         F40_before_after_14years = ifelse(F40 < turned_14,
                                           "before", "after"),
         F41_before_after_14years = ifelse(F41 < turned_14,
                                           "before", "after"),
         F42_before_after_14years = ifelse(F42 < turned_14,
                                           "before", "after"),
         F43_before_after_14years = ifelse(F43 < turned_14,
                                           "before", "after"),
         F45_before_after_14years = ifelse(F45 < turned_14,
                                           "before", "after"),
         F48_before_after_14years = ifelse(F45 < turned_14,
                                           "before", "after"),
         F50_before_after_14years = ifelse(F50 < turned_14,
                                           "before", "after"),
         F60_before_after_14years = ifelse(F60 < turned_14,
                                           "before", "after"),
         F70_before_after_14years = ifelse(F70 < turned_14,
                                           "before", "after"),
         F78_before_after_14years = ifelse(F78 < turned_14,
                                           "before", "after"),
         F79_before_after_14years = ifelse(F79 < turned_14,
                                           "before", "after"),
         F80_before_after_14years = ifelse(F80 < turned_14,
                                           "before", "after"),
         F81_before_after_14years = ifelse(F81 < turned_14,
                                           "before", "after"),
         F82_before_after_14years = ifelse(F82 < turned_14,
                                           "before", "after"),
         F83_before_after_14years = ifelse(F83 < turned_14,
                                           "before", "after"),
         F84_before_after_14years = ifelse(F84 < turned_14,
                                           "before", "after"),
         F84_before_after_14years = ifelse(F84 < turned_14,
                                           "before", "after"),
         F90_before_after_14years = ifelse(F90 < turned_14,
                                           "before", "after"),
         F91_before_after_14years = ifelse(F90 < turned_14,
                                           "before", "after"),
         F92_before_after_14years = ifelse(F90 < turned_14,
                                           "before", "after"),
         F93_before_after_14years = ifelse(F90 < turned_14,
                                           "before", "after"))
#select variables
children_NPR4 <- children_NPR3 %>%
 select(c(ID_2445, "PREG_ID_2445","ChildNumber", 51:94))

#### change values to 0 if NA or "after"
vars_to_replace <- c("F10_before_after_14years", "F11_before_after_14years", "F12_before_after_14years",
                     "F13_before_after_14years", "F14_before_after_14years", "F15_before_after_14years", 
                     "F16_before_after_14years", "F17_before_after_14years", "F18_before_after_14years", "F19_before_after_14years",
                     "F20_before_after_14years", 
                     "F21_before_after_14years",  
                     "F22_before_after_14years", 
                     "F23_before_after_14years",
                     "F24_before_after_14years", 
                     "F25_before_after_14years",  
                     "F28_before_after_14years", 
                     "F29_before_after_14years",   
                     "F31_before_after_14years", "F32_before_after_14years" , "F34_before_after_14years", 
                     "F38_before_after_14years", "F39_before_after_14years",
                     "F40_before_after_14years",  
                     "F41_before_after_14years",  
                     "F42_before_after_14years", 
                     "F43_before_after_14years",  
                     "F45_before_after_14years", 
                     "F48_before_after_14years",
                     "F50_before_after_14years",  
                     "F60_before_after_14years",
                     "F70_before_after_14years", "F78_before_after_14years", "F79_before_after_14years",
                     "F80_before_after_14years", "F81_before_after_14years", "F82_before_after_14years", 
                     "F83_before_after_14years", "F84_before_after_14years",
                     "F90_before_after_14years", "F91_before_after_14years", 
                     "F92_before_after_14years", "F93_before_after_14years")

for (var in vars_to_replace) {
  children_NPR4[[var]] <- ifelse(is.na(children_NPR4[[var]]) | children_NPR4[[var]] == "after", 0, 1)
}

##### New variables ----
#children_NPR5 <- children_NPR4 %>%
#  mutate(children_NPR_ICD_before_Q14 = as.numeric(rowSums(across(starts_with("F")))> 0),) # children_NPR_ICD_before_Q14

# Retrieve KUHR script ----------------------------------------------------------
setwd("N:/durable/users/avbirken/Paper_3/complete_QC_data/getDiagInfo_script/firstDiag")
load("df_KUHR.Rda")

children_KUHR <- df_KUHR %>%
  rename("ID_2445" = ID2445)

# Remove IDs starting with "F" or "M"
children_KUHR <- subset(children_KUHR, !(substr(ID_2445, 1, 1) %in% c("F", "M")))

#complete participant list
complete_IDs <- read.delim(
  "Z:/users/parekh/2023-08-14_parseNPR/2024-08-09-MoBa-CompleteParticipantList.csv", sep = "\t")

# merge complete list and MBRN to get parent IDs and unique IDs
MBRN <- read_sav("N:/durable/phenotypes/mbrn/PDB2445_MBRN_541_v12.sav")
MBRN <- MBRN %>%
  rename("ChildNumber" = BARN_NR) 
tmp1 <- merge(complete_IDs, MBRN[, c("PREG_ID_2445", "FAAR", "ChildNumber")], by = "PREG_ID_2445", all.x = T)

#create unique child ID
tmp1$ID_2445 <- paste(tmp1$PREG_ID_2445, tmp1$ChildNumber, sep = "_")

# merge with children_KUHR diagnoses 
children_KUHR2 <- merge(children_KUHR, tmp1[, c("ID_2445", "PREG_ID_2445", "FAAR", "ChildNumber")], by = "ID_2445", all = T)

#add variable indicating when the child turned 14 years ----
children_KUHR2$turned_14 <- (children_KUHR2$FAAR + 14)

# creating new variable - diagnosis_before_after_14years -----------------
children_KUHR3 <-  children_KUHR2 %>%
  mutate(F10_before_after_14years = ifelse(F10 < turned_14,
                                           "before", "after"),
         F11_before_after_14years = ifelse(F11 < turned_14,
                                           "before", "after"),
         F12_before_after_14years = ifelse(F12 < turned_14,
                                           "before", "after"),
         F13_before_after_14years = ifelse(F13 < turned_14,
                                           "before", "after"),
         F14_before_after_14years = ifelse(F14 < turned_14,
                                           "before", "after"),
         F15_before_after_14years = ifelse(F15 < turned_14,
                                           "before", "after"),
         F16_before_after_14years = ifelse(F16 < turned_14,
                                           "before", "after"),
         F17_before_after_14years = ifelse(F17 < turned_14,
                                           "before", "after"),
         F18_before_after_14years = ifelse(F18 < turned_14,
                                           "before", "after"),
         F19_before_after_14years = ifelse(F19 < turned_14,
                                           "before", "after"),
         F20_before_after_14years = ifelse(F20 < turned_14,
                                           "before", "after"),
         F21_before_after_14years = ifelse(F21 < turned_14,
                                           "before", "after"),
         F22_before_after_14years = ifelse(F22 < turned_14,
                                           "before", "after"),
         F23_before_after_14years = ifelse(F23 < turned_14,
                                           "before", "after"),
         F24_before_after_14years = ifelse(F24 < turned_14,
                                           "before", "after"),
         F25_before_after_14years = ifelse(F25 < turned_14,
                                           "before", "after"),
         F28_before_after_14years = ifelse(F28 < turned_14,
                                           "before", "after"),
         F29_before_after_14years = ifelse(F29 < turned_14,
                                           "before", "after"),
         F31_before_after_14years = ifelse(F31 < turned_14,
                                           "before", "after"),
         F32_before_after_14years = ifelse(F32 < turned_14,
                                           "before", "after"),
         F33_before_after_14years = ifelse(F33 < turned_14,
                                           "before", "after"),
         F40_before_after_14years = ifelse(F40 < turned_14,
                                           "before", "after"),
         F41_before_after_14years = ifelse(F41 < turned_14,
                                           "before", "after"),
         F42_before_after_14years = ifelse(F42 < turned_14,
                                           "before", "after"),
         F43_before_after_14years = ifelse(F43 < turned_14,
                                           "before", "after"),
         F45_before_after_14years = ifelse(F45 < turned_14,
                                           "before", "after"),
         F50_before_after_14years = ifelse(F50 < turned_14,
                                           "before", "after"),
         F60_before_after_14years = ifelse(F60 < turned_14,
                                           "before", "after"),
         F80_before_after_14years = ifelse(F80 < turned_14,
                                           "before", "after"),
         F81_before_after_14years = ifelse(F81 < turned_14,
                                           "before", "after"),
         F82_before_after_14years = ifelse(F82 < turned_14,
                                           "before", "after"),
         F83_before_after_14years = ifelse(F83 < turned_14,
                                           "before", "after"),
         F84_before_after_14years = ifelse(F84 < turned_14,
                                           "before", "after"),
         F84_before_after_14years = ifelse(F84 < turned_14,
                                           "before", "after"),
         F90_before_after_14years = ifelse(F90 < turned_14,
                                           "before", "after"),
         F91_before_after_14years = ifelse(F90 < turned_14,
                                           "before", "after"),
         F92_before_after_14years = ifelse(F90 < turned_14,
                                           "before", "after"),
         F93_before_after_14years = ifelse(F90 < turned_14,
                                           "before", "after"))
#select variables
children_KUHR4 <- children_KUHR3 %>%
  select(c(ID_2445, "PREG_ID_2445","ChildNumber", 43:79))

#### change values to 0 if NA or "after"
vars_to_replace <- c("F10_before_after_14years", "F11_before_after_14years", "F12_before_after_14years",
                     "F13_before_after_14years", "F14_before_after_14years", "F15_before_after_14years", 
                     "F16_before_after_14years", "F17_before_after_14years", "F18_before_after_14years", "F19_before_after_14years",
                     "F20_before_after_14years", 
                     "F21_before_after_14years",  
                     "F22_before_after_14years", 
                     "F23_before_after_14years",
                     "F24_before_after_14years", 
                     "F25_before_after_14years",  
                     "F28_before_after_14years", 
                     "F29_before_after_14years",   
                     "F31_before_after_14years", "F32_before_after_14years", "F33_before_after_14years",
                     "F40_before_after_14years",  
                     "F41_before_after_14years",  
                     "F42_before_after_14years", 
                     "F43_before_after_14years",  
                     "F45_before_after_14years",  
                     "F50_before_after_14years",  
                     "F60_before_after_14years",
                     "F80_before_after_14years", "F81_before_after_14years", "F82_before_after_14years", "F83_before_after_14years",
                     "F84_before_after_14years",
                     "F90_before_after_14years", "F91_before_after_14years", "F92_before_after_14years", "F93_before_after_14years")

###binarize variable so that it indicates whether the person had a diagnosis before Q14
for (var in vars_to_replace) {
  children_KUHR4[[var]] <- ifelse(is.na(children_KUHR4[[var]]) | children_KUHR4[[var]] == "after", 0, 1)
}


##### New variables ----
#children_KUHR5 <- children_KUHR4 %>%
 # mutate(children_KUHR_ICD_before_Q14 = as.numeric(rowSums(across(starts_with("F")))> 0),) 

#### merge diagnostic DFs together -----
children_combined <- merge(children_NPR4,
                          children_KUHR4,
                          by =  "ID_2445", all = TRUE)
    setwd("N:/durable/users/avbirken/Paper_3/complete_QC_data/datasets/Granular diagnostic datasets")
    save("children_combined", file="children_combined.Rda") 
    
    
#create combined diagnostic variables
tmp <- children_combined %>%
  mutate(F1X_chapter_C = as.numeric(rowSums(across(starts_with("F1")))> 0),
         F2X_chapter_C = as.numeric(rowSums(across(starts_with("F2")))> 0),
         F31_C = as.numeric(rowSums(across(starts_with("F31")))> 0),
         F32_C = as.numeric(rowSums(across(starts_with("F32")))> 0),
         F33_C = as.numeric(rowSums(across(starts_with("F33")))> 0),
         F4X_chapter_C = as.numeric(rowSums(across(starts_with("F4")))> 0),
         F50_C = as.numeric(rowSums(across(starts_with("F5")))> 0),
         F60_C = as.numeric(rowSums(across(starts_with("F6")))> 0),
         F8X_chapter_C = as.numeric(rowSums(across(starts_with("F8")))> 0),
         F84_C = as.numeric(rowSums(across(starts_with("F84")))> 0),
         F90_C = as.numeric(rowSums(across(starts_with("F90")))> 0),
         F91_C = as.numeric(rowSums(across(starts_with("F91")))> 0),
         F92_C = as.numeric(rowSums(across(starts_with("F92")))> 0),
         F93_C = as.numeric(rowSums(across(starts_with("F93")))> 0),)

# Replace NA values with 0
tmp[is.na(tmp)] <- 0

children_diagn_before_Q14 <- tmp %>%
  select(c("ID_2445", "PREG_ID_2445.x", "ChildNumber.x", "PREG_ID_2445.y", "ChildNumber.y",
           "F1X_chapter_C", "F31_C", "F32_C", "F33_C",                
           "F4X_chapter_C","F50_C", "F60_C", 
           "F8X_chapter_C", "F84_C", 
           "F90_C","F91_C", "F92_C", "F93_C"
           ))

#DATASET FOR USE IN ANALYSES -----
setwd("N:/durable/users/avbirken/Paper_3/complete_QC_data/datasets/Granular diagnostic datasets")
save("children_diagn_before_Q14", file="children_diagn_before_Q14.Rda") 


