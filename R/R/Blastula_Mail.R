library(blastula)
library(tidyverse)

email <- compose_email(
  body = "Hello,
  
  I just wanted to give you an update of our work.
  
  Cheers, Edgar")



salutation <- "Cheerio,"
sender_name <- "Edgar"

#Add Graphs
library(gapminder)

plot <- gapminder %>% 
  filter (continent == "Europe") %>%
  ggplot(aes(x=lifeExp)) +
  geom_density()+
  facet_wrap(year ~ ., nrow=2)+
  ggtitle("Europe")

plot

mail_plot <- add_ggplot(plot_object = plot)



library(glue)

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



compose_email(body = body_text)

email <- compose_email(body = body_text)




#MyCreate cred
create_smtp_creds_file(
  file = "mail_creds",
  user = "edgar.treischl@fau.de",
  host = "smtp-auth.fau.de",
  port = 587,
  use_ssl = TRUE
   )

#Gmail Example
create_smtp_creds_key(
  id = "gmail",
  user = "user_name@gmail.com",
  host = "smtp.gmail.com",
  port = 465,
  use_ssl = TRUE
)


setwd("C:/Users/gu99mywo/Dropbox/R in Practice/Book/Chapters_R/08_Report_Findings")

#Send mail
email %>%
  add_attachment(file = "Mail.html", filename = "Mail") %>%
  smtp_send(
    to = "edgar.treischl@me.com",
    from = "edgar.treischl@fau.de",
    subject = "Update on project X",
    credentials = creds_file("mail_creds")
  )




