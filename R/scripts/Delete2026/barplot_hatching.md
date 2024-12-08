```r
library(ggplot2)
library(dplyr)
library(ggpattern)

p <- ggplot(mtcars, aes(x = factor(cyl), fill = factor(cyl))) + 
  geom_bar(data = mtcars |>  filter(cyl == 4 | cyl == 6)) + 
  geom_bar_pattern(data = mtcars |>  filter(cyl == 8),
    aes(pattern = factor(cyl), pattern_angle = factor(cyl)),
    pattern = 'stripe',
    fill            = 'white',
    colour          = 'black',
    pattern_spacing = 0.020
  )+
  theme_minimal() + 
  labs(title = "Bar plot with hatching", x = "Cylinders", y = "Count")+
  #scale_fill_brewer(palette = "Set1")+
  theme(legend.position = "none")


#save the plot p to a file
#ggsave("barplot_hatching.png", plot = p, device = "png", width = 6, height = 4, units = "in", dpi = 300)

```
