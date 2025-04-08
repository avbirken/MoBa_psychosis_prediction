

library(tidyverse)

setwd("N:/durable/users/avbirken/Paper_3/complete_QC_data/datasets")
load("Q14_adolescent_predictors.Rda")

###update with new NPR -----
load("any_F2_after_Q14.Rda")
IDs <-  unique(Q14_adolescent_predictors$ID_2445) #DFs must be of the same length
any_F2_after_Q14 <- any_F2_after_Q14 %>%
  subset(any_F2_after_Q14$ID_2445 %in% IDs)

Q14_adolescent_predictors$any_F2_NPR_or_KUHR <- any_F2_after_Q14$any_F2_NPR_or_KUHR
#table(Q14_adolescent_predictors$any_F2_NPR_or_KUHR)


#### remove individuals with withdrawn consent: ----
withdrawn <- read.delim(
  "Z:/users/parekh/2023-08-14_parseNPR/2024-08-09-MoBa-WithdrawnList.csv", sep = "\t")

MBRN <- read_sav("N:/durable/phenotypes/mbrn/PDB2445_MBRN_541_v12.sav")
MBRN <- MBRN %>%
  rename("ChildNumber" = BARN_NR) 
tmp1 <- merge(withdrawn, MBRN[, c("PREG_ID_2445", "ChildNumber")], by = "PREG_ID_2445", all.x = T)

#create unique child ID
tmp1$ID_2445 <- paste(tmp1$PREG_ID_2445, tmp1$ChildNumber, sep = "_")
withdrawn_IDs <-  unique(tmp1$ID_2445)

Q14_adolescent_predictors <- Q14_adolescent_predictors %>%
  subset(!Q14_adolescent_predictors$ID_2445 %in% withdrawn_IDs)
table(Q14_adolescent_predictors$any_F2_NPR_or_KUHR) #does not get rid of any cases

#### save updated data frame (per 14.08.24)
setwd("N:/durable/users/avbirken/Paper_3/complete_QC_data/datasets")
save("Q14_adolescent_predictors", file="Q14_adolescent_predictors.Rda")



##### Q14-data ----
Q14 <- read_sav("N:/durable/phenotypes/mobaQ/PDB2445_V12_Q14/2024-03-07/PDB2445_Ungdomsskjema_Barn_v12_standard.sav")

tmp <- Q14 %>%
  select(c(PREG_ID_2445, BARN_NR, "AGE_YRS_UB", #age at response
           UB25, UB26, UB27, UB28, UB29, #social competence
           UB31, UB32, UB33, UB34, UB35, #SDQ, prosocial subscale
           UB40:UB53, #Adolescent depression, UB41-53
           # 48:57, #SCL-10 - drop because of NA
           UB64, UB65, UB66, # social phobia
           UB67, UB68, UB69, UB70, # bullying
           UB71, UB72, UB73, UB74, #relations with parents
           UB75, UB76, UB77, UB78, #parent-child conflict
           UB100, UB102, UB104, UB300, UB301, UB302, #sleep UB100-111
           UB117, UB118, UB119, UB120, UB121, UB122, UB123, #academic engagement
           UB124, UB125, UB126, #grades
           UB127:UB134, #disruptive behavior, UB127-134
           UB155:UB165, #psychopathic traits, UB155-65
           UB166:UB170, #SCARED - youth anxiety
           UB171:UB173, #EASE version B
           UB323, UB324, UB325, #EASE version A
           UB178, UB179, UB180, #(not)apathy 
           UB181:UB219, #traumatic life events
           UB249, UB250, UB251, #drug use
           UB188:UB295, #Grit UB288-295
           UB239, #smoking (1-4)
           UB244, #e-cigarettes
           UB245, #nicotine gum
           UB246, #other nicotine
  )) %>%
  rename("smoking" = UB239,
         "e_cigarettes" = UB244,
         "nicotine_gum" = UB245,
         "other_nicotine" = UB246,
         "lifetime_alcohol" = UB249,
         "lifetime_cannabis" = UB250,
         "lifetime_other_drugs" = UB251, 
         "grade_norwegian" = UB124,
         "grade_maths" = UB125,
         "grade_english" = UB126,
         "last_yr_serious_illness" = UB182,
         "last_yr_serious_accident" = UB185,
         "last_yr_changed_school" = UB188,
         "last_yr_friend_injured" = UB191,
         "last_yr_friendship_ended" = UB194,
         "last_yr_changed_homes" = UB197,
         "last_yr_assault" = UB200,
         "last_yr_robbed" = UB203,
         "last_yr_friend_conflict" = UB206,
         "last_yr_family_conflict" = UB209,
         "last_yr_death" = UB212,
         "last_yr_family_mental_health_illness" = UB215,
         "last_yr_family_suicide_or_attempt" = UB218,
         "previous_serious_illness" = UB183,
         "previous_serious_accident" = UB186,
         "previous_changed_school" = UB189,
         "previous_friend_injured" = UB192,
         "previous_friendship_ended" = UB195,
         "previous_changed_homes" = UB198,
         "previous_assault" = UB201,
         "previous_robbed" = UB204,
         "previous_friend_conflict" = UB207,
         "previous_family_conflict" = UB210,
         "previous_death" = UB213,
         "previous_family_mental_health_illness" = UB216,
         "previous_family_suicide_or_attempt" =  UB219)

