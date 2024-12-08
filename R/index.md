__
Example of Webscraping:
- Download badges from [[Credly]]

### Extract R chunks from Obsedian

```r
input_md_file <- "~/Documents/GitHub/obsidian_docs/R/Snippets.md"

md_content <- readLines(input_md_file)

# Initialize list to hold R code chunks
r_code <- list()

# Flag to track if inside an R code chunk
inside_chunk <- FALSE
current_chunk <- ""

# Iterate through the lines of the file
for (line in md_content) {
  # Start of an R code chunk
  if (grepl("^```r", line)) {
    inside_chunk <- TRUE
    current_chunk <- ""  # Reset the current chunk
  } 
  # End of an R code chunk
  else if (grepl("^```", line) && inside_chunk) {
    inside_chunk <- FALSE
    r_code <- append(r_code, current_chunk)  # Add the current chunk (without delimiters)
  }
  # Collect R code inside a chunk
  else if (inside_chunk) {
    current_chunk <- paste(current_chunk, line, sep = "\n")
  }
}

# Combine the extracted R code into a single block of text
r_code_text <- paste(r_code, collapse = "\n")

# Optionally, print the extracted code for debugging
cat(r_code_text)

# Write the extracted code to an R file
writeLines(r_code_text, output_r_file)


```
