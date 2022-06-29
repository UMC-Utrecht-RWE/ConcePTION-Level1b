# Aim
The aim of this script is to explore which data is stored in the CDM. This can be compared to the study specific specifications of the study variables.

# Instruction

1. Download the ZIP folder and extract the contents.

2. Open the to_run.R file with Rstudio

3. Fill, at the beginning of the to_run file, the variable path with the location of the CDM tables (csv files) and set StudyName to NULL, OR fill the variable StudyName with the foldername where the CDM tables are stored in CDMinstances and set the variable path to NULL. 

4. By default the variable t.interest (at the beginnning of the to_run) is set to NULL. In that situation all the CDM tables that are found are analysed. You can also specify the variable t.interest yourself (example: t.interest <- c("EVENTS","MEDICAL_OBSERVATIONS")).

5. By default the variable  GetCountsColumns (at the beginnning of the to_run) is set to FALSE. If you set this to TRUE also counts per columns are executed in addition to the unique row count.

6. Run the whole to_run file

7. Go to g_output and upload the csv file(s)to DRE (see below)


# Uploading to anDREa

1.	In a web browser, Go To: mydre.org.

2.	Click on 'Click here to login'. Pick an account and enter password.

3.	Click on Workspaces in upper left and then double click on the project workspace.

4.	Click on Files tab at top.

5.	Double click on 'inbox' folder.

6.	Click on '(DAPNAME/)Level 1 & 2'.

7.	Create a folder by clicking on the folder icon with + on it.

8.	Name the folder with the name of the data source, quality check level number and the date of running/uploading. Example if the data source ARS is uploading the level 1b checks output on the 28 September 2021, the folder should be named: ARS_level1b_2021_09_28.

9.	Click on the folder you created.

10.	Click on cloud icon to upload files.

11.	Click on select and upload.

12.	Open the /g_output/. Hold down control and select all files within your prepared folder.

13.	Click on open.

14.	When it asks to confirm: "Would like to upload the inbox?" select 'OK'.

15.	Note: It may take many minutes for your upload to complete. You should receive an email once they are uploaded.

16.	If you find that your files are not in the corresponding level directory, check if the files are in the inbox and move them to the corresponding level directory.

