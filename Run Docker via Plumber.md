Plumber

```r
library(plumber)

#' @post /run_validation
function(req, res) {
  # Get table_name from the incoming HTTP POST request body
  table_name <- req$body$table_name
  
  # Validate the input (check if table_name is provided)
  if (is.null(table_name) || table_name == "") {
    res$status <- 400
    return(list(error = "Table name is required."))
  }

  # Call the run_validation function with the table_name
  # You can also pass a config file if needed
  tryCatch({
    run_validation(table_name = table_name)
    # If the validation was successful, return a success message
    list(success = TRUE, message = paste("Validation and GitLab push completed for table:", table_name))
  }, error = function(e) {
    # If an error occurs, return an error message
    res$status <- 500
    list(error = "Validation or GitLab push failed", details = e$message)
  })
}

# Create a plumber router
pr <- plumb("plumber_api.R")

# Run the API on port 8000
pr$run(port = 8000)


```



Orchestrate

```r
# run_validation.R

# run_validation.R

# Function that performs the validation for a given table name
run_validation <- function(table_name, config = NULL) {
  # Load necessary libraries
  library(octopussy)
  library(spectr)

  # Run the validation pipeline using octopussy
  cat("Starting validation for table: ", table_name, "\n")

  if (!is.null(config)) {
    cat("Using config file: ", config, "\n")
    octopussy::validate(table_name = table_name, config = config)
  } else {
    octopussy::validate(table_name = table_name)
  }

  # Push the results to GitLab using spectr
  cat("Pushing results to GitLab...\n")
  spectr::push_files_to_gitlab(table_name = table_name)

  cat("Validation and GitLab push completed for table: ", table_name, "\n")
}

# Example: Run validation with a hardcoded table_name for testing (you can remove this later)
# run_validation("users")


```




```r
# Start from a base R image
FROM rocker/r-ver:4.2.3

# Install system dependencies for building R packages
RUN apt-get update -y && apt-get install -y \
  libcurl4-openssl-dev \
  libssl-dev \
  libgit2-dev \
  libxml2-dev \
  git \
  && rm -rf /var/lib/apt/lists/*

# Install R packages needed for octopussy, spectr, and pointblank
RUN R -e "install.packages('remotes')"
RUN R -e "remotes::install_github('your_org/octopussy')"
RUN R -e "remotes::install_github('your_org/spectr')"
RUN R -e "remotes::install_github('rich-iannone/pointblank')"

# Set working directory
WORKDIR /data

# Copy the R script that will run the validation pipeline
COPY run_validation.R /data/run_validation.R

# Expose port for API (optional if running the API inside the container)
EXPOSE 8000

# Set entry point to run the validation with the passed arguments
ENTRYPOINT ["Rscript", "/data/run_validation.R"]


```



## Curl the result

```r
curl -X POST http://localhost:8000/run_validation \
     -H "Content-Type: application/json" \
     -d '{"table_name": "users"}'

```
