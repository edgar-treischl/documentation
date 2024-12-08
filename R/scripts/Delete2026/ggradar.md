
Raw material to delete?

```r
# install.packages("ggplot2")
#library(ggplot2)
library(tidyverse)

# Data
set.seed(4)
df <- data.frame(group = 1:10,
                 name = letters[1:10],
                 outcome = sample(1:10))


stat <- NULL
check <- stat == "identity"
check

ggpolar <- function(data, x, y, 
                    fill = NULL,
                    color = NULL,
                    alpha = NULL, 
                    identity = TRUE) {
  
  check <- identity == TRUE
  
  if (check == TRUE) {
    ggplot2::ggplot(data, ggplot2::aes(x = {{x}}, y = {{y}}, 
                                       fill = {{fill}},
                                       color = {{color}},
                                       alpha = {{alpha}})) +
      ggplot2::geom_bar(stat = "identity",
                        lwd = 1)+
      ggplot2::coord_polar() 
  } else {
    data %>% 
      group_by({{x}}) %>% 
      summarise(y = mean({{y}})) %>% 
      ggplot(aes(x = {{x}}, y = y, 
                 fill = {{fill}},
                 color = {{color}},
                 alpha = {{alpha}})) +
      geom_bar(stat = "identity", color = "white",
               lwd = 1)+
      coord_polar() 
  }
  
}

ggpolar(df, group, outcome, color = name)
ggpolar(df, group, outcome, fill = name)
ggpolar(df, group, outcome, alpha = name)


library(palmerpenguins)
penguins %>% 
  drop_na() %>% 
  ggpolar(., x = species, y = bill_length_mm, fill = species,
          identity = TRUE)




  


ggpolar_example <- function(data, x, y, 
                    fill = NULL,
                    color = NULL) {
  
  data %>% 
    group_by({{x}}) %>% 
    summarise(y = mean({{y}})) %>% 
    ggplot(aes(x = {{x}}, y = y, 
               fill = {{fill}})) +
    geom_bar(stat = "identity", color = "white",
             lwd = 1)+
    coord_polar() 
  
}

ggpolar(diamonds, x = cut, y = price, fill = cut)
ggpolar(mtcars, x = gear, y = hp, fill = gear)

```
