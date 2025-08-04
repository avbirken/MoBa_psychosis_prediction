library(data.table)
dirNPR   <- "/ess/p697/cluster/users/parekh/2023-08-14_parseNPR"
dirKUHR  <- "/ess/p697/cluster/users/parekh/2023-10-24_KUHR"
dirWork  <- "/ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/work"

allIDs   <- fread(file.path(dirWork, "IDList.csv"))

# Read NPR
dataNPR <- fread(file.path(dirNPR, "2024-09-19-MoBa-LinkedNPR-Children.csv"))
dataNPR$ID2445 <- paste0(dataNPR$PREG_ID_2445, "_", dataNPR$ChildNumber)

# Read KUHR
dataKUHR <- fread(file.path(dirKUHR, "2024-09-19-MoBa-LinkedKUHR-Children.csv"))
dataKUHR$ID2445 <- paste0(dataKUHR$PREG_ID_2445, "_", dataKUHR$ChildNumber)

# Subset NPR
dataNPR <- dataNPR[dataNPR$ID2445 %in% allIDs$ID_2445, ]

# Subset KUHR
dataKUHR <- dataKUHR[dataKUHR$ID2445 %in% allIDs$ID_2445, ]

# Codes to keep - NPR
codes <- c("F20", "F21", "F22", "F23", "F24", "F25", "F26", "F27", "F28", "F29")
locs_NPR  <- data.frame(matrix(data = FALSE, nrow=nrow(dataNPR), ncol=length(codes)))
count <- 1
for (cc in codes)
{
  locs_NPR[,count] <- grepl(glob2rx(paste0(cc, "*")), dataNPR$Diagnosis_ICDCode)
  count <- count + 1
}
anyL_NPR <- as.logical(rowSums(locs_NPR))
dataNPR <- dataNPR[anyL_NPR,]

# Codes to keep - KUHR ICD
codes <- c("F20", "F21", "F22", "F23", "F24", "F25", "F26", "F27", "F28", "F29")
locs_KUHR  <- data.frame(matrix(data = FALSE, nrow=nrow(dataKUHR), ncol=length(codes)))
count <- 1
for (cc in codes)
{
  locs_KUHR[,count] <- grepl(glob2rx(paste0(cc, "*")), dataKUHR$Diagnosis) & 
                  !grepl(glob2rx("*ICPC*"), dataKUHR$DiagnosticManual)
  count <- count + 1
}
anyL_KUHR <- as.logical(rowSums(locs_KUHR))
dataKUHR_ICD <- dataKUHR[anyL_KUHR,]

# Codes to keep - ICPC
codes <- c("P72", "P98")
locs_ICPC  <- data.frame(matrix(data = FALSE, nrow=nrow(dataKUHR), ncol=length(codes)))
count <- 1
for (cc in codes)
{
  locs_ICPC[,count] <- grepl(glob2rx(paste0(cc, "*")), dataKUHR$Diagnosis) & 
                      grepl(glob2rx("*ICPC*"), dataKUHR$DiagnosticManual)
  count <- count + 1
}
anyL_ICPC <- as.logical(rowSums(locs_ICPC))
dataKUHR_ICPC <- dataKUHR[anyL_ICPC,]


##
uqNPR <- unique(dataNPR$ID2445)
diffDays_NPR <- data.frame(matrix(nrow = length(uqNPR), ncol = 1))
count <- 1
for (uq in uqNPR)
{
  diffDays_NPR[count,1] <- min(dataNPR$DiffDays_Admission[dataNPR$ID2445 %in% uq])
  count <- count + 1
}
diffDays_NPR <- cbind(uqNPR, diffDays_NPR)


uqKUHR <- unique(dataKUHR_ICD$ID2445)
diffDays_KUHR <- data.frame(matrix(nrow = length(uqKUHR), ncol = 1))
count <- 1
for (uq in uqKUHR)
{
  diffDays_KUHR[count,1] <- min(dataKUHR_ICD$DiffDays[dataKUHR_ICD$ID2445 %in% uq])
  count <- count + 1
}
diffDays_KUHR <- cbind(uqKUHR, diffDays_KUHR)
