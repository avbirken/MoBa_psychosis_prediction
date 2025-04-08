
####Data sources: 
###Norwegian Medical birth registry
###Wave 1, 2 and 3 of the MoBa mother questionnaires

library(tidyverse)
library(haven)
library(data.table)

setwd("N:/durable/users/avbirken/Paper_3/complete_QC_data/datasets")
load("pre_perinatal_predictors.Rda")
load("any_F2_after_Q14.Rda")


###### MBRN ----
MBRN <- read_sav("N:/durable/phenotypes/mbrn/PDB2445_MBRN_541_v12.sav")
MBRN <- MBRN %>%
  rename("ChildNumber" = BARN_NR,
         "sex" = KJONN) %>%
  relocate(sex)

MBRN_predictors <- MBRN %>%
  select(c(PREG_ID_2445, ChildNumber,HYPERTENSJON_KRONISK,
           DIABETES_MELLITUS, #several categories 
           HELLP,
           ICTERUS, #gulsott
           VEKT,
           PARITET_5, HODE, 
           RESPIRATORISK_DISTR,
           MORS_ALDER_G, FARS_ALDER_G, VAGINAL, KSNITT_PLANLAGT,
           PREEKLTIDL, PREEKL, 
           APGAR5, 
           APGAR10,
           APGAR1, 
           DAAR,
           FAAR,
           SVLEN_DG,
           SVLEN_UL_DG,
           SVLEN_SM_DG
  ))  %>% rename("gestation_duration" = SVLEN_DG,
                 "parity" = PARITET_5,
                 "chronic_hypertension"  = HYPERTENSJON_KRONISK,
                 "HELLP_syndrome" = HELLP,
                 "weight" = VEKT,
                 "head_circumfrence" = HODE,
                 "respiratory_distress_syndrome" = RESPIRATORISK_DISTR,
                 "mothers_age_at_birth" = MORS_ALDER_G,
                 "fathers_age_at_birth" = FARS_ALDER_G,
                 "delivery_type" = VAGINAL,
                 "early_pre_eclampsia" = PREEKLTIDL,
                 "pre_eclampsia" = PREEKL) 

#### QC of variables ---- 
#Hypertension - coding NaN as 0
          MBRN_predictors$chronic_hypertension <- ifelse(is.na(MBRN_predictors$chronic_hypertension), 0, MBRN_predictors$chronic_hypertension)
         
#Diabetes mellitus into two variables: pregestational and gestational - NaN are coded as 0
          # Create pregest_diabetes and remove NaN
          MBRN_predictors$pregest_diabetes <- ifelse(MBRN_predictors$DIABETES_MELLITUS > 0 & MBRN_predictors$DIABETES_MELLITUS <= 3, 1, 0)
          MBRN_predictors$pregest_diabetes <- ifelse(is.na(MBRN_predictors$pregest_diabetes), 0, MBRN_predictors$pregest_diabetes)
          
          # Create gest_diabetes and remove NaN
          MBRN_predictors$gest_diabetes <- ifelse(MBRN_predictors$DIABETES_MELLITUS == 4 | MBRN_predictors$DIABETES_MELLITUS == 5, 1, 0)
          MBRN_predictors$gest_diabetes <- ifelse(is.na(MBRN_predictors$gest_diabetes), 0, MBRN_predictors$gest_diabetes)
         
#HELLP-syndrome - coding NaN as 0
          MBRN_predictors$HELLP_syndrome <- ifelse(is.na(MBRN_predictors$HELLP_syndrome), 0, MBRN_predictors$HELLP_syndrome)
          
#cecariean or vaginal - Vaginal = 1; cecariean = 0
          MBRN_predictors$delivery_type <- ifelse(is.na(MBRN_predictors$delivery_type), 0, MBRN_predictors$delivery_type)
          
#Icterus/ jaundice - coding NaN as 0
          MBRN_predictors$icterus <- ifelse(is.na(MBRN_predictors$ICTERUS), 0, MBRN_predictors$ICTERUS)
         
