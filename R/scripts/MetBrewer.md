## MetBrewer Examples

```r
#install.packages("MetBrewer")
library(MetBrewer)
library(ggplot2)

#Self-Portrait with a Straw Hat 

ggplot(data=iris, aes(x=Species, y=Petal.Length, fill=Species)) +
  geom_violin() +
  scale_fill_manual(values=met.brewer("VanGogh2", 3))


ggplot(data=iris, aes(x=Species, y=Petal.Length, fill=Species)) +
  geom_violin() +
  scale_fill_manual(values=met.brewer("Monet", 3))


ggplot(data=iris, aes(x=Species, y=Petal.Length, fill=Species)) +
  geom_violin() +
  scale_fill_manual(values=met.brewer("Pissaro", 3))


palette <- c("#000000", "#403f45", "#EfEBED", "#334764", "#476397", "#9CB5DE",
             "#652B43", "#9a3a48", "#fac73d")

scales::show_col(palette, borders = NA)










```
