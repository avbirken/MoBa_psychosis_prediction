### Data sources: 
### Q14 MoBa questionnaire:
https://www.fhi.no/globalassets/dokumenterfiler/studier/den-norske-mor-far-og-barn--undersokelsenmoba/instrumentdokumentasjon/instrument-documentation-q14_barn.pdf

library(haven)
library(tidyverse)

### CAPE dataset ----
Q14 <- read_sav("N:/durable/phenotypes/mobaQ/PDB2445_V12_Q14/2024-03-07/PDB2445_Ungdomsskjema_Barn_v12_standard.sav")

#### CAPE-9, frequency ----
CAPE_9 <- Q14 %>% select(UB252,UB254,UB256,UB258,UB260,UB262,UB264,UB266,UB268) #check number of missing on each item
summary(CAPE_9)

sum_values <- rowSums(CAPE_9, na.rm = T) #normalize the scale by summing item values,
#dividing by the number of items, then filling in the missing values
num_items <- rowSums(!is.na(CAPE_9)) #calculate number of non-NA values for each row in the scale
mean_values <-  sum_values / num_items #calculate mean value for each row in the scale

Q14 <- Q14 %>% #fill in normalized values
  mutate(UB252 = ifelse(is.na(UB252), mean_values, UB252),
         UB254 = ifelse(is.na(UB254), mean_values, UB254),
         UB256 = ifelse(is.na(UB256), mean_values, UB256),
         UB258 = ifelse(is.na(UB258), mean_values, UB258),
         UB260 = ifelse(is.na(UB260), mean_values, UB260),
         UB262 = ifelse(is.na(UB262), mean_values, UB262),
         UB264 = ifelse(is.na(UB264), mean_values, UB264),
         UB266 = ifelse(is.na(UB266), mean_values, UB266),
         UB268 = ifelse(is.na(UB268), mean_values, UB268)) %>%
  mutate(CAPE_9_frequency = (UB252+ UB254 +UB256 + UB258 + UB260
                   + UB262 + UB264+ UB266 + UB268)) #create sum score

CAPE_9 <- Q14 %>% select(UB252,UB254,UB256,UB258,UB260,UB262,UB264,UB266,UB268) 
#check new pattern of missingness
summary(CAPE_9)

# #### CAPE-16, frequency ----
# CPAE-16 is put on ice for now
#CAPE_16 <- Q14 %>% select(UB252,UB254,UB256,UB258,UB260,UB262,UB264,UB266,UB268,
#                           UB270,UB272,UB274,UB276,UB278,UB280,UB282) #check number of missing on each item
# summary(CAPE_16)
# 
# Q14 <- Q14 %>% # NOT ENOUTH VALUES TO NORMALIZE THE LAST SEVEN VALUES
#   mutate(CAPE_16_frequency = (UB252+ UB254 +UB256 + UB258 + UB260 + UB262 + UB264+ UB266 + UB268
#                     +UB270 + UB272 + UB274 + UB276 + UB278 + UB280 + UB282)) #create sum score
# hist(Q14$CAPE_16_frequency)


#Transform all NA distress values to 1 (not at all) before summarizing 
CAPE_distress <-  c("UB253","UB255","UB257","UB259","UB261",
                    "UB263","UB265","UB267","UB269","UB271",
                    "UB273", "UB275",  "UB277",  "UB279",
                    "UB281","UB283")

for (variable in CAPE_distress) {
  Q14[[variable]][is.na(Q14[[variable]])] <- 1
}

CAPE_9 <- Q14 %>% 
  mutate(CAPE_9_distress = (UB253+ UB255 + UB257 + UB259 + UB261 +
                             UB263 + UB265 + UB267 + UB269 )) #create sum score

##### select variables ---
CAPE_9 <- CAPE_9 %>%
  select(c(PREG_ID_2445, BARN_NR, 
           CAPE_9_frequency, CAPE_9_distress,# sum scores
           UB252, UB254, UB256, UB258, UB260, UB262, UB264, UB266, UB268, # frequency items
           UB253, UB255, UB257, UB259, UB261, UB263, UB265, UB267, UB269, #distress items
           UB250, UB251)) %>% #drugs
  rename("lifetime_cannabis" = UB250,
         "lifetime_other_drugs" = UB251) %>%
  mutate(lifetime_cannabis = ifelse(is.na(lifetime_cannabis), 0, lifetime_cannabis),
         lifetime_other_drugs = ifelse(is.na(lifetime_other_drugs), 0, lifetime_other_drugs)) #all NA coded as 0

#create unique child ID
CAPE_9$ID_2445 <- paste(CAPE_9$PREG_ID_2445, CAPE_9$BARN_NR, sep = "_")

#join with F2* diagnoses
setwd("N:/durable/users/avbirken/Paper_3/complete_QC_data/datasets")
load("any_F2_after_Q14.Rda")

CAPE_91 <- merge(CAPE_9, any_F2_after_Q14, by = "ID_2445", all.x = T)

# #make sure that there are no NA diagnoses values
# CAPE_scales2 <- CAPE_scales1 %>%
#   mutate(any_F2_NPR_or_KUHR = ifelse(is.na(any_F2_NPR_or_KUHR), 0, any_F2_NPR_or_KUHR)) #all NA coded as 0


## remove those with F2* before Q14 (additional QC in preprocessing before we run the ML pipeline)
setwd("N:/durable/users/avbirken/Paper_3/complete_QC_data/datasets")
load("any_F2_before_Q14.Rda") #### created with the NPR_after_Q14 and KUHR_after_Q14 scripts

any_F2_before_Q14 <-  unique(any_F2_before_Q14$ID_2445)
CAPE_9_2 <- CAPE_91 %>%
  subset(!CAPE_91$ID_2445 %in% any_F2_before_Q14)
cape_9_complete_cases <- CAPE_9[complete.cases(CAPE_9),]

### Remove individuals who withdrew their consent:
load("withdrawn_consent.Rda")
cape_9_complete_cases <- filter(cape_9_complete_cases, !ID_2445 %in% withdrawn_consent)

### Include ICPC diagnoses:
load("any_ICD_or_ICPC_psychosis.Rda")
cape_9_complete_cases <- merge(cape_9_complete_cases, any_ICD_or_ICPC_psychosis, by = "ID_2445", all.x = T)

#Reorder variables:
cape_9_complete_cases <- cape_9_complete_cases[, c("ID_2445", "any_F2_NPR_or_KUHR", "any_psychosis_ICD_or_ICPC", "sex",
                                              setdiff(names(cape_9_complete_cases), 
                                              c("ID_2445", "any_F2_NPR_or_KUHR", "any_psychosis_ICD_or_ICPC", "sex")))]
cape_9_complete_cases <- cape_9_complete_cases %>%
  select(c(-"PREG_ID_2445", -"BARN_NR", 
            -"lifetime_cannabis", -"lifetime_other_drugs"))

setwd("N:/durable/users/avbirken/Paper_3/complete_QC_data/datasets")
save("cape_9_complete_cases", file="cape_9_complete_cases.Rda")


