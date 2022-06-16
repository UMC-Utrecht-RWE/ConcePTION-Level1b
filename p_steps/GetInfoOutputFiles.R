
#GetInfoOutputFiles.R

#Date and DAP name is retrieved from CDM. This is used for the naming of the output files.


if(file.exists(paste0(path, "CDM_SOURCE.csv"))){
  
  INFO <- IMPORT_PATTERN(dir = path, pat = "CDM_SOURCE.csv", colls = c("data_access_provider_name", "date_creation"), date.colls = "date_creation")
  
  if(nrow(INFO) > 0){
    setorder(INFO, -date_creation )
    DAP <- INFO[1,][["data_access_provider_name"]]
    DATE <- gsub("-", "", as.character(INFO[1,][["date_creation"]]))
  }else{
    DAP <- "UNKDAP"
    DATE <- gsub("-", "", as.character(Sys.Date()))
    print("CDM_SOURCE.csv has 0 rows so for date the day of today is used in output files and DAP is filld with UNKDAP")
  }
  
  if(is.na(DAP)){
    DAP <- "UNKDAP"
    print("DAP not filled in CDM_SOURCE.csv. UNKDAP is used for the naming of the output files")
  }
  
  if(is.na(DATE)){ 
    DATE <- gsub("-", "", as.character(Sys.Date()))
    print("Date not filled in CDM_SOURCE.csv. Date of today is used for the naming of the output files ")
  }
  
  rm(INFO)
  
}else{
  DAP <- "UNKDAP"
  DATE <- gsub("-", "", as.character(Sys.Date()))
  print("CDM_SOURCE.csv is missing so for date the day of today is used in output files and DAP is filld with UNKDAP")
}
