Create/run a cron job

```r
#this script will create a function to set a cron job with R
#the cron job will run the script every night at 00:01
#the script name is: analysis.R and lives in the prog directory
#the description of the cron job is: Run Evaluation Reports

add_cron_job <- function(file){
  #cronR to develope fun
  #cronR::cron_clear(ask = FALSE)
  #cronR::cron_ls()
  
  #get R cmd from file
  cmd <- cronR::cron_rscript(file)
  
  #create a cron job
  cronR::cron_add(command = cmd, 
                  description = "Run Evaluation Reports",
                  frequency = "daily", 
                  at = "15:15")
}

add_cron_job(file = "/Users/edgar/barplot_hatching.R")


cronR::cron_clear(ask = FALSE)
cronR::cron_ls()

```
