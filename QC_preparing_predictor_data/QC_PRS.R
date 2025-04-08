
library(tidyverse)
library(haven)
library(data.table)

#### PRS ----
setwd("N:/durable/users/piotrpj/for_Viktoria/out_MAF_0_05/OR")  


###### ADHD ####
ADHD <- fread("N:/durable/users/piotrpj/for_Viktoria/out_MAF_0_05/OR/prs_from_OR_0_05.PGC_ADHD_2017_EUR_Filtered.all_score")

#Map to correct SentrixID and Father/Mother/child ID:
IDS <- fread("N:/durable/genotype/MoBaPsychGen_v1/MoBaPsychGen_v1-ec-eur-batch-basic-qc-cov.txt")
names(IDS)
ADHD <- merge(ADHD, IDS, by = c("IID", "FID")) #N = 207,568

#filter on children
ADHD <- ADHD %>%
  filter(Role == "Child")

#join with any F2
setwd("N:/durable/users/avbirken/Paper_3/complete_QC_data/datasets")
load("any_F2_after_Q14.Rda")

ADHD <- merge(ADHD, any_F2_after_Q14, by = "ID_2445", all.x = T)

## remove those with F2* before Q14
setwd("N:/durable/users/avbirken/Paper_3/complete_QC_data/datasets")
load("any_F2_before_Q14.Rda")

any_F2_before_Q14 <-  unique(any_F2_before_Q14$ID_2445)
PRS_ADHD <- ADHD[!ADHD$ID_2445 %in% any_F2_before_Q14, ]
table(PRS_ADHD$any_F2_NPR_or_KUHR)
#removes six cases

        ## recode sex variable - values of 1 to 0 and 2 to 1, and set 0 as 0 
        PRS_ADHD$sex <- recode(PRS_ADHD$SEX, `1` = "0", `2` = "1", .default = "0")
        table(is.na(PRS_ADHD$SEX))
        
        #remove NA in any psychosis variable
        PRS_ADHD$any_F2_NPR_or_KUHR[is.na(PRS_ADHD$any_F2_NPR_or_KUHR)] <- 0
        
#### remove individuals with withdrawn consent: ----
        load("withdrawn_consent.Rda") #Updated list, per 20-09-24
        PRS_ADHD <- filter(PRS_ADHD, !ID_2445 %in% withdrawn_consent)
        table(PRS_ADHD$any_F2_NPR_or_KUHR) #does not get rid of any cases
        
        ### Include ICPC diagnoses
        load("any_ICD_or_ICPC_psychosis.Rda")
        PRS_ADHD <- merge(PRS_ADHD, any_ICD_or_ICPC_psychosis, by = "ID_2445", all.x = T)
        
        #remove NAs
        PRS_ADHD$any_psychosis_ICD_or_ICPC[is.na(PRS_ADHD$any_psychosis_ICD_or_ICPC)] <- 0
        
        #Reorder variables:
        selected_vars <- c("ID_2445", "any_F2_NPR_or_KUHR", "any_psychosis_ICD_or_ICPC", "sex")
        PRS_ADHD <- select(PRS_ADHD, all_of(selected_vars), everything())
        
## save: 
setwd("N:/durable/users/avbirken/Paper_3/complete_QC_data/datasets")
save("PRS_ADHD", file="PRS_ADHD.Rda")


###### ASD ####
ASD <- fread("N:/durable/users/piotrpj/for_Viktoria/out_MAF_0_05/OR/prs_from_OR_0_05.PGC_ASD_2017_iPSYCH_Filtered.all_score")

#Map to correct SentrixID and Father/Mother/child ID:
IDS <- fread("N:/durable/genotype/MoBaPsychGen_v1/MoBaPsychGen_v1-ec-eur-batch-basic-qc-cov.txt")
names(IDS)
ASD <- merge(ASD, IDS, by = c("IID", "FID")) #N = 207,568

#filter on children
ASD <- ASD %>%
  filter(Role == "Child")

#join with any F2
setwd("N:/durable/users/avbirken/Paper_3/complete_QC_data/datasets")
load("any_F2_after_Q14.Rda")

ASD <- merge(ASD, any_F2_after_Q14, by = "ID_2445", all.x = T)

## remove those with F2* before Q14
setwd("N:/durable/users/avbirken/Paper_3/complete_QC_data/datasets")
load("any_F2_before_Q14.Rda")

any_F2_before_Q14 <-  unique(any_F2_before_Q14$ID_2445)
PRS_ASD <- ASD[!ASD$ID_2445 %in% any_F2_before_Q14, ]
table(PRS_ASD$any_F2_NPR_or_KUHR)
#removes six cases
          
          ## recode sex variable - values of 1 to 0 and 2 to 1, and set 0 as 0
          PRS_ASD$sex <- recode(PRS_ASD$SEX, `1` = "0", `2` = "1", .default = "0")
          table(is.na(PRS_ASD$SEX))
          
          #remove NA in any psychosis variable
          PRS_ASD$any_F2_NPR_or_KUHR[is.na(PRS_ASD$any_F2_NPR_or_KUHR)] <- 0
          