# Birth weight - Removing extreme values based on Norwegian growth charts 
          Q6_MONTHS <- read_sav("N:/durable/phenotypes/mobaQ/PDB2445_MoBa_V12/PDB2445_Q4_6months_v12.sav")
          
          ## fill in missing values in the MBRN-variable with values from the questionnaire (DD212: weight at 6 weeks): 
                 MBRN_predictors$weight = ifelse(is.na(MBRN_predictors$weight), Q6_MONTHS$DD212, MBRN_predictors$weight)
          
          #NB: threshold for viability of life has increased from lower threshold of 1,500g to 400-500 g in the past years
          #remove all individuals with values under 400g or NA
                 MBRN_predictors <- subset(MBRN_predictors,
                                    weight >= 400  & !is.na(weight))
          
# Head circumference 
          ## fill in missing values in the MBRN-variable with values from the questionnaire (DD214: head circumference at 6 weeks): 
          MBRN_predictors$head_circumfrence = ifelse(is.na(MBRN_predictors$head_circumfrence),
                                                      Q6_MONTHS$DD214, MBRN_predictors$head_circumfrence)
          
          hist(MBRN_predictors$head_circumfrence)
          # Replace values outside of the range 20-40 with NA (20 to include those at the lower end - a little bit extra lenient)
          MBRN_predictors$head_circumfrence <-  ifelse(MBRN_predictors$head_circumfrence < 20 | 
                                                      MBRN_predictors$head_circumfrence > 40, NA,
                                                     MBRN_predictors$head_circumfrence)
         
           hist(pre_perinatal_predictors$APGAR5_new)
         table(pre_perinatal_predictors$weight < 2000)
          
# Respiratory distress syndrome - coding NaN as 0
          MBRN_predictors$respiratory_distress_syndrome <- ifelse(is.na(MBRN_predictors$respiratory_distress_syndrome), 0, MBRN_predictors$respiratory_distress_syndrome)
          
# Mother's age at birth - no NaN, but some erroneous values
          #changing all 917 and 945 with 17 and 45
          MBRN_predictors$mothers_age_at_birth <- ifelse(MBRN_predictors$mothers_age_at_birth == 917, 17, 
                                                         ifelse(MBRN_predictors$mothers_age_at_birth == 945, 45,
                                                                MBRN_predictors$mothers_age_at_birth))
        
# Father's age at birth
          summary(MBRN_predictors$fathers_age_at_birth) #333 NA
          
          #changing all 918 and 959 with 18 and 59
          MBRN_predictors$fathers_age_at_birth <- ifelse(MBRN_predictors$fathers_age_at_birth == 918, 18, 
                                                         ifelse(MBRN_predictors$fathers_age_at_birth == 959, 59, MBRN_predictors$fathers_age_at_birth))

#Pre-eclampsia - collapse the two variables into one binarized variable
          MBRN_predictors$pre_eclampsia <- ifelse(MBRN_predictors$early_pre_eclampsia == 1 |
                                                         MBRN_predictors$pre_eclampsia == 1 | #light
                                                         MBRN_predictors$pre_eclampsia == 2 | #serious
                                                         MBRN_predictors$pre_eclampsia == 3,  #unspecified
                                                       1, 0)
          MBRN_predictors$pre_eclampsia <- ifelse(is.na(MBRN_predictors$pre_eclampsia), 0, MBRN_predictors$pre_eclampsia)

#APGAR-5, fill out NaN with values on APGAR1 or 10, if not available, set NaN as 9 or 10
          MBRN_predictors$APGAR5_new <- ifelse(is.na(MBRN_predictors$APGAR5), 
                                   ifelse(!is.na(MBRN_predictors$APGAR10), MBRN_predictors$APGAR10, 
                                   ifelse(!is.na(MBRN_predictors$APGAR1), MBRN_predictors$APGAR1, NA)), MBRN_predictors$APGAR5)
          
          # Fill NAs with either 9 or 10 randomly
          MBRN_predictors$APGAR5_new <- ifelse(is.na(MBRN_predictors$APGAR5_new), sample(c(9, 10), sum(is.na(MBRN_predictors$APGAR5_new)), replace = TRUE), MBRN_predictors$APGAR5_new)

          
