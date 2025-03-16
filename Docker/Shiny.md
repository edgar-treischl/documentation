## Run Example App in Docker

```r
# Use the rocker/shiny base image
FROM rocker/shiny:latest

# Install system dependencies
RUN apt-get update -qq && apt-get install -y \
    libcurl4-openssl-dev \
    libxml2-dev \
    libssl-dev \
    pandoc

# Copy the app files into the container
COPY app /srv/shiny-server/app

# Expose the port where the app will run
EXPOSE 3838

# Run the Shiny app
CMD ["R", "-e", "shiny::runApp('/srv/shiny-server/app', host = '0.0.0.0', port = 3838)"]
```
