#Load demanded packages
if(!require(data.table)){install.packages("data.table")}
suppressPackageStartupMessages(library(data.table))

if(!require(lubridate)){install.packages("lubridate")}
suppressPackageStartupMessages(library(lubridate))

if(!require("rlist")){install.packages("rlist")}
suppressPackageStartupMessages(library("rlist"))

if(!require("DBI")){install.packages("DBI")}
suppressPackageStartupMessages(library(DBI))

if(!require("Rcpp")){install.packages("Rcpp")}
suppressPackageStartupMessages(library("Rcpp"))

if(!require("sqldf")){install.packages("sqldf")}
suppressPackageStartupMessages(library("sqldf"))

if(!require("RSQLite")){install.packages("RSQLite")}
suppressPackageStartupMessages(library(RSQLite))