#merge with F2* diagnoses in the start to see where we lose cases
setwd("N:/durable/users/avbirken/Paper_3/complete_QC_data/datasets")
load("any_F2_after_Q14.Rda")

tmp$ID_2445 <- paste(tmp$PREG_ID_2445, tmp$BARN_NR, sep = "_")
tmp <- merge(tmp, any_F2_after_Q14, by = "ID_2445", all.x = T)
#table(tmp$any_F2_NPR_or_KUHR)


##### Remove F2* before Q14 ####
setwd("N:/durable/users/avbirken/Paper_3/complete_QC_data/datasets")
load("any_F2_before_Q14.Rda")

any_F2_before_Q14 <-  unique(any_F2_before_Q14$ID_2445)
tmp <- tmp %>%
  subset(!tmp$ID_2445 %in% any_F2_before_Q14)
#table(tmp$any_F2_NPR_or_KUHR) # we don't lose any cases here



# Variables ---------------------------------------------------------------

##### Social competence ---- 
social_competence <- tmp %>% select(UB25,UB26,UB27,UB28,UB29) #check number of missing on each item
summary(social_competence)

#normalize the scale by summing item values, dividing by the number of items, then filling in the missing values
sum_values <- rowSums(social_competence, na.rm = T)

num_items <- rowSums(!is.na(social_competence)) #calculate number of non-NA values for each row in the scale
mean_values <-  sum_values / num_items #calculate mean value for each row in the scale
table(is.na(mean_values))

tmp1 <- tmp %>% #fill in normalized values
  mutate(UB25 = ifelse(is.na(UB25), mean_values, UB25),
         UB26 = ifelse(is.na(UB26), mean_values, UB26),
         UB27 = ifelse(is.na(UB27), mean_values, UB27),
         UB28 = ifelse(is.na(UB28), mean_values, UB28),
         UB29 = ifelse(is.na(UB29), mean_values, UB29)) %>%
  mutate(social_competence = (UB25+UB26+UB27+UB28+UB29)) #create sum score

social_competence <- tmp1 %>% select(UB25,UB26,UB27,UB28,UB29) #check new pattern of missingness
summary(social_competence)


##### depression_SMFQ ---- 
depression_SMFQ <- tmp %>% select(UB41,UB42,UB43,UB44,UB45,
                                      UB46,UB47,UB48,UB49,UB50,UB51,UB52,UB53) #check number of missing on each item
summary(depression_SMFQ)

