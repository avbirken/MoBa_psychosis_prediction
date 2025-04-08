###Data sources: 
###Diagnostic registries NPR and KUHR

library(data.table)
library(tidyverse)
library(haven)

# Run NPR script ----------------------------------------------------------
setwd("N:/durable/users/avbirken/Paper 3/complete_QC_data/datasets/firstDiag")
load("df_NPR.Rda")

#### NB:
#### If diagnostic data is updated, then the original detDiagInfo script must be rerun

fathers_NPR <- df_NPR %>%
  rename("ID_2445" = ID2445)
fathers_NPR <- subset(fathers_NPR, grepl("^F", ID_2445))

#complete participant list
complete_IDs <- read.delim(
  "Z:/users/parekh/2023-08-14_parseNPR/2024-03-11-MoBa-CompleteParticipantList.csv", sep = "\t")

# merge complete list and MBRN to get parent IDs and unique IDs
MBRN <- read_sav("N:/durable/phenotypes/mbrn/PDB2445_MBRN_541_v12.sav")
MBRN <- MBRN %>%
  rename("ChildNumber" = BARN_NR) 

tmp1 <- merge(complete_IDs, MBRN[, c("PREG_ID_2445", "FAAR", "ChildNumber")], by = "PREG_ID_2445", all.x = T)

#create unique child ID
tmp1$ID_2445 <- paste(tmp1$PREG_ID_2445, tmp1$ChildNumber, sep = "_")

# merge with fathers_NPR diagnoses 
fathers_NPR2 <- merge(fathers_NPR, tmp1[, c("F_ID_2445", "ID_2445", "PREG_ID_2445", "FAAR", "ChildNumber")], by.x = "ID_2445", by.y = "F_ID_2445")

#add variable indicating when the child turned 14 years ----
fathers_NPR2$turned_14 <- (fathers_NPR2$FAAR + 14)

