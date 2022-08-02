

#Empty memory
rm(list=ls())
gc()

#To fill
###
#DAP <- "SIDIAP"
path <- "H:/Review_level1b/"
path_code <- "C:/C4591021_PfizerUMC/Data characterisation/PfizerScript/p_meta_data/Pfizer_full_codelist.csv"
TABLE <- "EVENTS"
###


c.voc = "coding_system"
c.concept = "Outcome"
c.codes = "code"
f.code = "event_code"
f.voc =  "event_record_vocabulary"
c.startwith = c("ICD10CM","ICD10","ICD10DA","ICD9CM","MTHICD9")



#dbcdm <- "H:/Review_level1b/tempdb.db"

#codesheet <- readRDS(paste0(tmp,"CODES_EVENTS.rds"))



codesheet <-  fread(path_code)
codesheet <-  codesheet[, Outcome := paste0(system,"_",event_abbreviation,"_",type)]

setnames(codesheet,c(c.voc,c.concept,c.codes),c("Type","Concept","Code"))


#Create variable code_no_dot by removing dot from all codes
codesheet[,code_no_dot := gsub("\\.","",codesheet[,Code])]


codesheet[,start_with := fifelse(substr(Code,nchar(Code),nchar(Code) + 1) == "." | Type %in% c.startwith ,"T","F")]

 

files <- list.files(path, include.dirs = T, all.files = T, full.names = T, recursive = T)

files <- files[grepl(paste0("WHERECLAUSE_", TABLE), files)]
i=files[1]
report <- list()

for(i in files){


        mydb <- dbConnect(RSQLite::SQLite(), "")
        
        dbWriteTable(mydb, "codesheet" ,codesheet[,c("Type","Concept","Code", "code_no_dot", "start_with") , with = F], overwrite = T, append = F)
        
        DATA_FILE <- fread(i)
        
        dbWriteTable(mydb, "TEMP" ,DATA_FILE , overwrite = T, append = F) 
        
        p <- dbSendStatement(mydb, paste0("CREATE TABLE TEMP2 AS SELECT DISTINCT ",f.voc," AS Type2, REPLACE( ",f.code,", '.', '' ) as code_no_dot2 FROM TEMP"))
        dbClearResult(p)
        
        p <- dbSendStatement(mydb, paste0("CREATE INDEX TEMP2_index ON TEMP2( code_no_dot2, Type2)"))
        dbClearResult(p)
        
        p <- dbSendStatement(mydb, paste0("CREATE INDEX codesheet_index ON codesheet( code_no_dot, Type, start_with)"))
        dbClearResult(p)
        
        voc <- paste0(dbGetQuery(mydb, "SELECT DISTINCT Type2 FROM TEMP2")[["Type2"]], collapse = "|")
        
        system.time(TEMP1 <- dbGetQuery(mydb,"
                  select  t1.*, t2.Concept
                  from TEMP2 t1
                  inner join codesheet t2
        
                  on (
                        t1.Type2 = t2.Type
        
                        and
                        (
        
                              (
        
                              t2.start_with = 'T'
                              and
                              substr(t1.code_no_dot2,1,length(t2.code_no_dot)) = substr(t2.code_no_dot,1,length(t2.code_no_dot))
                              )
        
                              or
        
                              (
                              t2.start_with = 'F'
                              and
                              t1.code_no_dot2 = t2.code_no_dot
                              )
                        )
        
                      )
        
        
                  "))
        
        
        
        missing <- unique(codesheet$Concept)[!unique(codesheet$Concept) %in% unique(TEMP1$Concept)]
        file <- rep(i, length(missing))
        voc <- rep(voc, length(missing))
        
        report[[i]] <- as.data.table(cbind(file, missing, voc))
        
        
        dbDisconnect(mydb)
        
        rm(DATA_FILE, missing, file, voc, p, mydb)
        gc()

}


report <-  do.call(rbind, report)


rm(c.voc, c.concept, c.codes, f.code, f.voc, c.startwith )



fwrite(report, paste0(path,TABLE,"_Available_concepts.csv"))