#normalize the scale by summing item values, dividing by the number of items, then filling in the missing values
sum_values <- rowSums(depression_SMFQ, na.rm = T)
num_items <- rowSums(!is.na(depression_SMFQ)) #calculate number of non-NA values for each row in the scale
mean_values <-  sum_values / num_items #calculate mean value for each row in the scale
table(is.na(mean_values))

tmp1 <- tmp1 %>% #fill in normalized values
  mutate(UB41 = ifelse(is.na(UB41), mean_values, UB41),
         UB42 = ifelse(is.na(UB42), mean_values, UB42),
         UB43 = ifelse(is.na(UB43), mean_values, UB43),
         UB44 = ifelse(is.na(UB44), mean_values, UB44),
         UB45 = ifelse(is.na(UB45), mean_values, UB45),
         UB46 = ifelse(is.na(UB46), mean_values, UB46),
         UB47 = ifelse(is.na(UB47), mean_values, UB47),
         UB48 = ifelse(is.na(UB48), mean_values, UB48),
         UB49 = ifelse(is.na(UB49), mean_values, UB49),
         UB50 = ifelse(is.na(UB50), mean_values, UB50),
         UB51 = ifelse(is.na(UB51), mean_values, UB51),
         UB52 = ifelse(is.na(UB52), mean_values, UB52),
         UB53 = ifelse(is.na(UB53), mean_values, UB53)) %>%
  mutate(depression_SMFQ = (UB41 + UB42 + UB43 + UB44 + UB45 +
                                UB46 + UB47 + UB48 + UB49 + UB50 + UB51 + UB52 + UB53)) #create sum score

depression_SMFQ <- tmp1 %>% select(UB41,UB42,UB43,UB44,UB45,
                                     UB46,UB47,UB48,UB49,UB50,UB51,UB52,UB53) #check new pattern of missing
summary(depression_SMFQ)
table(is.na(tmp1$depression_SMFQ))


##### Social phobia ---- 
social_phobia <- tmp %>% select(UB64,UB65,UB66) #check number of missing on each item
summary(social_phobia)

#normalize the scale by summing item values, dividing by the number of items, then filling in the missing values
sum_values <- rowSums(social_phobia, na.rm = T)

num_items <- rowSums(!is.na(social_phobia)) #calculate number of non-NA values for each row in the scale
mean_values <-  sum_values / num_items #calculate mean value for each row in the scale
table(is.na(mean_values))

tmp1 <- tmp1 %>% #fill in normalized values
  mutate(UB64 = ifelse(is.na(UB64), mean_values, UB64),
         UB65 = ifelse(is.na(UB65), mean_values, UB65),
         UB66 = ifelse(is.na(UB66), mean_values, UB66)) %>%
  mutate(social_phobia = (UB64 + UB65 + UB66)) #create sum score

social_phobia <- tmp1 %>% select(UB64,UB65,UB66) #check new pattern of missingness
summary(social_phobia)
table(is.na(tmp1$social_phobia))


##### Being bullied ---- 
bullying <- tmp %>% select(UB67,UB68,UB69,UB70) #check number of missing on each item
summary(bullying)

sum_values <- rowSums(bullying, na.rm = T) #normalize the scale by summing item values, dividing by the number of items, then filling in the missing values
num_items <- rowSums(!is.na(bullying)) #calculate number of non-NA values for each row in the scale
mean_values <-  sum_values / num_items #calculate mean value for each row in the scale
table(is.na(mean_values))

tmp1 <- tmp1 %>% #fill in normalized values
  mutate(UB67 = ifelse(is.na(UB67), mean_values, UB67),
         UB68 = ifelse(is.na(UB68), mean_values, UB68),
         UB69 = ifelse(is.na(UB69), mean_values, UB69),
         UB70 = ifelse(is.na(UB70), mean_values, UB70)) %>%
  mutate(bullying = (UB67 + UB68 + UB69 + UB70)) #create sum score

bullying <- tmp1 %>% select(UB67,UB68,UB69,UB70) #check new pattern of missingness
table(is.na(tmp1$bullying))



