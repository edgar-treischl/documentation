This script creates: 

![[plot_6b86b273_2_20241207204036.jpg]]


The code:

```r
#| label: 6b86b273
#Minimal code example #####
library(ggplot2)
library(ggalluvial)


library(showtext)
#Add a font
font_add_google("Lato")


showtext_auto()


df <- tibble::tribble(
                      ~From,                 ~To, ~Freq,  ~Schulwechsel,
             "Mittelschule",     "Förderzentrum",   863,  "Abstieg",
             "Mittelschule",        "Realschule", 4899, "Aufstieg",
             "Mittelschule",         "Gymnasium",   312, "Aufstieg",
           "Förderzentrum",      "Mittelschule",   757, "Aufstieg",
           "Förderzentrum",        "Realschule",    19, "Aufstieg",
           "Förderzentrum",         "Gymnasium",     5, "Aufstieg",
               "Realschule",     "Förderzentrum",    51,  "Abstieg",
               "Realschule",      "Mittelschule", 5669,  "Abstieg",
               "Realschule",         "Gymnasium",   311, "Aufstieg",
                "Gymnasium",     "Förderzentrum",     6,  "Abstieg",
                "Gymnasium",      "Mittelschule",   766,  "Abstieg",
                "Gymnasium",        "Realschule", 7699,  "Abstieg",
                "Gymnasium",    "FOS", 1227,  "Abstieg"
        )



df$To <- factor(df$To,
                 levels = c("Gymnasium", "FOS", "Realschule", "Mittelschule", "Förderzentrum")
)


df$From <- factor(df$From,
                  levels = c("Gymnasium", "FOS", "Realschule", "Mittelschule", "Förderzentrum")
)




ploti <- ggplot(data = df,
       aes(axis1 = From, axis2 = To, y = Freq)) +
  geom_alluvium(aes(fill = Schulwechsel), alpha = 0.9) +
  geom_stratum()+
  geom_text(stat = "stratum", aes(label = after_stat(stratum)), 
            size = rel(4))+
  theme_minimal(base_size = 12, base_family = "Lato")+
  labs(title = "Schulartwechsel aus dem Schuljahr 2018/19",
       subtitle = "Schulartwechsel während der Sekundarstufe nach Schularten in Bayern",
       caption = "Anmerkung: Die Schulformen Wirtschaftsschule und Realschule wurden zusammengefasst. 
       Daten: Amtliche Schuldaten des Bayerischen Landesamtes für Statistik",
       y = "Anzahl")+
  scale_x_discrete(limits = c("Von", "Nach")) +
  scale_fill_manual(values = c("#9b2226", "#003566"))+
  theme(legend.position="bottom")+
  theme(plot.caption = element_text(color = "darkgray"))


```