### duration of gestation - fill out NA values in the main variable with values in the other variables
          MBRN_predictors$gestation_duration <- ifelse(is.na(MBRN_predictors$gestation_duration), 
                                               ifelse(!is.na(MBRN_predictors$SVLEN_UL_DG), MBRN_predictors$SVLEN_UL_DG, 
                                                      ifelse(!is.na(MBRN_predictors$SVLEN_SM_DG), MBRN_predictors$SVLEN_SM_DG, NA)),
                                               MBRN_predictors$gestation_duration)
          
          table(is.na(MBRN_predictors$gestation_duration)) #NAs from 488 to 465
                
#Select variables
          MBRN_predictors <- MBRN_predictors %>%
            select(c(-SVLEN_UL_DG, -SVLEN_SM_DG, -DIABETES_MELLITUS,
                     -ICTERUS, -APGAR10, -APGAR1, -APGAR5, -DAAR, -KSNITT_PLANLAGT, 
                     -early_pre_eclampsia))
          summary(MBRN_predictors)  #only NAs in the fathers age, HC and duration of gestation       


##### Q1 data - questionnaires at week 15 of pregnancy----
      #### prenatal exposures
Q1_mother <- read_sav("N:/durable/phenotypes/mobaQ/PDB2445_MoBa_V12/PDB2445_Q1_v12.sav") #NB: sav, not csv-file

#Select variables
tmp_Q1 <- Q1_mother %>%
  select(c(PREG_ID_2445, VERSJON_SKJEMA1_TBL1, 
           AA326, AA327, AA328, AA329, #fever with rash, week: 0-4, 5-8, 9-12, 13+
           AA336, AA337, AA338, AA339, #fever over 38,5, week: 0-4, 5-8, 9-12, 13+
           AA376, AA377, AA378, AA379, #influenza, week: 0-4, 5-8, 9-12, 13+
           AA386, AA387, AA388, AA389, #Pneumonia, week: 0-4, 5-8, 9-12, 13+
           #AA1305, parents mother tongue other than Norwegian (not available)
           AA1349, #passive smoking to week 15 (1-No, 2-Sometimes, 3-Daily)
           AA1356, #active smoking to week 15 (1-No, 2-Sometimes, 3-Daily)
           AA1454, #alcohol to week 15 (1-7: one indicates daily drinking) 
           AA1435, AA1439, AA1443, AA1447, AA1451, #drug use during pregnancy
           AA1434, AA1438, AA1442, AA1446, AA1450,#drugs before pregnancy
           AA1203, AA1207, AA1211, AA1215, AA1219, AA1223, AA1227, AA1231, AA1235, #Exposure to harmful substances - nr of days in the past year 
           AA1239, AA1243, AA1247, AA1251, AA1255, AA1259, AA1263, AA1267
  )) %>%
  rename("fever_rash_w4" = AA326,
         "fever_rash_w8" = AA327, 
         "fever_rash_w12" = AA328, 
         "fever_rash_w13" = AA329, 
         "high_fever_w4" = AA336,
         "high_fever_w8" = AA337,
         "high_fever_w12" = AA338,
         "high_fever_w13" = AA339,
         "influenza_w4" = AA376, 
         "influenza_w8" = AA377, 
         "influenza_w12" = AA378, 
         "influenza_w13" = AA379, 
         "pneumonia_w4" = AA386,
         "pneumonia_w8" = AA387,
         "pneumonia_w12" = AA388,
         "pneumonia_w13" = AA389,
         #"mother_tongue_other" = AA1305,
         "passive_smoking_w15" = AA1349,
         "smoking_w15" = AA1356,
         "alcohol_w15" = AA1454, 
         "cannabis_w15" = AA1435,
         "amphetamine_w15" = AA1439,
         "ecstasy_w15" = AA1443,
         "cocaine_w15" = AA1447,
         "heroin_w15" = AA1451)

##### Q3 data ----
Q3_mother <- read_sav("N:/durable/phenotypes/mobaQ/PDB2445_MoBa_V12/PDB2445_Q3_v12.sav") #NB: sav, not csv-file

