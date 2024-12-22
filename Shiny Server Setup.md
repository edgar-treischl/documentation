This script automates the installation of various software packages on an Ubuntu-based server, including R, RStudio, Shiny Server, and Nginx, as well as setting up security measures such as Fail2ban and a UFW firewall.

### 01 Update the System

This part updates the package lists and upgrades installed packages to their latest versions. If any of these steps fail, the script will output an error message and exit.

```bash
#!/bin/bash
# Update system
apt-get update || { echo 'ERROR: apt-get update failed' >&2; exit 1; }
apt-get upgrade -y || { echo 'ERROR: apt-get upgrade failed' >&2; exit 1; }
```

### 02 Install Required Dependencies

Installs various dependencies required for the installation of RStudio, Shiny, Nginx, and other necessary libraries like SSL, Java, and PostgreSQL development packages.

```bash
# Install dependencies
apt-get install -y gdebi-core libssl-dev libcurl4-openssl-dev libxml2-dev default-jdk fail2ban nginx libsodium-dev libpq-dev libopenblas-dev pandoc-citeproc texlive-full libfreetype6-dev libfontconfig1-dev
```

### 03 Add R Repository and Install R

Adds the CRAN repository for R to Ubuntu’s package manager. Installs the base R package and development tools.

```bash
# Add R repository
wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu 22.04-cran40/"
apt-get update
apt-get install -y r-base r-base-dev
```

### 04 Install RStudio Server 

Downloads and installs the latest version of RStudio Server. Removes the `.deb` file after installation.

```bash
# Install RStudio Server
RSTUDIO_LATEST=$(wget --no-check-certificate -qO- https://download2.rstudio.org/server/jammy/amd64/VERSION)
wget -q https://download2.rstudio.org/server/jammy/amd64/rstudio-server-${RSTUDIO_LATEST}-amd64.deb
gdebi -n rstudio-server-${RSTUDIO_LATEST}-amd64.deb
rm rstudio-server-*-amd64.deb
```

### 05 Install Shiny Server

Installs the Shiny package from CRAN. Downloads and installs Shiny Server. Removes the `.deb` file after installation.

```bash
# Install Shiny and Shiny Server
R -e "install.packages('shiny', repos='https://cran.rstudio.com/')"
wget https://download3.rstudio.org/ubuntu-22.04/x86_64/shiny-server-1.5-amd64.deb
gdebi -n shiny-server-*-amd64.deb
rm shiny-server-*.deb
```

### 06: Set Up Shiny App Directory and Permissions

Creates the Shiny app directory `/srv/shiny-server` and sets the correct ownership and permissions for the Shiny user.

Creates directories for logging and sets up necessary log files for both RStudio Server and Shiny Server.
```bash
# Ensure Shiny app directory exists with correct permissions
mkdir -p /srv/shiny-server
chown -R shiny:shiny /srv/shiny-server
chmod -R 755 /srv/shiny-server

# Configure logging directories and permissions
mkdir -p /var/log/rstudio
mkdir -p /var/log/shiny-server
touch /var/log/rstudio/rserver-http-access.log
touch /var/log/shiny-server/shiny-server.log
chown -R rstudio-server:rstudio-server /var/log/rstudio
chown -R shiny:shiny /var/log/shiny-server
```

### 07: Configure RStudio Server and Shiny Server Logging

Configures logging for both RStudio Server and Shiny Server, defining log levels and paths.

```bash
# Configure RStudio Server logging
cat > /etc/rstudio/logging.conf <<EOL
[@access]
log-level=info
logger-type=file
path=/var/log/rstudio/rserver-http-access.log
EOL

# Configure Shiny Server logging
cat > /etc/shiny-server/shiny-server.conf <<EOL
# Define the user we should use when spawning R Shiny processes
run_as shiny;

# Define a top-level server which will listen on a port
server {
  listen 3838;

  # Define the location available at the base URL
  location / {
    site_dir /srv/shiny-server;
    log_dir /var/log/shiny-server;
    directory_index on;
  }
}

# Configure logging
preserve_logs true;
access_log /var/log/shiny-server/access.log;
server_log /var/log/shiny-server/server.log;
EOL
```

### 08 Configure Log Rotation for Shiny Server

Configures log rotation for Shiny Server logs to ensure they do not consume excessive disk space.
```bash
# Configure logrotate for Shiny Server
cat > /etc/logrotate.d/shiny-server <<EOL
/var/log/shiny-server/*.log {
    rotate 7
    daily
    missingok
    notifempty
    compress
    delaycompress
    postrotate
        systemctl reload shiny-server > /dev/null 2>/dev/null || true
    endscript
    create 0644 shiny shiny
}
EOL

```

### 09 Restart Shiny Server and Verify Log Creation

Restarts Shiny Server to apply configuration changes and checks that the log files are being written.
```bash
# Test Shiny Server configuration
if ! systemctl restart shiny-server; then
    echo 'ERROR: Shiny Server failed to restart with new configuration' >&2
    exit 1
fi

# Verify log files are being written
sleep 2
if [ ! -f /var/log/shiny-server/server.log ]; then
    echo 'WARNING: Shiny Server log file not created' >&2
fi

```

