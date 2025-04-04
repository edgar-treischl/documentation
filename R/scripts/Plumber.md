## Run Plumber

```r
# # Load the plumber package
# library(plumber)
# 
# # Create and run the plumber API
# pr <- plumber::plumb("plumber.R")
# pr$run(host = "0.0.0.0", port = 8001)

library(plumber)

# Define the Plumber API
pr <- plumb("plumber.R")

# Add CORS support
pr$filter("cors", function(req, res) {
  res$setHeader("Access-Control-Allow-Origin", "*")
  res$setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
  res$setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization")
  
  if (req$REQUEST_METHOD == "OPTIONS") {
    res$status <- 200
    return(list())
  } else {
    forward()
  }
})

# Run the API
pr$run(host = "0.0.0.0", port = 8001)
```

Return Data To Test

```r
# Load required libraries
library(plumber)

#* @apiTitle Static Data API

#* Fetch hardcoded data
#* @get /data
function() {
  # Hardcoded data
  # data <- data.frame(
  #   column1 = c("value1", "value3"),
  #   column2 = c("value2", "value4")
  # )
  
  # Return the data as JSON
  mtcars
}
```
