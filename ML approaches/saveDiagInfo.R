library(data.table)
workdir <- "/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/work"
nprdir  <- "/ess/p697/cluster/users/parekh/2023-08-14_parseNPR"
kuhrdir <- "/ess/p697/cluster/users/parekh/2023-10-24_KUHR"
setwd(workdir)

allIDs   <- fread(file.path(workdir, "IDList.csv"))
dataNPR  <- fread(file.path(nprdir,  "2024-09-19-MoBa-ParsedNPR_majorCodes.csv"))
dataKUHR <- fread(file.path(kuhrdir, "2024-09-19-MoBa-ParsedKUHR-ICD10-majorCodes.csv"))

# For ICPC, get header
tmpNamesICPC <- colnames(fread(file = file.path(kuhrdir, "2024-09-20-MoBa-ParsedKUHR-ICPC-majorCodes.csv"), nrows = 0))
locs1 <- grepl(glob2rx("*_x*"), tmpNamesICPC)
locs2 <- grepl("^N", tmpNamesICPC)
locs3 <- grepl("^P", tmpNamesICPC)
locs  <- unique(c(1:5, which((locs2 | locs3) & !locs1)))
dataICPC <- fread(file.path(kuhrdir, "2024-09-20-MoBa-ParsedKUHR-ICPC-majorCodes.csv"), select = tmpNamesICPC[locs])

# Remove cross-sectional columns
locs <- !grepl(glob2rx("*_x*"), colnames(dataNPR))
dataNPR <- dataNPR[,..locs]
locs <- !grepl(glob2rx("*_x*"), colnames(dataKUHR))
dataKUHR <- dataKUHR[,..locs]

# Remove data of any subject who is not in allIDs
locs <- dataNPR$ID_2445 %in% allIDs$ID_2445
dataNPR <- dataNPR[locs,]
locs <- dataKUHR$ID_2445 %in% allIDs$ID_2445
dataKUHR <- dataKUHR[locs,]
locs <- dataICPC$ID_2445 %in% allIDs$ID_2445
dataICPC <- dataICPC[locs,]

# Remove all diagnoses outside of F chapter
locs <- c(1:5, which(grepl("^F", colnames(dataNPR))))
dataNPR <- dataNPR[,..locs]
locs <- c(1:5, which(grepl("^F", colnames(dataKUHR))))
dataKUHR <- dataKUHR[,..locs]

# Remove all columns which sum up to zero
locs <- c(1:5, (which(!colSums(dataNPR[,6:ncol(dataNPR)]) == 0) + 5))
dataNPR <- dataNPR[,..locs]
locs <- c(1:5, (which(!colSums(dataKUHR[,6:ncol(dataKUHR)]) == 0) + 5))
dataKUHR <- dataKUHR[,..locs]
locs <- c(1:5, (which(!colSums(dataICPC[,6:ncol(dataICPC)]) == 0) + 5))
dataICPC <- dataICPC[,..locs]

# Write out
fwrite(dataKUHR, file=file.path(workdir, "Info_KUHR_allIDs.csv"), sep = "\t")
fwrite(dataNPR,  file=file.path(workdir, "Info_NPR_allIDs.csv"), sep = "\t")
fwrite(dataICPC, file=file.path(workdir, "Info_ICPC_allIDs.csv"), sep = "\t")
gc()
