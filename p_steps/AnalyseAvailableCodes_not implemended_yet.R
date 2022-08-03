


#To fill
###
#DAP <- "SIDIAP"
path_code <- paste0(projectFolder,"/p_meta/")

###

TABLE <- "EVENTS"
c.voc = "coding_system"
c.concept = "Outcome"
c.codes = "code"
f.code = "event_code"
f.voc =  "event_record_vocabulary"
c.startwith = c("ICD10CM","ICD10","ICD10DA","ICD9CM","MTHICD9")
n.codesheet = "ALL_full_codelist.csv"


#dbcdm <- "H:/Review_level1b/tempdb.db"

#codesheet <- readRDS(paste0(tmp,"CODES_EVENTS.rds"))

codesheet <- IMPORT_PATTERN(pat = n.codesheet, dir = path_code)


if(TABLE == "EVENTS"){
  codesheet <-  codesheet[, Outcome := paste0(system,"_",event_abbreviation,"_",type)]
  setnames(codesheet,c(c.voc,c.concept,c.codes),c("Type","Concept","Code"))
}




#Create variable code_no_dot by removing dot from all codes
codesheet[,code_no_dot := gsub("\\.","",codesheet[,Code])]


codesheet[,start_with := fifelse(substr(Code,nchar(Code),nchar(Code) + 1) == "." | Type %in% c.startwith ,"T","F")]

report_missing <- list()
report_available <- list()

files <- list.files(paste0(projectFolder,"/g_intermediate/"), include.dirs = T, all.files = T, full.names = T, recursive = T)

file <- files[grepl(paste0("WHERECLAUSE_", TABLE), files)]


        dbListTables(mydb)

        mydb <- dbConnect(RSQLite::SQLite(), paste0(projectFolder,"/g_intermediate/database.db"))

        tmpdb <- dbConnect(RSQLite::SQLite(), "")
        
        dbWriteTable(tmpdb, "codesheet" ,codesheet[,c("Type","Concept","Code", "code_no_dot", "start_with") , with = F], overwrite = T, append = F)
        
        DATA_FILE <- dbGetQuery(mydb, paste0("SELECT DISTINCT ",f.code,",", f.voc," FROM ", TABLE))
        
        dbWriteTable(tmpdb, "TEMP" ,DATA_FILE , overwrite = T, append = F) 
        #dbGetQuery(tmpdb, "SELECT * FROM TEMP")
        p <- dbSendStatement(tmpdb, paste0("CREATE TABLE TEMP2 AS SELECT DISTINCT ",f.voc," AS Type2, REPLACE( ",f.code,", '.', '' ) as code_no_dot2 FROM TEMP"))
        dbClearResult(p)
        
        p <- dbSendStatement(tmpdb, paste0("CREATE INDEX TEMP2_index ON TEMP2( Type2, code_no_dot2 )"))
        dbClearResult(p)
        
        p <- dbSendStatement(tmpdb, paste0("CREATE INDEX codesheet_index ON codesheet( code_no_dot, Type, start_with)"))
        dbClearResult(p)
        
        voc <- paste0(dbGetQuery(tmpdb, "SELECT DISTINCT Type2 FROM TEMP2")[["Type2"]], collapse = "|")
        
        #Problem to solve
        ###
        #https://stackoverflow.com/questions/59409075/sqlite-like-operator-is-very-slow-compared-to-the-operator
        #t1.code_no_dot2 LIKE(t2.code_no_dot || '%')
        ###
        
        #aatest <- dbGetQuery(tmpdb, "SELECT DISTINCT * FROM TEMP2")
        #EXPLAIN QUERY PLAN
        system.time(TEMP1 <- dbGetQuery(tmpdb,"
                  
                  
                  SELECT DISTINCT  t1.Type2 , t2.Concept
                  FROM (SELECT DISTINCT * FROM TEMP2) t1
                  INNER JOIN codesheet t2
        
                  ON (
                        t1.Type2 = t2.Type
        
                        AND
                        
                        (
        
                              (
        
                              t2.start_with = 'T'
                              
                              AND
                              
                              substr(t1.code_no_dot2,1,length(t2.code_no_dot)) = substr(t2.code_no_dot,1,length(t2.code_no_dot))
                              )
        
                              OR
        
                              (
                              t2.start_with = 'F'
                              
                              AND
                              
                              t1.code_no_dot2 = t2.code_no_dot
                              )
                        )
        
                      )
        
        
                  "))
        
        
        
        missing <- unique(codesheet$Concept)[!unique(codesheet$Concept) %in% unique(TEMP1$Concept)]
        available <- unique(codesheet$Concept)[unique(codesheet$Concept) %in% unique(TEMP1$Concept)]
        file <- rep(TABLE, length(missing))
        voc <- rep(voc, length(missing))
        
        
        report_missing[[i]] <- as.data.table(cbind(file, missing, voc))
        
        
        report_available <- unique(TEMP1)[, Table := TABLE]
        setnames(available, "Type2", "Coding_system")
        
        dbDisconnect(mydb)
        
        rm(DATA_FILE, missing, file, voc, p, mydb)
        gc()




        report_available <-  do.call(rbind, report_available)
        report_missing <-  do.call(rbind, report_missing)

rm(c.voc, c.concept, c.codes, f.code, f.voc, c.startwith )



fwrite(report_available, paste0(path,"Available_concepts.csv"))
fwrite(report_missing, paste0(path,"Missing_concepts.csv"))

