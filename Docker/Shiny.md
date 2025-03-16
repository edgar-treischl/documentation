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


```r
mkdir my-shiny-app

cd my-shiny-app

docker build -t my-shiny-app .

docker run -p 3838:3838 my-shiny-app


http://104.248.23.57:3838

# Permamently run the container
docker run -d -p 3838:3838 my-shiny-app

docker ps
```