# creating new variable - diagnosis_before_after_14years -----------------
fathers_NPR3 <-  fathers_NPR2 %>%
  mutate(F20_before_after_14years = ifelse(F20 < turned_14,
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
         F84_before_after_14years = ifelse(F84 < turned_14,
                                           "before", "after"),
         F90_before_after_14years = ifelse(F90 < turned_14,
                                           "before", "after"))

fathers_NPR4 <- fathers_NPR3 %>%
  select(c(ID_2445, "PREG_ID_2445","ChildNumber",  
           "F20_before_after_14years", 
           "F21_before_after_14years",  
           "F22_before_after_14years", 
           "F23_before_after_14years",
           "F24_before_after_14years",
           "F25_before_after_14years" ,  
           "F28_before_after_14years" , 
           "F29_before_after_14years" ,   
           "F31_before_after_14years" ,  
           "F32_before_after_14years" ,  
           "F40_before_after_14years" ,  
           "F41_before_after_14years" ,  
           "F42_before_after_14years" , 
           "F43_before_after_14years" ,  
           "F45_before_after_14years" ,  
           "F50_before_after_14years" ,  
           "F60_before_after_14years",
           "F84_before_after_14years",
           "F90_before_after_14years"))

#### change values to 0 if NA or "after"
vars_to_replace <- c("F20_before_after_14years", 
                     "F21_before_after_14years",  
                     "F22_before_after_14years", 
                     "F23_before_after_14years",
                     "F24_before_after_14years" , 
                     "F25_before_after_14years" ,  
                     "F28_before_after_14years" , 
                     "F29_before_after_14years" ,   
                     "F31_before_after_14years" ,  
                     "F32_before_after_14years" ,  
                     "F40_before_after_14years" ,  
                     "F41_before_after_14years" ,  
                     "F42_before_after_14years" , 
                     "F43_before_after_14years" ,  
                     "F45_before_after_14years" ,  
                     "F50_before_after_14years" ,  
                     "F60_before_after_14years",
                     "F84_before_after_14years",
                     "F90_before_after_14years")

for (var in vars_to_replace) {
  fathers_NPR4[[var]] <- ifelse(is.na(fathers_NPR4[[var]]) | fathers_NPR4[[var]] == "after", 0, 1)
}


##### New variables ----
fathers_NPR5 <- fathers_NPR4 %>%
  mutate(fathers_NPR_ICD_before_Q14 = as.numeric(rowSums(across(starts_with("F")))> 0),) %>% # fathers_NPR_ICD_before_Q14
  mutate(fathers_NPR_F2_or_F31_before_Q14 = as.numeric(rowSums(across(starts_with("F2") | starts_with("F31")))> 0),) # fathers_NPR_F2_or_F31_before_Q14

####NB: Number indicates the number of children with a father diagnosed before the child turned 14, not the number of fathers_NPR


# Retrieve KUHR script ----------------------------------------------------------
setwd("N:/durable/users/avbirken/Paper 3/complete_QC_data/datasets/firstDiag")
load("df_KUHR.Rda")

fathers_KUHR <- df_KUHR %>%
  rename("ID_2445" = ID2445)
fathers_KUHR <- subset(fathers_KUHR, grepl("^F", ID_2445))

#complete participant list
complete_IDs <- read.delim(
  "Z:/users/parekh/2023-08-14_parseNPR/2024-03-11-MoBa-CompleteParticipantList.csv", sep = "\t")
colnames(complete_IDs)

# merge complete list and MBRN to get parent IDs and unique IDs
MBRN <- read_sav("N:/durable/phenotypes/mbrn/PDB2445_MBRN_541_v12.sav")
MBRN <- MBRN %>%
  rename("ChildNumber" = BARN_NR) 
tmp1 <- merge(complete_IDs, MBRN[, c("PREG_ID_2445", "FAAR", "ChildNumber")], by = "PREG_ID_2445", all.x = T)

#create unique child ID
tmp1$ID_2445 <- paste(tmp1$PREG_ID_2445, tmp1$ChildNumber, sep = "_")

# join with fathers_KUHR diagnoses 
fathers_KUHR2 <- merge(fathers_KUHR, tmp1[, c("F_ID_2445", "ID_2445", "PREG_ID_2445", "FAAR", "ChildNumber")], by.x = "ID_2445", by.y = "F_ID_2445")

#add variable indicating when the child turned 14 years ----
fathers_KUHR2$turned_14 <- (fathers_KUHR2$FAAR + 14)

# creating new variable - diagnosis_before_after_14years -----------------
fathers_KUHR3 <-  fathers_KUHR2 %>%
  mutate(F20_before_after_14years = ifelse(F20 < turned_14,
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
         F84_before_after_14years = ifelse(F84 < turned_14,
                                           "before", "after"),
         F90_before_after_14years = ifelse(F90 < turned_14,
                                           "before", "after"))

fathers_KUHR4 <- fathers_KUHR3 %>%
  select(c(ID_2445, "PREG_ID_2445","ChildNumber",  
           "F20_before_after_14years", 
           "F21_before_after_14years",  
           "F22_before_after_14years", 
           "F23_before_after_14years",
           "F24_before_after_14years",
           "F25_before_after_14years" ,  
           "F28_before_after_14years" , 
           "F29_before_after_14years" ,   
           "F31_before_after_14years" ,  
           "F32_before_after_14years" ,  
           "F40_before_after_14years" ,  
           "F41_before_after_14years" ,  
           "F42_before_after_14years" , 
           "F43_before_after_14years" ,  
           "F45_before_after_14years" ,  
           "F50_before_after_14years" ,  
           "F60_before_after_14years",
           "F84_before_after_14years",
           "F90_before_after_14years"))

#### change values to 0 if NA or "after"
vars_to_replace <- c("F20_before_after_14years", 
                     "F21_before_after_14years",  
                     "F22_before_after_14years", 
                     "F23_before_after_14years",
                     "F24_before_after_14years" , 
                     "F25_before_after_14years" ,  
                     "F28_before_after_14years" , 
                     "F29_before_after_14years" ,   
                     "F31_before_after_14years" ,  
                     "F32_before_after_14years" ,  
                     "F40_before_after_14years" ,  
                     "F41_before_after_14years" ,  
                     "F42_before_after_14years" , 
                     "F43_before_after_14years" ,  
                     "F45_before_after_14years" ,  
                     "F50_before_after_14years" ,  
                     "F60_before_after_14years",
                     "F84_before_after_14years",
                     "F90_before_after_14years")

for (var in vars_to_replace) {
  fathers_KUHR4[[var]] <- ifelse(is.na(fathers_KUHR4[[var]]) | fathers_KUHR4[[var]] == "after", 0, 1)
}


##### New variables ----
fathers_KUHR5 <- fathers_KUHR4 %>%
  mutate(fathers_KUHR_ICD_before_Q14 = as.numeric(rowSums(across(starts_with("F")))> 0),) %>% # fathers_KUHR_ICD_before_Q14
  mutate(fathers_KUHR_F2_or_F31_before_Q14 = as.numeric(rowSums(across(starts_with("F2") | starts_with("F31")))> 0),) # fathers_KUHR_F2_or_F31_before_Q14

####NB: Number indicates the number of children with a father diagnosed before the child turned 14, not the number of fathers_KUHR


#### merge diagnostic DFs together -----
fathers_combined <- merge(fathers_NPR5[, c( "ID_2445", "PREG_ID_2445", "fathers_NPR_ICD_before_Q14", "fathers_NPR_F2_or_F31_before_Q14")],
                          fathers_KUHR5[, c( "ID_2445", "PREG_ID_2445", "fathers_KUHR_ICD_before_Q14", "fathers_KUHR_F2_or_F31_before_Q14")],
                          by =  "ID_2445", all = TRUE)

#create combined diagnostic variables
fathers_combined$fathers_any_ICD <- ifelse(fathers_combined$fathers_NPR_ICD_before_Q14 == 1 |
                                             fathers_combined$fathers_KUHR_ICD_before_Q14 == 1, 1, 0)

fathers_combined$fathers_F2_or_F31 <- ifelse(fathers_combined$fathers_NPR_F2_or_F31_before_Q14 == 1 |
                                               fathers_combined$fathers_KUHR_F2_or_F31_before_Q14 == 1, 1, 0)

fathers_diagn_before_Q14 <- fathers_combined %>%
  select(c(-fathers_NPR_ICD_before_Q14, -fathers_NPR_F2_or_F31_before_Q14,
           -fathers_KUHR_ICD_before_Q14, -fathers_KUHR_F2_or_F31_before_Q14))

#FINAL DATASET FOR USE IN ANALYSES -----
setwd("N:/durable/users/avbirken/Paper 3/complete_QC_data/datasets/Granular diagnostic datasets")
save("fathers_diagn_before_Q14", file="fathers_diagn_before_Q14.Rda") 







