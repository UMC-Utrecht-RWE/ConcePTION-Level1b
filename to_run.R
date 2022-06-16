
#Author:Roel Elbers MSc.
#email: r.j.h.elbers@umcutrecht.nl
#Organisation: UMC Utrecht, Utrecht, The Netherlands
#Date: 26/07/2021

#Empty memory
rm(list=ls())
gc()

#Fill location of CDM and the table to analyse
#path <- "Y:/Studies/ConcePTION/B_Documentation/2 Protocol_DSMB_Monitoring/WP 7.6 Data Characterization SAP/tmp_RE/C4591021_PfizerUMC_20220325/CDMInstances/TEST_SAMPLE"
#path <- "C:/C4591021_PfizerUMC/CDMInstances/RTI_simulated_10000"
path <- "C:/C4591021_PfizerUMC/CDMInstances/Validate"

#Choose wich tables you want to analyse or fill NULL to get all tables analysed
#t.interest <- c("SURVEY_OBSERVATIONS", "SURVEY_ID", "MEDICAL_OBSERVATIONS", "VACCINES")
t.interest <- NULL

#Set to TRUE if you also want counts per column rather then only by row
GetCountsColumns <- F


#Get location of program
if(!require(rstudioapi)){install.packages("rstudioapi")}
library(rstudioapi)

projectFolder<-dirname(rstudioapi::getSourceEditorContext()$path)

#empty g_output folder
if(length(list.files(paste0(projectFolder,"/g_output"))) > 0)file.remove(paste0(projectFolder,"/g_output/",list.files(paste0(projectFolder,"/g_output"))))


#Load needed functions
system.time(source(paste0(projectFolder,"/p_steps/functions/IMPORT_PATTERN.R")))
system.time(source(paste0(projectFolder,"/p_steps/functions/GetColumnNamesCDM.R")))

#Get needed packages
system.time(source(paste0(projectFolder,"/packages.R")))

#Get CDM tables and columns
TABLES <- GetColumnNamesCDM(paste0(projectFolder,"/p_meta/ConcePTION_CDM tables v2.2.xlsx"))

#Correct for problems with excel import and mistakes in the origonal CDM file. 
#invisible(lapply(c("Variable", "TABLE"), function(x) TABLES <- TABLES[, eval(x) := trimws(get(x), "b")]))
invisible(lapply(c("Variable", "TABLE"), function(x) TABLES <- TABLES[, eval(x) := str_trim(get(x), "b")]))
TABLES <- TABLES[, .(Variable, TABLE)]
TABLES[TABLES == ""] <- NA

TABLES <- TABLES[Variable ==  "specialty_of_visit" , Variable := "speciality_of_visit"]
TABLES <- TABLES[Variable ==  "specialty_of_visit_vocabulary" , Variable := "speciality_of_visit_vocabulary"]
TABLES <- TABLES[Variable ==  "inidication_code" , Variable := "indication_code"]




if(is.null(t.interest)){
      t.interest <- unique(TABLES[["TABLE"]])
      t.interest <- t.interest[!t.interest %in% c("METADATA","CDM_SOURCE","INSTANCE")]
      t.interest <- t.interest[unname((unlist(sapply(t.interest, function(x) any(grepl(x ,list.files(path)), na.rm = T)))))] 
      
} 
  

#Run program that is counting all combinations after deleting columns with id and date in it.
system.time(source(paste0(projectFolder,"/p_steps/GetCounts.R")))







