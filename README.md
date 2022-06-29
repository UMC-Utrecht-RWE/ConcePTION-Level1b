# Aim
The aim of this script is to explore which data is stored in the CDM. This can be compared to the study specific specifications of the study variables.

# Instruction

1 Download the ZIP folder and extract the contents.

2 Open the to_run.R file with Rstudio

3 Fill the variable path with the location of the CDM tables (csv files) and set StudyName to NULL, OR fill the variable StudyName with the foldername where the CDM tables are stored in CDMinstances and set path to NULL. 

4 By default the variables t.interest is set to NULL. In that situation all the CDM tables that are found are analysed. You can also specify the variable t.interest    yourself.

5 By default GetCountsColumns is set to FALSE. If you set this to TRUE also counts per columns are executed in addition to the unique row count.

6 Run the ro_run file

7 Go to g_output and upload the csv file(s)to DRE