## Parent_child_relationship ---- 
parent_child_relationship <- tmp %>% select(UB71,UB72,UB73,UB74) #check number of missing on each item
summary(parent_child_relationship)

sum_values <- rowSums(parent_child_relationship, na.rm = T) #normalize the scale by summing item values, dividing by the number of items, then filling in the missing values
num_items <- rowSums(!is.na(parent_child_relationship)) #calculate number of non-NA values for each row in the scale
mean_values <-  sum_values / num_items #calculate mean value for each row in the scale
table(is.na(mean_values))

tmp1 <- tmp1 %>% #fill in normalized values
  mutate(UB71 = ifelse(is.na(UB71), mean_values, UB71),
         UB72 = ifelse(is.na(UB72), mean_values, UB72),
         UB73 = ifelse(is.na(UB73), mean_values, UB73),
         UB74 = ifelse(is.na(UB74), mean_values, UB74)) %>%
  mutate(parent_child_relationship = (UB71 + UB72 + UB73 + UB74)) #create sum score

parent_child_relationship <- tmp1 %>% select(UB71,UB72,UB73,UB74) #check new pattern of missingness
summary(parent_child_relationship)
table(is.na(tmp1$parent_child_relationship))



## Parent_child_conflict ---- 
parent_child_conflict <- tmp %>% select(UB75,UB76,UB77,UB78) #check number of missing on each item
summary(parent_child_conflict)

sum_values <- rowSums(parent_child_conflict, na.rm = T) #normalize the scale by summing item values, dividing by the number of items, then filling in the missing values
num_items <- rowSums(!is.na(parent_child_conflict)) #calculate number of non-NA values for each row in the scale
mean_values <-  sum_values / num_items #calculate mean value for each row in the scale
table(is.na(mean_values))

tmp1 <- tmp1 %>% #fill in normalized values
  mutate(UB75 = ifelse(is.na(UB75), mean_values, UB75),
         UB76 = ifelse(is.na(UB76), mean_values, UB76),
         UB77 = ifelse(is.na(UB77), mean_values, UB77),
         UB78 = ifelse(is.na(UB78), mean_values, UB78)) %>%
  mutate(parent_child_conflict = (UB75 + UB76 + UB77 + UB78)) #create sum score

parent_child_conflict <- tmp1 %>% select(UB75,UB76,UB77,UB78) #check new pattern of missingness
table(is.na(tmp1$parent_child_conflict))



## Sleep_problems_short ---- 
sleep_problems_short <- tmp %>% select(UB100,UB102,UB104) #check number of missing on each item
summary(sleep_problems_short)

sum_values <- rowSums(sleep_problems_short, na.rm = T) #normalize the scale by summing item values, dividing by the number of items, then filling in the missing values
num_items <- rowSums(!is.na(sleep_problems_short)) #calculate number of non-NA values for each row in the scale
mean_values <-  sum_values / num_items #calculate mean value for each row in the scale
table(is.na(mean_values))

tmp1 <- tmp1 %>% #fill in normalized values
  mutate(UB100 = ifelse(is.na(UB100), mean_values, UB100),
         UB102 = ifelse(is.na(UB102), mean_values, UB102),
         UB104 = ifelse(is.na(UB104), mean_values, UB104)) %>%
  mutate(sleep_problems_short = (UB100 + UB102 + UB104)) #create sum score

sleep_problems_short <- tmp1 %>% select(UB100,UB102,UB104) #check new pattern of missingness
table(is.na(tmp1$sleep_problems_short))


### Clean up RAM
rm(bullying, depression_SMFQ, parent_child_conflict, parent_child_relationship,
   prosocial_sumscore, sleep_problems_short, social_competence, social_phobia)
gc()



## disruptive_behavior_child_rated ---- 
disruptive_behavior_child_rated <- tmp %>% select(UB127,UB128,UB129,UB130,UB131,UB132,UB133,UB134) #check number of missing on each item
summary(disruptive_behavior_child_rated)

