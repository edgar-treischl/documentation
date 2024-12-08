
## Data bases

###  Create a minimal sql working example


```r
library(DBI)
library(RSQLite)

# Create in-memory RSQLite database
con <- dbConnect(drv = RSQLite::SQLite(), 
                 dbname = ":memory:")

#Write a table into the data base
dbWriteTable(conn = con, 
             name = "mtcars", 
             value = mtcars)

library(sqldf)
sqldf('select avg(mpg) from mtcars;')
```

## Deploy

### Create a docker file from renv

```r
dockerfiler::dock_from_renv()
```



