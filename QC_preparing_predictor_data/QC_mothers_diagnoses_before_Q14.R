###Data source: 
###diagnostic registries NPR and KUHR

library(data.table)
library(tidyverse)
library(haven)

# Run NPR script ----------------------------------------------------------
setwd("N:/durable/users/avbirken/Paper_3/complete_QC_data/datasets/firstDiag")
load("df_NPR.Rda")
#### if diagnostic data is updated, the original getDiagInfo script must be rerun

mothers_NPR <- df_NPR %>%
  rename("ID_2445" = ID2445)
mothers_NPR <- subset(mothers_NPR, grepl("^M", ID_2445))

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

# merge with mothers_NPR diagnoses 
mothers_NPR2 <- merge(mothers_NPR, tmp1[, c("M_ID_2445", "ID_2445", "PREG_ID_2445", "FAAR", "ChildNumber")], by.x = "ID_2445", by.y = "M_ID_2445")

#add variable indicating when the child turned 14 years ----
mothers_NPR2$turned_14 <- (mothers_NPR2$FAAR + 14)

# creating new variable - diagnosis_before_after_14years -----------------
mothers_NPR3 <-  mothers_NPR2 %>%
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

mothers_NPR4 <- mothers_NPR3 %>%
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
  mothers_NPR4[[var]] <- ifelse(is.na(mothers_NPR4[[var]]) | mothers_NPR4[[var]] == "after", 0, 1)
}


##### New variables ----
mothers_NPR5 <- mothers_NPR4 %>%
  mutate(mothers_NPR_ICD_before_Q14 = as.numeric(rowSums(across(starts_with("F")))> 0),) %>% # mothers_NPR_ICD_before_Q14
  mutate(mothers_NPR_F2_or_F31_before_Q14 = as.numeric(rowSums(across(starts_with("F2") | starts_with("F31")))> 0),) # mothers_NPR_F2_or_F31_before_Q14

####NB: Number indicates the number of children with a mother diagnosed before the child turned 14, not the number of mothers_NPR

  
# Retrieve KUHR script ----------------------------------------------------------
setwd("N:/durable/users/avbirken/Paper_3/complete_QC_data/datasets/firstDiag")
load("df_KUHR.Rda")

mothers_KUHR <- df_KUHR %>%
  rename("ID_2445" = ID2445)

mothers_KUHR <- subset(mothers_KUHR, grepl("^M", ID_2445))

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

# join with mothers_KUHR diagnoses 
mothers_KUHR2 <- merge(mothers_KUHR, tmp1[, c("M_ID_2445", "ID_2445", "PREG_ID_2445", "FAAR", "ChildNumber")], by.x = "ID_2445", by.y = "M_ID_2445")

#add variable indicating when the child turned 14 years ----
mothers_KUHR2$turned_14 <- (mothers_KUHR2$FAAR + 14)

# creating new variable - diagnosis_before_after_14years -----------------
mothers_KUHR3 <-  mothers_KUHR2 %>%
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

mothers_KUHR4 <- mothers_KUHR3 %>%
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
  mothers_KUHR4[[var]] <- ifelse(is.na(mothers_KUHR4[[var]]) | mothers_KUHR4[[var]] == "after", 0, 1)
}


##### New variables ----
mothers_KUHR5 <- mothers_KUHR4 %>%
  mutate(mothers_KUHR_ICD_before_Q14 = as.numeric(rowSums(across(starts_with("F")))> 0),) %>% # mothers_KUHR_ICD_before_Q14
  mutate(mothers_KUHR_F2_or_F31_before_Q14 = as.numeric(rowSums(across(starts_with("F2") | starts_with("F31")))> 0),) # mothers_KUHR_F2_or_F31_before_Q14

#### merge diagnostic DFs together -----
mothers_combined <- merge(mothers_NPR5[, c( "ID_2445", "PREG_ID_2445", "mothers_ICD_before_Q14", "mothers_F2_or_F31_before_Q14")],
                          mothers_KUHR5[, c( "ID_2445", "PREG_ID_2445", "mothers_KUHR_ICD_before_Q14", "mothers_KUHR_F2_or_F31_before_Q14")],
                          by =  "ID_2445", all = TRUE)

#create combined diagnostic variables
mothers_combined$mothers_any_ICD <- ifelse(mothers_combined$mothers_ICD_before_Q14 == 1 |
                                                mothers_combined$mothers_KUHR_ICD_before_Q14 == 1, 1, 0)

mothers_combined$mothers_F2_or_F31 <- ifelse(mothers_combined$mothers_F2_or_F31_before_Q14 == 1 |
                                         mothers_combined$mothers_KUHR_F2_or_F31_before_Q14 == 1, 1, 0)

mothers_diagn_before_Q14 <- mothers_combined %>%
  select(c(-mothers_ICD_before_Q14, -mothers_F2_or_F31_before_Q14,
           -mothers_KUHR_ICD_before_Q14, -mothers_KUHR_F2_or_F31_before_Q14))

#FINAL DATASET FOR USE IN ANALYSES -----
setwd("N:/durable/users/avbirken/Paper_3/complete_QC_data/datasets/Granular diagnostic datasets")
save("mothers_diagn_before_Q14", file = "mothers_diagn_before_Q14.Rda")




