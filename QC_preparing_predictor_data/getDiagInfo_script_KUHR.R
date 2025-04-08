
# getDiagInfo script ------------------------------------------------------

# The script accepts the following:
#   listID2445: list of subjects you want to work with (or leave empty for all subjects)
#   listDiagCodes: list of major/minor codes that you need (or leave empty for all diagnostic codes); you can use wildcards such as "F32*"
#   wildcard: set to "TRUE" if you have supplied wildcards in listDiagCodes
#   codeType: optional; defaults to all codes; set to "major" if you only need major codes

#   The output is a list having two data frames:
#   diagInfo: data frame having IDs for every diagnostic category,
#   a character entry (in the appropriate column) indicating all years in which the subject got that specific diagnosis
#   firstDiag: data frame having IDs and for every diagnostic category,
#   the year in which the subject got that specific diagnosis for the first time

# The scripts include the following functionalities:
#   Robust handling of all codes vs. major codes
#   Allowing user to pass a path to where the NPR files are located
#   Users can optionally pass a vector of yearOfBirth which will return two more data frames as additional output - age of first diagnosis and age of all diagnoses
#   Additionally calculating a "minimum" year of birth (and similarly minimum age) which is basically minimum year across all columns - only relevant for first diagnosis case


getDiagInfo_KUHR = function(listID2445, listDiagCodes, wildCard = FALSE, codeType = c("all", "major"))
{
  
  # Preliminaries -----------------------------------------------------------
  # Get the data.table library for faster file reading with additional functions
  require(data.table)
  
  # Defining the directory where csv files are saved
  dirOverall <- "Z:/users/parekh/2023-10-24_KUHR"
  
  # Fixing the delimiter here
  delimiter  <- "\t"
  
  # All possible years from KUHR: 2006 to 2023
  allTimes   <- 2006:2023
  
  # Fixed column names that are always to be read
  fixedNames <- c("ID_2445", "Role","PREG_ID_2445", "ChildNumber", "WithdrawnConsent18years")
  
  
  # Check inputs ------------------------------------------------------------
  # Check if all subjects are to be processed
  if(missing(listID2445))
  {
    doAllSubjs <- TRUE
  } else
  {
    doAllSubjs <- FALSE
  }
  
  # Check if diagnostic codes are passed
  if(missing(listDiagCodes))
  {
    doAllCodes <- TRUE
  } else
  {
    doAllCodes <- FALSE
    
    # Make sure that all codes are usable
    listDiagCodes <- sub("\\.", "", listDiagCodes)
    listDiagCodes <- sub(" ",   "", listDiagCodes)
  }
  
  
  # Determine file to read --------------------------------------------------
  if(doAllCodes)
  {
    if(missing(codeType))
    {
      codeType <- "all"
    } 
  } else
  {
    if(missing(codeType))
    {
      if(sum(nchar(listDiagCodes) > 3) > 1)
      {
        codeType <- "all"
      } else
      {
        codeType <- "major"
      }
    } else
    {
      codeType <- match.arg(codeType)
    }
  }
  
  listFiles <- file.path(dirOverall, list.files(path = dirOverall, pattern = glob2rx(paste("*-*-*-MoBa-ParsedKUHR-ICD10-", codeType, "CodesX.csv", sep = ""))))
  if(length(listFiles) == 0)                                                                #### paste("*-*-*-MoBa-ParsedNPR_", codeType, "Codes.csv", sep = ""))))
    if(length(listFiles) == 0)
    {
      stop("No KUHR file found; have the path(s) or file name(s) changed?")
    } else
    {
      if(length(listFiles) > 1)
      {
        warning(paste("Multiple KUHR files found; selecting: ", listFiles[length(listFiles)], sep = ""))
        listFiles <- listFiles[length(listFiles)]
      }
    }
  
  # Get header --------------------------------------------------------------
  tmpNamesKUHR <- colnames(fread(file = listFiles, sep = delimiter, nrows = 0))
  
  # List of codes to read ---------------------------------------------------
  if(doAllCodes)
  {
    listDiagCodes <- unlist(lapply(unique(sapply(strsplit(tmpNamesKUHR[6:length(tmpNamesKUHR)], "_"), "[", 1)), paste, allTimes, sep = "_x"))
    namesToLoad   <- c(fixedNames, listDiagCodes)
  } else
  {
    if(!wildCard)
    {
      # Make a list of all cross-sectional column names
      namesToLoad   <- c(fixedNames, unlist(lapply(listDiagCodes, paste, allTimes, sep = "_x")))
    } else
    {
      namesToLoad   <- c(fixedNames, tmpNamesKUHR[unlist(sapply(glob2rx(unlist(lapply(listDiagCodes, paste, allTimes, sep = "_x"))), grep, tmpNamesKUHR))])
    }
  }
  
  
  # Read the file -----------------------------------------------------------
  if(sum(namesToLoad %in% tmpNamesKUHR) != length(namesToLoad))
  {
    stop("One or more diagnostic codes were not found in the KUHR")
  }
  dataKUHR <- fread(file = listFiles, sep = delimiter, header = TRUE, select = namesToLoad, data.table = FALSE)
  
  
  # Subset subjects, if required --------------------------------------------
  if(!doAllSubjs)
  {
    dataKUHR <- dataKUHR[dataKUHR$ID_2445 %in% listID2445, ]
    dataKUHR <- dataKUHR[match(listID2445, dataKUHR$ID_2445), ]
  }
  
  
  # List of diagnostic codes ------------------------------------------------
  onlyCodes <- unique(sapply(strsplit(namesToLoad[6:length(namesToLoad)], "_x"), "[", 1))
  
  
  # All years of diagnoses --------------------------------------------------
  # Find every occurrence of diagnoses of interest
  xx  <- stack(apply(as.matrix(dataKUHR[,6:ncol(dataKUHR)] == 1), 2, which))
  
  # Merge all diagnostic codes by subject index
  xx2 <- aggregate(xx["ind"], by=xx["values"], paste)
  
  # Initialize a table of results
  diagInfo            <- as.data.frame(matrix(data = NA, nrow = nrow(dataKUHR), ncol = length(onlyCodes)+1))
  firstDiag           <- as.data.frame(matrix(data = NA, nrow = nrow(dataKUHR), ncol = length(onlyCodes)+1))
  colnames(diagInfo)  <- c("ID2445", onlyCodes)
  colnames(firstDiag) <- c("ID2445", onlyCodes)
  diagInfo$ID2445     <- dataKUHR$ID_2445
  firstDiag$ID2445    <- dataKUHR$ID_2445
  
  # Go over every subject who has any of the diagnoses and then compile info
  for(idx in 1:nrow(xx2))
  {
    # What is this index?
    whichIdx <- xx2$values[idx]
    
    # Who is this subject?
    whichSubject <- dataKUHR$ID_2445[whichIdx]
    
    # Which is the corresponding row in results table? - should be same as whichIdx
    whichRow     <- which(diagInfo$ID2445 %in% whichSubject)
    
    # Sanity check
    if(whichRow != whichIdx)
    {
      stop("Something went wrong in subject alignment")
    }
    
    # What was the retrieved information?
    info <- strsplit(unlist(xx2$ind[idx]), "_x")
    
    # Which codes and years did we find?
    whichDiag  <- sapply(info, "[", 1)
    whichYears <- sapply(info, "[", 2)
    
    # Go over every code and compile years
    uqDiag <- unique(whichDiag)
    for(codes in uqDiag)
    {
      # Every year this diagnosis occurs for this subject
      diagInfo[whichRow, codes]  <- paste(whichYears[whichDiag == codes], collapse = ",")
      
      # Year of first diagnosis
      firstDiag[whichRow, codes] <- min(as.numeric(whichYears[whichDiag == codes]))
    }
  }
  
  
  # Put together as a list to return ----------------------------------------
  results <- list("DiagInfo" = diagInfo, "FirstDiagnoses" = firstDiag)
  return(results)
}


# Running script and saving data ---------------------------------------
library(data.table)
library(tidyverse)
library(haven)

#run script
KUHR <-  getDiagInfo_KUHR(listDiagCodes = c("F10", "F11", "F12", "F13", "F14", "F15", "F16", "F17", "F18", "F19",
                                            "F20","F21","F22",
                                            "F23", "F24", "F25","F28","F29",
                                            "F31","F32", "F33",
                                            "F40","F41","F42","F43","F45",
                                            "F50", 
                                            "F60", 
                                            "F80", "F81", "F82", "F83", 
                                            "F84",
                                            "F90", "F91", "F92", "F93"), wildCard = FALSE, codeType = c("major"))
df_KUHR <- as.data.frame(KUHR$FirstDiagnoses) 
names(df_KUHR)

### Save data
setwd("N:/durable/users/avbirken/Paper_3/complete_QC_data/getDiagInfo_script/firstDiag")
save("df_KUHR", file = "df_KUHR.Rda")