### 10 Configure Fail2ban for RStudio and Shiny Server

Configures Fail2ban to monitor login attempts for both RStudio Server and Shiny Server. Specifies how failed login attempts should be detected and defines banning policies.

```bash
# Configure Fail2ban for RStudio and Shiny Server
cat > /etc/fail2ban/jail.local <<EOL
[rstudio-server]
enabled = true
port = 8787
filter = rstudio-server
logpath = /var/log/rstudio/rserver-http-access.log
maxretry = 3
bantime = 3600

[shiny-server]
enabled = true
port = 3838
filter = shiny-server
logpath = /var/log/shiny-server.log
maxretry = 3
bantime = 3600
EOL

cat > /etc/fail2ban/filter.d/rstudio-server.conf <<EOL
[Definition]
failregex = ^.*Failed login attempt for user .* from IP <HOST>.*$
ignoreregex =
EOL

cat > /etc/fail2ban/filter.d/shiny-server.conf <<EOL
[Definition]
# Detect failed authentication attempts
failregex = ^.*Error in auth.: .* \[ip: <HOST>\].*$
            ^.*Unauthenticated request: .* \[ip: <HOST>\].*$
            ^.*Invalid authentication request from <HOST>.*$
            ^.*Authentication error for .* from <HOST>.*$
            ^.*Failed authentication attempt from <HOST>.*$
ignoreregex =
EOL

systemctl restart fail2ban
```

### 11 Install and Configure UFW Firewall

Installs UFW and configures it to allow SSH, HTTP, HTTPS, RStudio (port 8787), and Shiny (port 3838). Verifies that UFW is active.

```r
# Install and configure UFW firewall
apt-get install -y ufw
ufw allow ssh
ufw allow http
ufw allow https
ufw allow 8787/tcp
ufw allow 3838/tcp
echo 'y' | ufw enable
if ! ufw status | grep -q 'Status: active'; then
    echo 'ERROR: UFW is not active after enabling' >&2
    exit 1
fi
echo 'UFW is active and configured with the following rules:'
ufw status verbose | tee -a /var/log/ufw-configuration.log
```

### 12 Configure NGINX as Reverse Proxy

Configures NGINX to act as a reverse proxy for both RStudio and Shiny Server. Adds support for WebSockets.

```bash
# Configure NGINX as reverse proxy
cat > /etc/nginx/sites-available/r-proxy <<EOL
server {
    listen 80;
    server_name _;

    # RStudio Server
    location /rstudio/ {
        rewrite ^/rstudio/(.*) /\$1 break;
        proxy_pass http://localhost:8787;
        proxy_redirect http://localhost:8787/ \$scheme://\$http_host/rstudio/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \$connection_upgrade;
        proxy_read_timeout 20d;
        proxy_buffering off;
    }

    # Shiny Server
    location /shiny/ {
        rewrite ^/shiny/(.*) /\$1 break;
        proxy_pass http://localhost:3838;
        proxy_redirect http://localhost:3838/ \$scheme://\$http_host/shiny/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \$connection_upgrade;
        proxy_read_timeout 20d;
        proxy_buffering off;
    }
}
EOL

# Add websocket support
cat > /etc/nginx/conf.d/websocket-upgrade.conf <<EOL
map \$http_upgrade \$connection_upgrade {
    default upgrade;
    ''      close;
}
EOL
```

### 13 Enable NGINX Site and Test Configuration

Enables the NGINX reverse proxy configuration, tests it, and restarts NGINX.

```bash
# Enable the site and remove default
ln -s /etc/nginx/sites-available/r-proxy /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Test NGINX configuration
if ! nginx -t; then
    echo 'ERROR: NGINX configuration test failed' >&2
    exit 1
fi
systemctl restart nginx

# Verify NGINX is running
if ! systemctl is-active --quiet nginx; then
    echo 'ERROR: NGINX failed to restart' >&2
    exit 1
fi
```


### 14 Verify Critical Services Are Running

Verifies that NGINX, RStudio Server, Shiny Server, and Fail2ban are all running.

```bash
# Verify critical services are running
for service in nginx rstudio-server shiny-server fail2ban; do
    if ! systemctl is-active --quiet $service; then
        echo "ERROR: $service is not running" >&2
        exit 1
    fi
done
```

### 15 Install and Configure R Packages

Installs the `pak` package manager and several useful R packages for data manipulation, visualization, and development.

```bash
# Install pak and R packages
R --vanilla << EOF || { echo 'ERROR: R package installation failed' >&2; exit 1; }
install.packages('pak', repos = 'https://r-lib.github.io/p/pak/dev/')
pak::pkg_install(c('DBI', 'RPostgreSQL', 'dbplyr', 'dplyr', 'tidyr', 'readr', 'purrr', 'stringr', 'forcats', 'lubridate', 'jsonlite', 'devtools', 'roxygen2', 'testthat', 'rmarkdown', 'pkgdown', 'tinytex', 'ggplot2', 'showtext', 'ggtext', 'plotly', 'shiny', 'htmltools', 'bslib', 'xml2', 'parallel', 'future', 'furrr'))
q()
EOF
```