#### remove individuals with withdrawn consent: ----
          load("withdrawn_consent.Rda") #Updated list, per 20-09-24
          PRS_ASD <- filter(PRS_ASD, !ID_2445 %in% withdrawn_consent)
          
          table(PRS_ASD$any_F2_NPR_or_KUHR) #does not get rid of any cases
          
          ### Include ICPC diagnoses
          load("any_ICD_or_ICPC_psychosis.Rda")
          PRS_ASD <- merge(PRS_ASD, any_ICD_or_ICPC_psychosis, by = "ID_2445", all.x = T)
          
          #remove NAs
          PRS_ASD$any_psychosis_ICD_or_ICPC[is.na(PRS_ASD$any_psychosis_ICD_or_ICPC)] <- 0
          
          #Reorder variables:
          selected_vars <- c("ID_2445", "any_F2_NPR_or_KUHR", "any_psychosis_ICD_or_ICPC", "sex")
          PRS_ASD <- select(PRS_ASD, all_of(selected_vars), everything())
          
## save: 
setwd("N:/durable/users/avbirken/Paper_3/complete_QC_data/datasets")
save("PRS_ASD", file="PRS_ASD.Rda")



###### MDD ####
MDD <- fread("N:/durable/users/piotrpj/for_Viktoria/out_MAF_0_05/OR/prs_from_OR_0_05.PGC_MDD_2018_Howard_no23andMe_Filtered.all_score")
names(MDD)

#Map to correct SentrixID and Father/Mother/child ID:
IDS <- fread("N:/durable/genotype/MoBaPsychGen_v1/MoBaPsychGen_v1-ec-eur-batch-basic-qc-cov.txt")
names(IDS)
MDD <- merge(MDD, IDS, by = c("IID", "FID")) #N = 207,568

#filter on children
MDD <- MDD %>%
  filter(Role == "Child")

#join with any F2
setwd("N:/durable/users/avbirken/Paper_3/complete_QC_data/datasets")
load("any_F2_after_Q14.Rda")

MDD <- merge(MDD, any_F2_after_Q14, by = "ID_2445", all.x = T)
table(MDD$any_F2_NPR_or_KUHR)

## remove those with F2* before Q14
setwd("N:/durable/users/avbirken/Paper_3/complete_QC_data/datasets")
load("any_F2_before_Q14.Rda")
any_F2_before_Q14 <-  unique(any_F2_before_Q14$ID_2445)
PRS_MDD <- MDD[!MDD$ID_2445 %in% any_F2_before_Q14, ]

      ## recode sex variable - values of 1 to 0 and 2 to 1, and set 0 as 0
      PRS_MDD$sex <- recode(PRS_MDD$SEX, `1` = "0", `2` = "1", .default = "0")
      table(is.na(PRS_MDD$SEX))
      

#### remove individuals with withdrawn consent: ----
      load("withdrawn_consent.Rda") #Updated list, per 20-09-24
      PRS_MDD <- filter(PRS_MDD, !ID_2445 %in% withdrawn_consent)
      
      table(PRS_MDD$any_F2_NPR_or_KUHR) #does not get rid of any cases
      
      ### Include ICPC diagnoses
      load("any_ICD_or_ICPC_psychosis.Rda")
      PRS_MDD <- merge(PRS_MDD, any_ICD_or_ICPC_psychosis, by = "ID_2445", all.x = T)
      
      #remove NA in any psychosis variable
      PRS_MDD$any_F2_NPR_or_KUHR[is.na(PRS_MDD$any_F2_NPR_or_KUHR)] <- 0
      PRS_MDD$any_psychosis_ICD_or_ICPC[is.na(PRS_MDD$any_psychosis_ICD_or_ICPC)] <- 0
      
      #Reorder variables:
      selected_vars <- c("ID_2445", "any_F2_NPR_or_KUHR", "any_psychosis_ICD_or_ICPC", "sex")
      PRS_MDD <- select(PRS_MDD, all_of(selected_vars), everything())

## save: 
setwd("N:/durable/users/avbirken/Paper_3/complete_QC_data/datasets")
save("PRS_MDD", file="PRS_MDD.Rda")


###### BIP ####
BIP <- fread("N:/durable/users/piotrpj/for_Viktoria/out_MAF_0_05/OR/prs_from_OR_0_05.PGC_BIP_2019_wave3_Filtered.all_score")
names(BIP)

#Map to correct SentrixID and Father/Mother/child ID:
IDS <- fread("N:/durable/genotype/MoBaPsychGen_v1/MoBaPsychGen_v1-ec-eur-batch-basic-qc-cov.txt")
names(IDS)
BIP <- merge(BIP, IDS, by = c("IID", "FID")) #N = 207,568

#filter on children
BIP <- BIP %>%
  filter(Role == "Child")

#join with any F2
setwd("N:/durable/users/avbirken/Paper_3/complete_QC_data/datasets")
load("any_F2_after_Q14.Rda")

BIP <- merge(BIP, any_F2_after_Q14, by = "ID_2445", all.x = T)
table(BIP$any_F2_NPR_or_KUHR)

