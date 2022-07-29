


rm(list=ls())
gc()

data <- fread("C:/ConcePTION-Level1b/g_output/20211231_DSRU_WHERECLAUSE_MEDICAL_OBSERVATIONS.csv")

data <- data[, N := as.numeric(gsub("<", "", N_masked))][, N_masked := NULL ]

#file <- data
#c.N <- "N"

DetectValues <- function(file, c.N){

setnames(file, c.N, "N")

file <- copy(file)[, `:=` (sens = as.numeric(),  count = 0, col = as.character(), id = as.numeric())  ]
#file <- file[, `:=`  ( meanN = mean(N)), by = col_tmp]
cols <- colnames(file)

for(i in cols){
          
          col_tmp <- cols[!cols %in% c(i, "N", "Study_variable", "sens", "count", "meanN", "col")]
          
          file <- file[, `:=`  (sens = .N), by = col_tmp]
          file <- file[sens > 30, `:=` (count = count + 1, col = i, id = sens)]
          
          if(!any(file[["count"]] < 2)) break
          rm(col_tmp)
          
        }
        
        file2 <- list()
        file1 <- file[count != 1,]
        scheme <- unique(file[count == 1,][, .(col, id)])
        
        rm(cols)
        
        for(i in 1:nrow(scheme)){
        
          
              c.col <- scheme[i,][["col"]]
              c.id <- scheme[i,][["id"]]
              
              tmp <- copy(file)[id == c.id & col == c.col & count == 1,]
              
              cols <- colnames(file)[!colnames(file) %in% c(c.col ,"N", "Study_variable", "sens", "count", "meanN", "col")]
              tmp <- tmp[, id2 := paste0(nchar(do.call(paste0, .SD)), id), .SDcols = cols]
              
              check <- suppressWarnings(sum(is.na(as.numeric(tmp[[c.col]]))))
              
              
              if(check == 0) tmp <- tmp[, eval(c.col) := NULL][, eval(c.col) := "NUM"] 
              if(check == length(tmp[[c.col]])) tmp <- tmp[, eval(c.col) := NULL][, eval(c.col) := "CHAR"] 
              if(check > 0 & check < length(tmp[[c.col]])) tmp <- tmp[, eval(c.col) := NULL][, eval(c.col) := "CHAR/NUM"]
              
              
              
              file2[[i]] <- tmp
              
              rm(c.col, c.id, tmp, cols)
        
        }
        
        rm(scheme, file)
        file2 <- do.call(rbindlist, list(file2, fill = T, use.names = T))
        
        cols <- colnames(file2)[!colnames(file2) %in% c("N", "Study_variable", "sens", "count", "meanN", "col")]
        file2 <- unique(file2[, cols, with = F])
        setnames(file2, "id" , "N")
        rm(cols)
        
        cols <- colnames(file1)[!colnames(file1) %in% c("Study_variable", "sens", "count", "meanN", "col", "id", "id2")]
        file1 <- unique(file1[, cols, with = F])
        
        result <- rbindlist(list(file1, file2), fill = T, use.names = T)
        
        setnames(result , "N", c.N)
        
        return(result)


}


test <- DetectValues(
  file = data,
  c.N = "N"
  
  )
