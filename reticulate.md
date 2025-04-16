```r
library(reticulate)

#virtualenv_create("triggerR-env")

use_virtualenv("triggerR-env", required = TRUE)

#py_config()


source_python("pg_listener.py")


reticulate::virtualenv_remove("triggerR-env", confirm = FALSE)


#py_install("requests")


#reticulate::py_install("psycopg2-binary")


#py_require("psycopg2")


# Define your R callback
r_callback <- function(payload) {
  cat("🔍 Payload from DB:", payload, "\n")
  # You can parse the payload and call pointblank validations here
  data <- fromJSON(payload)
  # validate_data(payload)
}

# Start listener from R
listen_pg(callback = r_callback)

```
