## Function template from MetaMaster

```r
#Add file "MetaMasterMeta.xlsx"
  metadf <- readxl::read_excel("excel.xlsx")

  #get date and time and add it to the subject
  date <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  mailsubject <- paste("Update on bla", date)

  #The mail template
  file_path <- system.file("rmarkdown/templates/mail/skeleton/skeleton.Rmd", package = "MetaMaster")
  file.copy(file_path, to = here::here("template_mail.Rmd"))

  #Build the email with the template
  email <- blastula::render_email("template_mail.Rmd")|>
    blastula::add_attachment(file = "MetaMaster.xlsx")

  #Get the mail recipient and sender from the config file
  get <- config::get(file = "config.yml")
  report_from <- get$report_from
  report_to <- get$report_to

  # Send the email with smtp_send
  email |>
    blastula::smtp_send(
      to = report_to,
      from = report_from,
      subject = mailsubject,
      credentials = blastula::creds_file("my_mail_creds")
    )
```


### Template

```r
---
title: "Title"
output: blastula::blastula_email 
---


knitr::opts_chunk$set(echo = TRUE)
get <- config::get(file = here::here("config.yml"))
report_to <- get$report_to

split <- strsplit(report_to, "@")[[1]]
string <- split[1]

<img src= "man/figures/logo_small.png" align="right">
<br>
<br>
<br>
<br>


## Dear `r string`,
```


## Minimal example with credentials

```r
library(blastula)
library(tidyverse)
library(gapminder)
library(glue)

#Create email
email <- compose_email(
  body = "Hello,
  
  I just wanted to give you an update of our work.
  
  Cheers, Edgar")


#Some additional text
salutation <- "Cheerio,"
sender_name <- "Edgar"

#Add Graphs
plot <- gapminder |> 
  filter (continent == "Europe") |> 
  ggplot(aes(x=lifeExp)) +
  geom_density()+
  facet_wrap(year ~ ., nrow=2)+
  ggtitle("Europe")

#Add ggplot to email
mail_plot <- add_ggplot(plot_object = plot)

#Put together

body_text <-
  md(glue(
    "
## Hello my friend,

I just wanted to send you an update of your work, look at this
awesome graph:

{mail_plot}

{salutation}

{sender_name}
"    
  ))



#Compose email
email <- compose_email(body = body_text)


#MyCreate cred
create_smtp_creds_file(
  file = "mail_creds",
  user = "edgar.treischl@somewhere.com",
  host = "smtp-auth.fau.de",
  port = 587,
  use_ssl = TRUE
   )

#Gmail Example
# create_smtp_creds_key(
#   id = "gmail",
#   user = "user_name@gmail.com",
#   host = "smtp.gmail.com",
#   port = 465,
#   use_ssl = TRUE
# )



#Send mail
email %>%
  add_attachment(file = "Mail.html", filename = "Mail") %>%
  smtp_send(
    to = "edgar.treischl@somewhere.com",
    from = "edgar.treischl@somewhere.com",
    subject = "Update on project X",
    credentials = creds_file("mail_creds")
  )


```