#Select variables
tmp_Q3 <- Q3_mother %>%
  select(c(PREG_ID_2445, VERSJON_SKJEMA3_TBL1, 
           CC532, CC533, CC534, CC535, CC536, #influenza, week: 13-16 17-20 21-24 25-28 29+
           CC544, CC545, CC546, CC547, CC548, #Pneumonia, week: 13-16 17-20 21-24 25-28 29+
           CC592, CC593, CC594, CC595, CC596, #bladder infection, week: 13-16 17-20 21-24 25-28 29+
           CC269, #anesthetics during pregnancy (1 no, 2 yes)
           CC1033, #passive smoking to week 30: home (1 no, 2 yes)
           CC1037, #active smoking to week 30 (1-No, 2-Sometimes, 3-Daily)
           CC1067, CC1068, CC1069, CC1070, CC1071, #drugs to week 30 
           CC1157:CC1159 #alcohol to week 30 (1-7: one indicates daily drinking)
  )) %>%
  rename("influenza_w16" = CC532, #week: 13-16 17-20 21-24 25-28 29+
         "influenza_w20" = CC533, 
         "influenza_w24" = CC534, 
         "influenza_w28" = CC535,
         "influenza_w29" = CC536,
         "pneumonia_w16" = CC544,
         "pneumonia_w20" = CC545,
         "pneumonia_w24" = CC546,
         "pneumonia_w28" = CC547,
         "pneumonia_w29" = CC548,
         "bladder_infection_w16" = CC592,
         "bladder_infection_w20" = CC593,
         "bladder_infection_w24" = CC594,
         "bladder_infection_w28" = CC595,
         "bladder_infection_w29" = CC596,
         "anesthetics_during_pregnancy" = CC269,
         "passive_smoking_w30" = CC1033,
         "smoking_w30" = CC1037,
         "alcohol_w30" = CC1158, 
         "cannabis_w30" = CC1067,
         "amphetamine_w30" = CC1068,
         "ecstasy_w30" = CC1069,
         "cocaine_w30" = CC1070,
         "heroin_w30" = CC1071)

Q <- merge(tmp_Q1, tmp_Q3, by = "PREG_ID_2445", all = T)



###### QC of questionnaire variables -----
#Fever - combine all fever variables into two binary variables
      Q <- Q %>%
        mutate("fever_1_trim" = ifelse(rowSums(!is.na(cbind(fever_rash_w4, fever_rash_w8, fever_rash_w12, high_fever_w4, high_fever_w8, high_fever_w12))) > 0, 1, 0)) %>%
        mutate("fever_2_trim" = ifelse(rowSums(!is.na(cbind(fever_rash_w13, high_fever_w13))) > 0, 1, 0)) 

#Influenza - combine all fever variables into three binary variables
      Q <- Q %>%
        mutate("influenza_1_trim" = ifelse(rowSums(!is.na(cbind(influenza_w4, influenza_w8, influenza_w12))) > 0, 1, 0)) %>%
        mutate("influenza_2_trim" = ifelse(rowSums(!is.na(cbind(influenza_w13, influenza_w16, influenza_w20, influenza_w24))) > 0, 1, 0)) %>%
        mutate("influenza_3_trim" = ifelse(rowSums(!is.na(cbind(influenza_w28, influenza_w29))) > 0, 1, 0))

#Pneumonia - combine all fever variables into three binary variables
      Q <- Q %>%
        mutate("pneumonia_1_trim" = ifelse(rowSums(!is.na(cbind(pneumonia_w4, pneumonia_w8, pneumonia_w12))) > 0, 1, 0)) %>%
        mutate("pneumonia_2_trim" = ifelse(rowSums(!is.na(cbind(pneumonia_w13, pneumonia_w16, pneumonia_w20, pneumonia_w24))) > 0, 1, 0)) %>%
        mutate("pneumonia_3_trim" = ifelse(rowSums(!is.na(cbind(pneumonia_w28, pneumonia_w29))) > 0, 1, 0))

#Bladder infection - binarize to any infection throughout pregnancy - yes/no
      Q <- Q %>% mutate("bladder_infection" = 
                 ifelse(rowSums(!is.na(cbind(bladder_infection_w16, bladder_infection_w20,
                                             bladder_infection_w24, bladder_infection_w28,
                                             bladder_infection_w29))) > 0, 1, 0)) 

