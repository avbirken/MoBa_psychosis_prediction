setwd("/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/source")
listFiles <- list.files(pattern = "*.Rda")

# Remove irrelevant files
listFiles <- setdiff(listFiles, c("diagnostic_predictors.Rda", "any_ICD_or_ICPC_psychosis.Rda", "BUP_subset.Rda"))

for (files in listFiles)
{
  # Load file
  load(files)
  
  # What was loaded?
  d      <- ls()
  toSave <- d[!d %in% c("files", "listFiles")]
  
  write.csv(x = get(toSave), file = gsub("\\Rda", "\\csv", files), row.names = F)
  rm(list = c("d", "toSave", toSave))
}
