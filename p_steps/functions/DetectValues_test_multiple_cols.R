


data <- readRDS("C:/ConcePTION-Level1b/g_intermediate/WHERECLAUSE_VACCINES.rds")

#data <- data[, N := as.numeric(gsub("<", "", N_masked))][, N_masked := NULL ]

file <- data
c.N <- "N"
cutoff <- 10

#DetectValues <- function(file, c.N, cutoff = 30){

  
file <- copy(file)  
setnames(file, c.N, "N")
c.order <- c("N",colnames(file)[!colnames(file) %in% "N"])

file <- file[, `:=` (sens = as.numeric(), sens.keep = 0,  count = 0, col = as.character(), id = as.numeric())  ]
#file <- file[, `:=`  ( meanN = mean(N)), by = col_tmp]

cols <- colnames(file)[!colnames(file)  %in% c("N", "Study_variable", "sens", "sens.keep", "count", "meanN", "col", "id")]
cols2 <-  as.data.table(expand.grid(cols, cols, stringsAsFactors = F))
#[Var1 != Var2,]

cols2 <- cols2[, Var3 :=  fifelse(Var1 == Var2, 1, 2)]
setorder(cols2, Var3)[, Var3 := NULL]
cols2t <- split(as.data.frame(cols2), c(1:nrow(cols2)))

#t <- (cols2t[2])
cols2 <- as.list(as.data.frame(t(cols2)))



#col_tmp <- paste0(unname(cols[[1]]), collapse = "|")
i <- 7
          for(i in 1:length(cols2)){
            
            
            col_tmp <- cols[!cols %in% c(cols2[[i]], "N", "Study_variable", "sens", "sens.keep", "count", "meanN", "col", "id")]
            
            idfile <- unique(file[, col_tmp, with = F])[, idtmp := as.numeric(paste0(i, seq_len(.N)))] 
            file <- merge(file, idfile, by = col_tmp, all.x = T) 
            
            file <- file[, `:=`  (sens = .N), by = col_tmp]
            file <- file[sens > cutoff & sens > sens.keep, `:=` (count = count + 1, sens.keep = sens, col = paste0(cols2[[i]], collapse = "|"), id = idtmp)][, idtmp := NULL]
            
            #if(!any(file[["count"]] < 2)) break
            rm(col_tmp, idfile)
            
          }
        
        
        file1 <- file[count == 0,]
        scheme <- unique(file[count > 0,][, .(col, id)])
        
        rm(cols)
        
        if(nrow(scheme) > 0){
          file2 <- list()
          for(i in 1:nrow(scheme)){
          
            
                c.col <- scheme[i,][["col"]]
                c.id <- scheme[i,][["id"]]
              
                tmp <- copy(file)[id == c.id & col == c.col & count == 1,]
                
                #cols <- colnames(file)[!colnames(file) %in% c(c.col , "Study_variable", "sens", "count", "meanN", "col")]
                #tmp <- tmp[, id2 := paste0(nchar(do.call(paste0, .SD)), id), .SDcols = cols]
                
                for(j in unlist(strsplit(c.col, "\\|"))){
                
                check <- suppressWarnings(sum(is.na(as.numeric(tmp[[j]]))))
                
                if(check == 0) tmp <- tmp[, eval(j) := NULL][, eval(j) := "NUM"] 
                if(check == length(tmp[[j]])) tmp <- tmp[, eval(j) := NULL][, eval(j) := "CHAR"] 
                if(check > 0 & check < length(tmp[[j]])) tmp <- tmp[, eval(j) := NULL][, eval(j) := "CHAR/NUM"]
                rm(check)
                }
                
                
                file2[[i]] <- tmp
                
                rm(c.col, c.id, tmp)
          
          }
          file2 <- do.call(rbindlist, list(file2, fill = T, use.names = T))[, N := sum(N), by = "id"]
          
        }else{file2 <- file[0]}
        
        rm(scheme, file)
        
        
        cols <- colnames(file1)[!colnames(file1) %in% c("Study_variable", "sens", "sens.keep",  "count", "meanN", "col", "id", "id2")]
        file2 <- unique(file2[, cols, with = F])
        
        
        
        file1 <- unique(file1[, cols, with = F])
        
        result <- rbindlist(list(file1, file2), fill = T, use.names = T)
        
        setnames(result , "N", c.N)
        
        setcolorder(result, c.order)
        
        return(result)


#}


#test <- DetectValues(
#  file = data,
#  c.N = "N"
#  
#  )
