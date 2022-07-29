

files <- list.files(pattern = "WHERECLAUSE", path = paste0(projectFolder, "/g_intermediate/"))

#i=12

for(i in 1:length(files)){
  
  TEMP <- readRDS(paste0(projectFolder, "/g_intermediate/",files[i]))
  
  if(nrow(TEMP) > 30){
  
  #floor(sum(TEMP[["N"]])/100) > 
  #sum(TEMP[["N"]] < 5) > 30
  
  TEMP <- DetectValues(
    file = TEMP,
    c.N = "N"
    
  )
  }
  
  TEMP <- TEMP[,  N :=  fifelse(N < 5, "< 5", as.character(N)) ] 
  fwrite(TEMP[, Study_variable := as.character()],paste0(projectFolder, "/g_output/",DATE,"_",DAP,"_", substr(files[i], 1, nchar(files[i]) - 4),".csv"), sep = ";")
  rm(TEMP)
  gc()
  
  
  
  
}



       