#Smoking - create two binarized smoking variables
      # Recode values 0, 4, 5, 6, and 7 to 2 (indicating some smoking)
      Q$smoking_w15 <- ifelse(Q$smoking_w15 %in% c(0, 3, 4, 5, 6, 7), 2, Q$smoking_w15)
      Q$smoking_w30 <- ifelse(Q$smoking_w30 %in% c(0, 3, 4, 5, 6, 7), 2, Q$smoking_w30)
      
      #binarize variables and set all NA as 0: 
      Q$smoking_w15 <- ifelse(Q$smoking_w15 == 1 | is.na(Q$smoking_w15), 0, 1) 
      Q$smoking_w30 <- ifelse(Q$smoking_w30 == 1 | is.na(Q$smoking_w30), 0, 1)
      

# Drug use - creating three binary variables    
      Q <- Q %>%
        mutate("drug_use_mnth_before" = 
                 ifelse(rowSums(!is.na(cbind(AA1434, AA1438, AA1442, AA1446, AA1450))) > 0, 1, 0)) %>%
        mutate("drug_use_w15" = 
                 ifelse(rowSums(!is.na(cbind(cannabis_w15, amphetamine_w15, ecstasy_w15, cocaine_w15, heroin_w15))) > 0, 1, 0)) %>%
        mutate("drug_use_w30" = ifelse(cannabis_w30 == 2 | amphetamine_w30 == 2 | ecstasy_w30 == 2 | cocaine_w30 == 2 | heroin_w30 == 2 , 1, 0)) %>% #different coding
        mutate(drug_use_w30 = ifelse(is.na(Q$smoking_w30), 0, 1)) #recode NA as 0

# Exposure to harmful substances - 18 different exposures
      # Switch NAs with 0 in all variables
      Q <- Q %>%
        mutate_all(~ifelse(is.na(.), 0, .))
      
      Q <- Q %>%
       rename("lead_exposure" = AA1203,
              "arsenic_exposure" = AA1207,
              "gasoline_exposure" = AA1211,
              "mercury_exposure" = AA1215,
              "disinfectant_exposure" = AA1219,
              "insecticide_exposure" = AA1223,
              "oil_paint_exposure" = AA1227,
              "water_paint_exposure" = AA1231,
              "solvent_exposure" = AA1235,
              "industrial_dye_exposure" = AA1239,
              "oil_exposure" = AA1243,
              "fixative_exposure" = AA1247,
              "welding_exposure" = AA1251,
              "soldering_exposure" = AA1255,
              "formaldehyde_exposure" =  AA1259,
              "chemo_exposure" =  AA1263,
              "anesthetic_gas_exposure" = AA1267)
      ##all variables as > 1 or 0
      
      
# Alcohol use - creating three ordinal variables for each trimester
        #reordered - higher score should indicate more drinking
      Q <- Q %>%
        mutate(alcohol_w15 = ifelse(alcohol_w15 == 0, 7, alcohol_w15)) %>% #code all Nan (0s) as 7 (does not drink)
        mutate(alcohol_w30 = ifelse(alcohol_w30 == 0, 7, alcohol_w30)) %>%
        mutate(CC1159 = ifelse(CC1159 == 0, 7, CC1159)) %>%
        mutate("alcohol_1_trim" = recode(alcohol_w15, `1` = 7, `2` = 6, `3` = 5, `4` = 4, `5` = 3, `6` = 2, `7` = 1)) %>%
        mutate("alcohol_2_trim" = recode(alcohol_w30, `1` = 7, `2` = 6, `3` = 5, `4` = 4, `5` = 3, `6` = 2, `7` = 1)) %>%
        mutate("alcohol_3_trim" = recode(CC1159, `1` = 7, `2` = 6, `3` = 5, `4` = 4, `5` = 3, `6` = 2, `7` = 1)) 
      
     table(is.na(Q$alcohol_2_trim))

##### Select variables: 
Q <- Q %>%
  select(c(1, 32:48, "smoking_w15", "smoking_w30", 
           76:90))

#### Clean up RAM
rm(MBRN, Q1_mother, Q3_mother, Q6_MONTHS)
gc()

###### Join datasets ----
pre_perinatal_predictors <- left_join(MBRN_predictors, Q, by = "PREG_ID_2445") 
summary(pre_perinatal_predictors)

###### Create ID_2445 (unique IDs)----
pre_perinatal_predictors$ID_2445 <- paste(pre_perinatal_predictors$PREG_ID_2445, pre_perinatal_predictors$ChildNumber, sep = "_")
    ### move all IDs from diagnostic predictors to pre/perinatal predictors 
    #before joining with any F2 to get the total number of individuals
    #then, set all other NAs as 0