sum_values <- rowSums(disruptive_behavior_child_rated, na.rm = T) #normalize the scale by summing item values, dividing by the number of items, then filling in the missing values
num_items <- rowSums(!is.na(disruptive_behavior_child_rated)) #calculate number of non-NA values for each row in the scale
mean_values <-  sum_values / num_items #calculate mean value for each row in the scale
table(is.na(mean_values))

tmp1 <- tmp1 %>% #fill in normalized values
  mutate(UB127 = ifelse(is.na(UB127), mean_values, UB127),
         UB128 = ifelse(is.na(UB128), mean_values, UB128),
         UB129 = ifelse(is.na(UB129), mean_values, UB129),
         UB130 = ifelse(is.na(UB130), mean_values, UB130),
         UB131 = ifelse(is.na(UB131), mean_values, UB131),
         UB132 = ifelse(is.na(UB132), mean_values, UB132),
         UB133 = ifelse(is.na(UB133), mean_values, UB133),
         UB134 = ifelse(is.na(UB134), mean_values, UB134)) %>%
  mutate(disruptive_behavior_child_rated = (UB127 + UB128 + UB129 + UB130 +
                                            UB131 + UB132 + UB133 + UB134)) #create sum score

disruptive_behavior_child_rated <- tmp1 %>% select(UB127,UB128,UB129,UB130,UB131,UB132,UB133,UB134) #check new pattern of missingness



## psychopathic_traits ---- 
psychopathic_traits <- tmp %>% select(UB155,UB156,UB157,UB158,UB159,UB160, UB161,UB162,UB163,UB164,UB165) #check number of missing on each item
summary(psychopathic_traits)

sum_values <- rowSums(psychopathic_traits, na.rm = T) #normalize the scale by summing item values, dividing by the number of items, then filling in the missing values
num_items <- rowSums(!is.na(psychopathic_traits)) #calculate number of non-NA values for each row in the scale
mean_values <-  sum_values / num_items #calculate mean value for each row in the scale
table(is.na(mean_values))

tmp1 <- tmp1 %>% #fill in normalized values
  mutate(UB155 = ifelse(is.na(UB155), mean_values, UB155),
         UB156 = ifelse(is.na(UB156), mean_values, UB156),
         UB157 = ifelse(is.na(UB157), mean_values, UB157),
         UB158 = ifelse(is.na(UB158), mean_values, UB158),
         UB159 = ifelse(is.na(UB159), mean_values, UB159),
         UB160 = ifelse(is.na(UB160), mean_values, UB160),
         UB161 = ifelse(is.na(UB161), mean_values, UB161),
         UB162 = ifelse(is.na(UB162), mean_values, UB162),
         UB163 = ifelse(is.na(UB163), mean_values, UB163),
         UB164 = ifelse(is.na(UB164), mean_values, UB164),
         UB165 = ifelse(is.na(UB165), mean_values, UB165)) %>%
  mutate(psychopathic_traits = (UB155 + UB156 + UB157 + UB158 + UB159 +
                                UB160 + UB161 + UB162 + UB163 + UB164 + UB165)) #create sum score

psychopathic_traits <- tmp1 %>% select(UB155,UB156,UB157,UB158,UB159,UB160, UB161,UB162,UB163,UB164,UB165) #check new pattern of missingness

lose_cases <- tmp1 %>%
  filter(is.na(psychopathic_traits))
table(lose_cases$any_F2_NPR_or_KUHR) #### we lose one case here



## youth_anxiety ---- 
youth_anxiety <- tmp %>% select(UB166,UB167,UB168,UB169,UB170) #check number of missing on each item
summary(youth_anxiety)

sum_values <- rowSums(youth_anxiety, na.rm = T)
num_items <- rowSums(!is.na(youth_anxiety)) #calculate number of non-NA values for each row in the scale
mean_values <-  sum_values / num_items #calculate mean value for each row in the scale
table(is.na(mean_values))

