library(haven)
setwd("/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/source")
allFiles <- list.files(pattern = "*.sav")

for(files in allFiles){
  data <- read_sav(files)
  write.csv(data, gsub(".sav", ".csv", files), row.names = F)
}