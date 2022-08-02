

files <- list.files(pattern = "WHERECLAUSE", path = paste0(projectFolder, "/g_intermediate/"))

#i=12

for(i in 1:length(files)){
  
  TEMP <- readRDS(paste0(projectFolder, "/g_intermediate/",files[i]))
  
  TEMP2 <- copy(TEMP)[,  N :=  fifelse(N < 5, "< 5", as.character(N)) ] 
  fwrite(TEMP2[, Study_variable := as.character()],paste0(projectFolder, "/g_output/",DATE,"_",DAP,"_", substr(files[i], 1, nchar(files[i]) - 4),".csv"), sep = ";")
  rm(TEMP2)
  
  if(nrow(TEMP) > 100){
  
  #floor(sum(TEMP[["N"]])/100) > 
  #sum(TEMP[["N"]] < 5) > 30
  
  TEMP <- DetectValues(
    file = TEMP,
    c.N = "N",
    cutoff = 100
    
  )
  }
  
  TEMP <- TEMP[,  N :=  fifelse(N < 5, "< 5", as.character(N)) ] 
  fwrite(TEMP[, Study_variable := as.character()],paste0(projectFolder, "/g_output/",DATE,"_",DAP,"_", substr(files[i], 1, nchar(files[i]) - 4),"_EST.csv"), sep = ";")
  rm(TEMP)
  gc()
  
  
  
  
}



       