tmp1 <- tmp1 %>% #fill in normalized values
  mutate(UB166 = ifelse(is.na(UB166), mean_values, UB166),
         UB167 = ifelse(is.na(UB167), mean_values, UB167),
         UB168 = ifelse(is.na(UB168), mean_values, UB168),
         UB169 = ifelse(is.na(UB169), mean_values, UB169),
         UB170 = ifelse(is.na(UB170), mean_values, UB170)) %>%
  mutate(youth_anxiety = (UB166 + UB167 + UB168 + UB169 + UB170)) #create sum score

youth_anxiety <- tmp1 %>% select(UB166,UB167,UB168,UB169,UB170) #check new pattern of missingness



###### Anomalous self experiences ---
### combine the two versions of the scale to reduce the number of missing 
#EASE_versionA
EASE_versionA <- tmp %>% select(UB323,UB324,UB325) #check number of missing on each item
summary(EASE_versionA)

sum_values <- rowSums(EASE_versionA, na.rm = T) #normalize the scale by summing item values, dividing by the number of items, then filling in the missing values
num_items <- rowSums(!is.na(EASE_versionA)) #calculate number of non-NA values for each row in the scale
mean_values <-  sum_values / num_items #calculate mean value for each row in the scale
table(is.na(mean_values))

tmp1 <- tmp1 %>% #fill in normalized values
  mutate(UB323 = ifelse(is.na(UB323), mean_values, UB323),
         UB324 = ifelse(is.na(UB324), mean_values, UB324),
         UB325 = ifelse(is.na(UB325), mean_values, UB325)) %>%
  mutate(EASE_versionA = (UB323 + UB324 + UB325)) #create sum score

EASE_versionA <- tmp1 %>% select(UB323,UB324,UB325) #check new pattern of missingness
table(is.na(tmp1$EASE_versionA))


#EASE_versionB
EASE_versionB <- tmp %>% select(UB171,UB172,UB173) #check number of missing on each item
summary(EASE_versionB)

sum_values <- rowSums(EASE_versionB, na.rm = T) #normalize the scale by summing item values, dividing by the number of items, then filling in the missing values
num_items <- rowSums(!is.na(EASE_versionB)) #calculate number of non-NA values for each row in the scale
mean_values <-  sum_values / num_items #calculate mean value for each row in the scale
table(is.na(mean_values))

tmp1 <- tmp1 %>% #fill in normalized values
  mutate(UB171 = ifelse(is.na(UB171), mean_values, UB171),
         UB172 = ifelse(is.na(UB172), mean_values, UB172),
         UB173 = ifelse(is.na(UB173), mean_values, UB173)) %>%
  mutate(EASE_versionB = (UB171 + UB172 + UB173)) #create sum score

EASE_versionB <- tmp1 %>% select(UB171,UB172,UB173) #check new pattern of missingness
table(is.na(tmp1$EASE_versionB))

### fill out NAs on version A with values in version B
tmp1 <- tmp1 %>% 
  mutate(EASE_complete = ifelse(is.na(EASE_versionA), EASE_versionB, EASE_versionA))
table(is.na(tmp1$EASE_complete))



##### enjoyment_scale ----
enjoyment_scale <- tmp %>% select(UB178,UB179,UB180) #check number of missing on each item
summary(enjoyment_scale)

sum_values <- rowSums(enjoyment_scale, na.rm = T) #normalize the scale by summing item values, dividing by the number of items, then filling in the missing values
num_items <- rowSums(!is.na(enjoyment_scale)) #calculate number of non-NA values for each row in the scale
mean_values <-  sum_values / num_items #calculate mean value for each row in the scale

tmp1 <- tmp1 %>% #fill in normalized values
  mutate(UB178 = ifelse(is.na(UB178), mean_values, UB178),
         UB179 = ifelse(is.na(UB179), mean_values, UB179),
         UB180 = ifelse(is.na(UB180), mean_values, UB180)) %>%
  mutate(enjoyment_scale = (UB178 + UB179 + UB180)) #create sum score