## remove those with F2* before Q14
setwd("N:/durable/users/avbirken/Paper_3/complete_QC_data/datasets")
load("any_F2_before_Q14.Rda")
any_F2_before_Q14 <-  unique(any_F2_before_Q14$ID_2445)
PRS_BIP <- BIP[!BIP$ID_2445 %in% any_F2_before_Q14, ]

      ## recode sex variable - values of 1 to 0 and 2 to 1, and set 0 as 0
      PRS_BIP$sex <- recode(PRS_BIP$SEX, `1` = "0", `2` = "1", .default = "0")
      table(is.na(PRS_BIP$SEX))

      #remove NA in any psychosis variable
      PRS_BIP$any_F2_NPR_or_KUHR[is.na(PRS_BIP$any_F2_NPR_or_KUHR)] <- 0

#### remove individuals with withdrawn consent: ----
      load("withdrawn_consent.Rda") #Updated list, per 20-09-24
      PRS_BIP <- filter(PRS_BIP, !ID_2445 %in% withdrawn_consent)
      
      table(PRS_BIP$any_F2_NPR_or_KUHR) 
      #does not get rid of any cases
      
      ### Include ICPC diagnoses
      load("any_ICD_or_ICPC_psychosis.Rda")
      PRS_BIP <- merge(PRS_BIP, any_ICD_or_ICPC_psychosis, by = "ID_2445", all.x = T)
      
      #remove NA in any psychosis variable
      PRS_BIP$any_psychosis_ICD_or_ICPC[is.na(PRS_BIP$any_psychosis_ICD_or_ICPC)] <- 0
      
      #Reorder variables:
      selected_vars <- c("ID_2445", "any_F2_NPR_or_KUHR", "any_psychosis_ICD_or_ICPC", "sex")
      PRS_BIP <- select(PRS_BIP, all_of(selected_vars), everything())

## save: 
setwd("N:/durable/users/avbirken/Paper_3/complete_QC_data/datasets")
save("PRS_BIP", file="PRS_BIP.Rda")


###### SCZ ####
SCZ <- fread("N:/durable/users/piotrpj/for_Viktoria/out_MAF_0_05/OR/prs_from_OR_0_05.PGC_SCZ_0518_EUR_Filtered.all_score")
names(SCZ)

#Map to correct SentrixID and Father/Mother/child ID:
IDS <- fread("N:/durable/genotype/MoBaPsychGen_v1/MoBaPsychGen_v1-ec-eur-batch-basic-qc-cov.txt")
names(IDS)
SCZ <- merge(SCZ, IDS, by = c("IID", "FID")) #N = 207,568

#filter on children
SCZ <- SCZ %>%
  filter(Role == "Child")

#join with any F2
setwd("N:/durable/users/avbirken/Paper_3/complete_QC_data/datasets")
load("any_F2_after_Q14.Rda")

SCZ <- merge(SCZ, any_F2_after_Q14, by = "ID_2445", all.x = T)
table(SCZ$any_F2_NPR_or_KUHR)

## remove those with F2* before Q14
setwd("N:/durable/users/avbirken/Paper_3/complete_QC_data/datasets")
load("any_F2_before_Q14.Rda")
any_F2_before_Q14 <-  unique(any_F2_before_Q14$ID_2445)
PRS_SCZ <- SCZ[!SCZ$ID_2445 %in% any_F2_before_Q14, ]

        ## recode sex variable - values of 1 to 0 and 2 to 1, and set 0 as 0
        PRS_SCZ$sex <- recode(PRS_SCZ$SEX, `1` = "0", `2` = "1", .default = "0")
        table(is.na(PRS_SCZ$SEX))
        
        #remove NA in any psychosis variable
        PRS_SCZ$any_F2_NPR_or_KUHR[is.na(PRS_SCZ$any_F2_NPR_or_KUHR)] <- 0

#### remove individuals with withdrawn consent: ----
        load("withdrawn_consent.Rda") #Updated list, per 20-09-24
        PRS_SCZ <- filter(PRS_SCZ, !ID_2445 %in% withdrawn_consent)
        
        table(PRS_SCZ$any_F2_NPR_or_KUHR) #does not get rid of any cases
        
        ### Include ICPC diagnoses
        load("any_ICD_or_ICPC_psychosis.Rda")
        PRS_SCZ <- merge(PRS_SCZ, any_ICD_or_ICPC_psychosis, by = "ID_2445", all.x = T)
        
        #remove NA in any psychosis variable
        PRS_SCZ$any_psychosis_ICD_or_ICPC[is.na(PRS_SCZ$any_psychosis_ICD_or_ICPC)] <- 0
        
        #Reorder variables:
        selected_vars <- c("ID_2445", "any_F2_NPR_or_KUHR", "any_psychosis_ICD_or_ICPC", "sex")
        PRS_SCZ <- select(PRS_SCZ, all_of(selected_vars), everything())

## save: 
setwd("N:/durable/users/avbirken/Paper_3/complete_QC_data/datasets")
save("PRS_SCZ", file="PRS_SCZ.Rda")






