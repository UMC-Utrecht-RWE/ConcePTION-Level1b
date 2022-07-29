


#data <- fread("C:/ConcePTION-Level1b/g_output/20211231_DSRU_WHERECLAUSE_MEDICAL_OBSERVATIONS.csv")

#data <- data[, N := as.numeric(gsub("<", "", N_masked))][, N_masked := NULL ]

#file <- data
#c.N <- "N"
#cutoff <- 30

DetectValues <- function(file, c.N, cutoff = 30){

  
file <- copy(file)  
setnames(file, c.N, "N")
c.order <- c("N",colnames(file)[!colnames(file) %in% "N"])

file <- file[, `:=` (sens = as.numeric(),  count = 0, col = as.character(), id = as.numeric())  ]
#file <- file[, `:=`  ( meanN = mean(N)), by = col_tmp]

cols <- colnames(file)
i <- 1
          for(i in 1:length(cols)){
            
            col_tmp <- cols[!cols %in% c(cols[i], "N", "Study_variable", "sens", "count", "meanN", "col", "id")]
            
            idfile <- unique(file[, col_tmp, with = F])[, idtmp := as.numeric(paste0(i, seq_len(.N)))] 
            file <- merge(file, idfile, by = col_tmp, all.x = T) 
            
            file <- file[, `:=`  (sens = .N), by = col_tmp]
            file <- file[sens > cutoff, `:=` (count = count + 1, col = cols[i], id = idtmp)][, idtmp := NULL]
            
            if(!any(file[["count"]] < 2)) break
            rm(col_tmp, idfile)
            
          }
        
        
        file1 <- file[count != 1,]
        scheme <- unique(file[count == 1,][, .(col, id)])
        
        rm(cols)
        
        if(nrow(scheme) > 0){
          file2 <- list()
          for(i in 1:nrow(scheme)){
          
            
                c.col <- scheme[i,][["col"]]
                c.id <- scheme[i,][["id"]]
                
                tmp <- copy(file)[id == c.id & col == c.col & count == 1,]
                
                #cols <- colnames(file)[!colnames(file) %in% c(c.col , "Study_variable", "sens", "count", "meanN", "col")]
                #tmp <- tmp[, id2 := paste0(nchar(do.call(paste0, .SD)), id), .SDcols = cols]
                
                check <- suppressWarnings(sum(is.na(as.numeric(tmp[[c.col]]))))
                
                
                if(check == 0) tmp <- tmp[, eval(c.col) := NULL][, eval(c.col) := "NUM"] 
                if(check == length(tmp[[c.col]])) tmp <- tmp[, eval(c.col) := NULL][, eval(c.col) := "CHAR"] 
                if(check > 0 & check < length(tmp[[c.col]])) tmp <- tmp[, eval(c.col) := NULL][, eval(c.col) := "CHAR/NUM"]
                
                
                
                file2[[i]] <- tmp
                
                rm(c.col, c.id, tmp)
          
          }
          file2 <- do.call(rbindlist, list(file2, fill = T, use.names = T))[, N := sum(N), by = "id"]
          
        }else{file2 <- file[0]}
        
        rm(scheme, file)
        
        
        cols <- colnames(file1)[!colnames(file1) %in% c("Study_variable", "sens", "count", "meanN", "col", "id", "id2")]
        file2 <- unique(file2[, cols, with = F])
        
        
        
        file1 <- unique(file1[, cols, with = F])
        
        result <- rbindlist(list(file1, file2), fill = T, use.names = T)
        
        setnames(result , "N", c.N)
        
        setcolorder(result, c.order)
        
        return(result)


}


#test <- DetectValues(
#  file = data,
#  c.N = "N"
#  
#  )