enjoyment_scale <- tmp1 %>% select(UB178,UB179,UB180) 
#check new pattern of missingness
table(is.na(tmp1$enjoyment_scale))



### The short Grit Scale (Grit-S) - daily motivation ----
daily_motivation <- tmp %>% select(UB288,UB289,UB290,UB291,UB292,UB293,UB294,UB295) #check number of missing on each item
summary(daily_motivation)

sum_values <- rowSums(daily_motivation, na.rm = T) #normalize the scale by summing item values, dividing by the number of items, then filling in the missing values
num_items <- rowSums(!is.na(daily_motivation)) #calculate number of non-NA values for each row in the scale
mean_values <-  sum_values / num_items #calculate mean value for each row in the scale

tmp1 <- tmp1 %>% #fill in normalized values
  mutate(UB288 = ifelse(is.na(UB288), mean_values, UB288),
         UB289 = ifelse(is.na(UB289), mean_values, UB289),
         UB290 = ifelse(is.na(UB290), mean_values, UB290),
         UB291 = ifelse(is.na(UB291), mean_values, UB291),
         UB292 = ifelse(is.na(UB292), mean_values, UB292),
         UB293 = ifelse(is.na(UB293), mean_values, UB293),
         UB294 = ifelse(is.na(UB294), mean_values, UB294),
         UB295 = ifelse(is.na(UB295), mean_values, UB295)) %>%
  mutate(daily_motivation = (UB288 + UB289 + UB290 + UB291 +
                               UB292 + UB293 + UB294 + UB295)) #create sum score

daily_motivation <- tmp1 %>% select(UB288,UB289,UB290,UB291,UB292,UB293,UB294,UB295) 
#check new pattern of missingness
summary(daily_motivation)
table(is.na(tmp1$daily_motivation))

lose_cases <- tmp1 %>%    #here, we also lose one case
  filter(is.na(daily_motivation))
table(lose_cases$any_F2_NPR_or_KUHR) 



#### Nicotine ----
# new variable: any lifetime nicotine use
tmp1 <- tmp1 %>%
  mutate(nicotine_lifetime = ifelse(smoking >= 2 | e_cigarettes  >= 2 |
                                   nicotine_gum  >= 2 | other_nicotine  >= 2, 1, 0)) %>%
  mutate(nicotine_lifetime = ifelse(is.na(nicotine_lifetime), 0, nicotine_lifetime)) #all NA coded as 0
table(tmp1$nicotine_lifetime)

tmp1 <- tmp1 %>%
  mutate(nicotine_daily = ifelse(smoking >= 3 | e_cigarettes  >= 3 |
                                      nicotine_gum  >= 3 | other_nicotine  >= 3, 1, 0)) %>%
  mutate(nicotine_daily = ifelse(is.na(nicotine_daily), 0, nicotine_daily)) #all NA coded as 0
table(tmp1$nicotine_daily)

#### Alcohol and drugs ----
# lifetime alcohol - fill out NA values with values from UB247
tmp2 <- tmp1 %>% mutate(lifetime_alcohol = ifelse(is.na(lifetime_alcohol), UB47, lifetime_alcohol)) %>%
  mutate(lifetime_alcohol = ifelse(is.na(lifetime_alcohol), 0, lifetime_alcohol)) %>% #all NA coded as 0
  mutate(lifetime_cannabis = ifelse(is.na(lifetime_cannabis), 0, lifetime_cannabis)) %>% #all NA coded as 0
  mutate(lifetime_other_drugs = ifelse(is.na(lifetime_other_drugs), 0, lifetime_other_drugs)) #all NA coded as 0


##### free up memory 
rm(daily_motivation, disruptive_behavior_child_rated, EASE_versionA, EASE_versionB,
   enjoyment_scale, psychopathic_traits, youth_anxiety)
gc()


#### traumatic life events ----
##Keep all individual trauma variables, but recode NA as 0
names(tmp2)
life_events <- tmp2[93:131]

tmp3 <- tmp2 %>%
  mutate_at(vars(names(life_events)), ~ ifelse(is.na(.), 0, .))
