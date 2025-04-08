library(tidyverse)

####### combine mothers fathers and childrens diagnoses: 
setwd("N:/durable/users/avbirken/Paper_3/complete_QC_data/datasets/Granular diagnostic datasets")
load("mothers_diagn_before_Q14.Rda")
load("fathers_diagn_before_Q14.Rda")
load("children_diagn_before_Q14.Rda")

##### need to separate parent IDs and child IDs 
mothers_diagn_before_Q14 <- mothers_diagn_before_Q14 %>%
  rename("M_ID" = ID_2445,
         "PREG_ID_2445" = PREG_ID_2445.y) %>%
  select(-PREG_ID_2445.x)

fathers_diagn_before_Q14 <- fathers_diagn_before_Q14 %>%
  rename("F_ID" = ID_2445,
         "PREG_ID_2445" = PREG_ID_2445.y) %>%
  select(-PREG_ID_2445.x)

children_diagn_before_Q14 <- children_diagn_before_Q14 %>%
  select(c(-PREG_ID_2445.x, -PREG_ID_2445.y))

#create child IDs
mothers_diagn_before_Q14$ID_2445 <- paste(mothers_diagn_before_Q14$PREG_ID_2445, mothers_diagn_before_Q14$ChildNumber, sep = "_")
fathers_diagn_before_Q14$ID_2445 <- paste(fathers_diagn_before_Q14$PREG_ID_2445, fathers_diagn_before_Q14$ChildNumber, sep = "_")

#### all NAs as 0 - NAs indicate that the person does not have a diagnosis
mothers_diagn_before_Q14[is.na(mothers_diagn_before_Q14)] <- 0
fathers_diagn_before_Q14[is.na(fathers_diagn_before_Q14)] <- 0
children_diagn_before_Q14[is.na(children_diagn_before_Q14)] <- 0

#### merge together 
parents_diagnoses <- merge(mothers_diagn_before_Q14, fathers_diagn_before_Q14, by = c("PREG_ID_2445", "BARN_NR", "ID_2445"))
diagnostic_predictors <-  merge(children_diagn_before_Q14, parents_diagnoses, by = "ID_2445", all.x = T)

#keep only unique IDs
diagnostic_predictors <-  diagnostic_predictors %>%
  distinct(ID_2445, .keep_all = T)

#### combine with any psychosis
load("any_F2_after_Q14.Rda")
diagnostic_predictors <- merge(any_F2_after_Q14, diagnostic_predictors, by = "ID_2445", all.x = T) ## only keeping individuals in F2* dataframe

##### select variables 
diagnostic_predictors <- diagnostic_predictors %>%
  select(c("ID_2445","sex", "any_F2_NPR_or_KUHR", 
           9:18,
           25:35,
           42:52))

#remove F2* before Q14
setwd("N:/durable/users/avbirken/Paper_3/complete_QC_data/datasets/Granular diagnostic datasets")
load("any_F2_before_Q14.Rda")
any_F2_before_Q14 <-  unique(any_F2_before_Q14$ID_2445)

diagnostic_predictors1 <- diagnostic_predictors %>%
  subset(!diagnostic_predictors$ID_2445 %in% any_F2_before_Q14)

diagnostic_predictors[is.na(diagnostic_predictors)] <- 0

#### remove individuals with withdrawn consent: ----
load("withdrawn_consent.Rda") #Updated list, per 20-09-24
diagnostic_predictors <- filter(diagnostic_predictors, !ID_2445 %in% withdrawn_consent)

table(diagnostic_predictors$any_F2_NPR_or_KUHR) #does not get rid of any cases

### Include ICPC diagnoses
load("any_ICD_or_ICPC_psychosis.Rda")
diagnostic_predictors <- merge(diagnostic_predictors, any_ICD_or_ICPC_psychosis, by = "ID_2445", all.x = T)

#Reorder variables:
diagnostic_predictors <- diagnostic_predictors[, c("ID_2445", "any_F2_NPR_or_KUHR", "any_psychosis_ICD_or_ICPC", "sex",
                                                   setdiff(names(diagnostic_predictors), c("ID_2445", "any_F2_NPR_or_KUHR",
                                                                                           "any_psychosis_ICD_or_ICPC", "sex")))]

#### save
setwd("N:/durable/users/avbirken/Paper_3/complete_QC_data/datasets/")
save("diagnostic_predictors", file = "diagnostic_predictors.Rda") 
load("diagnostic_predictors.Rda")











