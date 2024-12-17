__
Example of Webscraping:
- Download badges from [[credly]]

### Extract R chunks from Obsedian


```r
md_content <- readLines("~/Documents/GitHub/documentation/R/Snippets.md")
md_content

MDtoR <- function(file,
                  export = FALSE) {
  md_content <- readLines(file)
  
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
  
  if (export) {
    # Write the extracted code to an R file
    output_file <- sub("\\.md$", ".R", file)
    
    # Write the extracted code to the output R file
    writeLines(r_code_text, output_file)
    cat("R code saved to:", output_file, "\n")
    
  }else {
    return(cat(r_code_text))
  
  }
}

MDtoR(file = "~/Documents/GitHub/documentation/R/Snippets.md")


RtoMD <- function(file, export = FALSE) {
  r_code <- readLines(file)  # Read the R script line by line
  
  # Initialize an empty vector to hold the final markdown content
  md_content <- c()
  
  # Initialize variables for managing R chunks
  inside_chunk <- FALSE
  empty_lines <- 0
  
  # Loop through each line of R code
  for (line in r_code) {
    
    # Handle lines starting with #'
    if (grepl("^#'", line)) {
      line <- sub("^#'", "#", line)  # Replace '#'' with '#'
    }
    
    # If the line is a comment (starts with #), check how many # are at the beginning
    if (grepl("^#", line)) {
      
      # Check if the line starts with more than three '#' (i.e., a header)
      num_hashes <- nchar(gsub("[^#]", "", line))  # Count the number of '#' at the beginning
      if (num_hashes > 3) {
        # Remove the leading '###' or more and insert only the comment text
        line <- substr(line, num_hashes + 1, nchar(line))
        md_content <- c(md_content, paste0("###", line))  # Treat as a header
      } else {
        # Insert a blank line before comments if an R chunk has been inserted
        if (length(md_content) > 0 && grepl("^```r", tail(md_content, 1))) {
          md_content <- c(md_content, "")  # Add a blank line after closing the previous R chunk
        }
        
        # Trim any leading whitespace from the comment and add it as markdown
        md_content <- c(md_content, paste0("#", substr(line, 2, nchar(line))))  # Remove leading whitespace
      }
      
      empty_lines <- 0  # Reset empty lines counter when encountering a comment
    } else if (line == "") {
      # Handle empty lines
      empty_lines <- empty_lines + 1
      if (empty_lines >= 2 && inside_chunk) {
        md_content <- c(md_content, "```")  # Close the R chunk if more than two empty lines
        inside_chunk <- FALSE
      }
    } else {
      # For non-empty, non-comment lines (R code)
      if (!inside_chunk) {
        # Add a blank line before starting an R code chunk
        if (length(md_content) > 0) {
          md_content <- c(md_content, "")  # Add a blank line before starting a new R chunk
        }
        md_content <- c(md_content, "```r")  # Start a new R code chunk
        inside_chunk <- TRUE
      }
      md_content <- c(md_content, line)
      empty_lines <- 0  # Reset empty lines counter when encountering R code
    }
  }
  
  # If still inside an R chunk at the end, close it
  if (inside_chunk) {
    md_content <- c(md_content, "```")
  }
  
  # Combine all lines of the markdown content
  md_content_text <- paste(md_content, collapse = "\n")
  
  if (export) {
    # Generate the output file name by replacing the .R extension with .md
    output_file <- sub("\\.R$", ".md", file)
    
    # Write the markdown content to the file
    writeLines(md_content_text, output_file)
    cat("Markdown file saved to:", output_file, "\n")
  } else {
    # Return the Markdown content as a string
    return(md_content_text)
  }
}




RtoMD(file = here::here("R", "limer.R"), export = TRUE)


```


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