summary(tmp3)

###### Year of response----
      FODEREG <- read_sav("N:/durable/phenotypes/mobaQ/PDB2445_MoBa_V12/PDB2445_MBRN_541_v12.sav")
      
      FODEREG$ID_2445 <- paste(FODEREG$PREG_ID_2445, FODEREG$BARN_NR, sep = "_")
      FODEREG<-distinct(FODEREG,ID_2445,.keep_all=TRUE)
      
      ####NB: I only want to keep FAAR
      tmp4 <- left_join(tmp3, FODEREG[, c("ID_2445", "FAAR")], by = "ID_2445")

      #create new variable:
      tmp4$year_of_response = tmp4$FAAR + tmp4$AGE_YRS_UB
      
##### select variables
       tmp5 <- tmp4 %>%
        select(c("ID_2445" , "any_F2_NPR_or_KUHR", "year_of_response",
                 "last_yr_serious_illness", "previous_serious_illness",             
                 "last_yr_serious_accident", "previous_serious_accident",            
                 "last_yr_changed_school",   "previous_changed_school", 
                 "last_yr_friend_injured",   "previous_friend_injured", 
                 "last_yr_friendship_ended", "previous_friendship_ended",            
                 "last_yr_changed_homes",    "previous_changed_homes",  
                 "last_yr_assault",          "previous_assault",        
                 "last_yr_robbed",           "previous_robbed",         
                 "last_yr_friend_conflict",  "previous_friend_conflict",
                 "last_yr_family_conflict",  "previous_family_conflict",
                 "last_yr_death",            "previous_death",          
                 "last_yr_family_mental_health_illness",  "previous_family_mental_health_illness",
                 "last_yr_family_suicide_or_attempt",     "previous_family_suicide_or_attempt",   
                 "lifetime_alcohol",         "lifetime_cannabis",        "lifetime_other_drugs",    
                 "social_phobia",            "depression_SMFQ",          "bullying",                
                 "parent_child_relationship","parent_child_conflict",    "sleep_problems_short",    
                 "disruptive_behavior_child_rated",             "youth_anxiety",           
                 "EASE_complete",  "enjoyment_scale",  "nicotine_lifetime",       
                 "nicotine_daily" ))

        #### decided to remove "psychopathic_traits" and "daily_motivation" as NA values makes us lose cases     


#### only keep complete cases ----
Q14_adolescent_predictors <- tmp5[complete.cases(tmp5),]
table(Q14_adolescent_predictors$any_F2_NPR_or_KUHR)
names(Q14_adolescent_predictors)

load("Q14_adolescent_predictors.Rda")

#### remove individuals with withdrawn consent: ----
    load("withdrawn_consent.Rda") #Updated list, per 20-09-24
    Q14_adolescent_predictors <- filter(Q14_adolescent_predictors, !ID_2445 %in% withdrawn_consent)
    
    table(Q14_adolescent_predictors$any_F2_NPR_or_KUHR) #does not get rid of any cases

### Include ICPC diagnoses
    load("any_ICD_or_ICPC_psychosis.Rda")
    Q14_adolescent_predictors <- merge(Q14_adolescent_predictors, any_ICD_or_ICPC_psychosis, by = "ID_2445", all.x = T)
    
    #remove NA in any psychosis variable
    Q14_adolescent_predictors$any_psychosis_ICD_or_ICPC[is.na(Q14_adolescent_predictors$any_psychosis_ICD_or_ICPC)] <- 0

#Reorder variables:
    selected_vars <- c("ID_2445", "any_F2_NPR_or_KUHR", "any_psychosis_ICD_or_ICPC")
    Q14_adolescent_predictors <- select(Q14_adolescent_predictors, all_of(selected_vars), everything())


#save dataset
setwd("N:/durable/users/avbirken/Paper_3/complete_QC_data/datasets")
#save("Q14_adolescent_predictors", file = "Q14_adolescent_predictors.Rda") 


