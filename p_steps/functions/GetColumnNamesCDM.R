

GetColumnNamesCDM <- function(cdm_path){

TABLES <- data.table()

if(!require("openxlsx")){install.packages("openxlsx")}
suppressPackageStartupMessages(library(openxlsx))

sheets <- getSheetNames(cdm_path)

for(i in sheets){
          
 
          TEMP <- as.data.table(read.xlsx(cdm_path, sheet = i))
          
          
          start <- which(TEMP[,1] == "Variable")
          end <- which(TEMP[,1] == "Conventions")
          
          if(length(start) == 1 & length(end) == 1){
          
          TEMP2 <- as.data.frame(TEMP[(start +1) : (end - 1) ,])
          colnames(TEMP2) <- unlist(unname(as.list(TEMP[start,])))
          TEMP2 <- TEMP2[, 1:4]
          TEMP2$TABLE <- i
          
          if(nrow(TABLES) == 0) TABLES <- TEMP2
          if(nrow(TABLES) > 0) TABLES <- rbindlist(list(TABLES,TEMP2), fill = T, use.names = T)
          
          rm(TEMP2, start, end)

          }
          rm(TEMP)
}


TABLES <- TABLES[!is.na(Variable) & !is.na(TABLE),]

return(TABLES)


}