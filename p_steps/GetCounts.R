
#Get info for all tables that are in scope of interest
TABLES2 <- as.data.table(TABLES)[TABLE %in% t.interest, ]

#Set up database in SQLite
if(file.exists(paste0(projectFolder,"/g_intermediate/database.db"))) file.remove(paste0(projectFolder,"/g_intermediate/database.db"))
mydb <- dbConnect(RSQLite::SQLite(), paste0(projectFolder,"/g_intermediate/database.db"))


#j = t.interest[3]


#Loop over all the relevant CDM tables, append them per type of CDM table and countthe unique rows. The results are stored in csv file in the folder output.

for(j in t.interest){
  
  #Get needed columns and files for CDM table of interest
  needed <- unique(TABLES2[TABLE == j,][["Variable"]])            
  files <- list.files(path = path, pattern = j)
  
  #i = files[1]
  for(i in files){
    
    #Import the 1 table for the CDM table of interest
    TEMP <- IMPORT_PATTERN(
      append = F,
      dir = path, 
      pat = i,
    )
    
    if(any(!colnames(TEMP) %in% needed)){
      lapply(colnames(TEMP)[!colnames(TEMP) %in% needed], function(x) TEMP <- TEMP[, eval(x) := NULL])
      print(paste0("Check colnames file ",i, " Some columns are excluded from the analyses"))
      }
    
    
    #Stop script if their exist column names that are not known within CDM
    #if(any(!colnames(TEMP) %in% needed)){print(paste0("Check colnames file ",i, " This file is excluded from the analyses"))}else{
      
      #Put all the column in the table that can exist in the CDM table
      to_add <- needed[!needed %in% colnames(TEMP)]
      if(length(to_add) > 0){
        print(paste0("In table ",i," colls are missing and are added as empty columns. Please check if all needed columns are in the table"))
        lapply(to_add, function(x) TEMP <- TEMP[, eval(x) := as.character()])
        
      }
      rm(to_add)  
      
      dbWriteTable(mydb, j, TEMP, append = T, overwrite = F)
    #}
    rm(TEMP)
    gc()
    
  }
  
  rm(needed, files)            
  
  if(j %in% dbListTables(mydb)){
    
    #Get colnames
    colls <- colnames(dbGetQuery(mydb,
                                 
                                 paste0(
                                   "
                SELECT  * FROM 
                ",j, " LIMIT 1"  
                                   
                                   
                                   
                                 )
                                 
    ))
    
    #Remove id's and dates
    colls <- colls[!grepl("date", colls)]
    colls <- colls[!grepl("_id", colls)]
    
    
    VALUES <- dbGetQuery(mydb,
                         
                         paste0(
                           "
                  SELECT count(*) AS N,",paste0(colls, collapse = ",")," FROM ",j," 
                  
                  GROUP BY ",paste0(colls, collapse = ",")
                           
                           
                         )
                         
                         
    )
    
    if(GetCountsColumns){
    for(i in colls){
      
      VALUES2 <- dbGetQuery(mydb,
                            
                            paste0(
                              "
                            SELECT count(",i,") AS N,",i," FROM ",j," 
                            
                            GROUP BY ",i
                            )
      )
      
      setnames(VALUES2, i, "Result")
      VALUES2 <- as.data.table(VALUES2)[, Column := i]
      
      if(i == colls[1]){VALUES3 <- VALUES2}else{
        VALUES3 <- rbindlist(list(VALUES3, VALUES2), fill = F, use.names = T)
      }
      rm(VALUES2)
      
    }
    fwrite(VALUES3,paste0(projectFolder, "/g_output/",DATE,"_",DAP,"_AWNSERS_",j,".csv"), sep = ";") 
    rm(VALUES3)
    }
      
    fwrite(as.data.table(VALUES)[, Study_variable := as.character()],paste0(projectFolder, "/g_output/",DATE,"_",DAP,"_WHERECLAUSE_",j,".csv"), sep = ";")
    rm(VALUES, colls)
  }
  
}

dbDisconnect(mydb)
rm(mydb, TABLES2)
gc()