summary(pre_perinatal_predictors) # N = 113,646

##### Add psychosis variables ----
setwd("N:/durable/users/avbirken/Paper_3/complete_QC_data/datasets")
load("any_F2_after_Q14.Rda") 
pre_perinatal_predictors <- merge(tmp, any_F2_after_Q14, by = "ID_2445", all.x = T)
table(pre_perinatal_predictors$any_F2_NPR_or_KUHR)
           

###### Set exposure variables with NaNs to 0
names(pre_perinatal_predictors)
variables_to_process <- c("lead_exposure", "arsenic_exposure","gasoline_exposure", "mercury_exposure",             
      "disinfectant_exposure", "insecticide_exposure",  "oil_paint_exposure",    "water_paint_exposure", 
      "solvent_exposure","industrial_dye_exposure",  "oil_exposure",  "fixative_exposure",    
      "welding_exposure","soldering_exposure",    "formaldehyde_exposure", "chemo_exposure", 
      "anesthetic_gas_exposure", "smoking_w15",   "smoking_w30",   "fever_1_trim", 
      "fever_2_trim",  "influenza_1_trim","influenza_2_trim","influenza_3_trim",     
      "pneumonia_1_trim","pneumonia_2_trim","pneumonia_3_trim","bladder_infection",    
      "drug_use_mnth_before",  "drug_use_w15",  "drug_use_w30",  "alcohol_1_trim", 
      "alcohol_2_trim","alcohol_3_trim")

# Loop through each variable and replace NA values with O
for(variable in variables_to_process) {
  pre_perinatal_predictors[[variable]][is.na(pre_perinatal_predictors[[variable]])] <- 0
}
        
        # Reorder the data frame 
        pre_perinatal_predictors <- pre_perinatal_predictors[, c("ID_2445", "sex",
                                                                   "any_F2_NPR_or_KUHR", setdiff(names(pre_perinatal_predictors), c("ID_2445", "sex",
                                                                                                                                    "any_F2_NPR_or_KUHR")))]
        # only keep complete cases ----
        pre_perinatal_predictors1 <- pre_perinatal_predictors[complete.cases(pre_perinatal_predictors),]
        table(pre_perinatal_predictors1$any_F2_NPR_or_KUHR)
        
        ##### Remove F2* before Q14 ####
        setwd("N:/durable/users/avbirken/Paper_3/complete_QC_data/datasets")
        load("any_F2_before_Q14.Rda") #UPDATED 20.08.24
        
        any_F2_before_Q14 <-  unique(any_F2_before_Q14$ID_2445)
        
        pre_perinatal_predictors <- pre_perinatal_predictors1 %>%
          subset(!pre_perinatal_predictors1$ID_2445 %in% any_F2_before_Q14)
        
        
        #### remove individuals with withdrawn consent: ----
        load("withdrawn_consent.Rda")
        pre_perinatal_predictors <- filter(pre_perinatal_predictors, !ID_2445 %in% withdrawn_consent)
        
        table(pre_perinatal_predictors$any_F2_NPR_or_KUHR) 
        #does not get rid of any cases
        
        ### Include ICPC diagnoses
        load("any_ICD_or_ICPC_psychosis.Rda")
        pre_perinatal_predictors <- merge(pre_perinatal_predictors, any_ICD_or_ICPC_psychosis, by = "ID_2445", all.x = T)
        
        #Reorder variables:
        pre_perinatal_predictors <- pre_perinatal_predictors[, c("ID_2445", "any_F2_NPR_or_KUHR", "any_psychosis_ICD_or_ICPC", "sex",
                                                           setdiff(names(pre_perinatal_predictors), c("ID_2445", "any_F2_NPR_or_KUHR",
                                                                                                   "any_psychosis_ICD_or_ICPC", "sex")))]
        
        pre_perinatal_predictors <- pre_perinatal_predictors %>%
          select(-"PREG_ID_2445", -"ChildNumber")
        
## save: 
setwd("N:/durable/users/avbirken/Paper_3/complete_QC_data/datasets")
save("pre_perinatal_predictors", file="pre_perinatal_predictors.Rda") 



      