
```r
## packages
library(tidyverse)
library(colorspace)
library(ragg)
library(cowplot)
library(ggtext)
library(pdftools)

theme_set(theme_minimal(base_size = 15, base_family = "Neutraface Slab Display TT Bold"))

theme_update(
  panel.grid.major = element_line(color = "grey92", size = .4),
  panel.grid.minor = element_blank(),
  axis.title.x = element_text(color = "grey30", margin = margin(t = 7)),
  axis.title.y = element_text(color = "grey30", margin = margin(r = 7)),
  axis.text = element_text(color = "grey50"),
  axis.ticks =  element_line(color = "grey92", size = .4),
  axis.ticks.length = unit(.6, "lines"),
  legend.position = "top",
  plot.title = element_text(hjust = 0, color = "black", 
                            family = "Neutraface 2 Display Titling",
                            size = 21, margin = margin(t = 10, b = 35)),
  plot.subtitle = element_text(hjust = 0, face = "bold", color = "grey30",
                               family = "Neutraface Text Book Italic", 
                               size = 14, margin = margin(0, 0, 25, 0)),
  plot.title.position = "plot",
  plot.caption = element_text(color = "grey50", size = 10, hjust = 1,
                              family = "Neutraface Display Medium", 
                              lineheight = 1.05, margin = margin(30, 0, 0, 0)),
  plot.caption.position = "plot", 
  plot.margin = margin(rep(20, 4))
)

pal <- c("#FF8C00", "#A034F0", "#159090")



df_penguins <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-07-28/penguins.csv') %>% 
  mutate(species = if_else(species == "Adelie", "Adélie", species))

#Data prep ########

df_peng_summary <-
  tribble(
    ~species, ~x, ~y,
    "Adélie", 34.7, 20.7,
    "Chinstrap", 55.7, 19,
    "Gentoo", 50.7, 13.6
  ) %>% 
  full_join(
    df_penguins %>% 
      group_by(species) %>% 
      summarize(across(
        contains("_"), 
        list(median = ~median(.x, na.rm = T), 
             sd = ~sd(.x, na.rm = T))
      ))
  ) %>% 
  mutate(label = glue::glue("Median length: {format(round(bill_length_mm_median, 1), nsmall = 1)} mm\nMedian depth: {format(round(bill_depth_mm_median, 1), nsmall = 1)} mm\nMedian body mass: {format(body_mass_g_median / 1000, nsmall = 1)} kg"))

url <- "https://raw.githubusercontent.com/allisonhorst/palmerpenguins/master/man/figures/culmen_depth.png"
img <- png::readPNG(RCurl::getURLContent(url))
i1 <- grid::rasterGrob(img, interpolate = T)



# Scatter ##########
scat <- 
  ggplot(df_penguins, aes(bill_length_mm, bill_depth_mm)) +
  geom_errorbar(
    data = df_peng_summary,
    aes(
      x = bill_length_mm_median,
      ymin = bill_depth_mm_median - bill_depth_mm_sd,
      ymax = bill_depth_mm_median + bill_depth_mm_sd,
      color = species, 
      color = after_scale(darken(color, .2, space = "combined"))
    ),
    inherit.aes = F,
    width = .8,
    size = .8
  ) +
  geom_errorbar(
    data = df_peng_summary,
    aes(
      y = bill_depth_mm_median,
      xmin = bill_length_mm_median - bill_length_mm_sd,
      xmax = bill_length_mm_median + bill_length_mm_sd,
      color = species, 
      color = after_scale(darken(color, .2, space = "combined"))
    ),
    inherit.aes = F,
    width = .5,
    size = .8
  ) +
  geom_point(
    aes(
      fill = species, 
      size = body_mass_g
    ), 
    shape = 21,
    color = "transparent",
    alpha = .3
  ) +
  geom_point(
    aes(
      size = body_mass_g
    ), 
    shape = 21,
    color = "white",
    fill = "transparent"
  ) +
  geom_text(
    data = df_peng_summary,
    aes(
      x = x, y = y, 
      label = species, 
      color = species
    ),
    family = "Neutraface Slab Display TT Titl",
    size = 5.6
  ) +
  geom_text(
    data = df_peng_summary,
    aes(
      x = x, y = y - .6, 
      label = label, 
      color = species,
      color = after_scale(lighten(color, .3))
    ),
    family = "Neutraface Slab Display TT Bold",
    size = 3.5,
    lineheight = .8
  ) +
  annotate(
    "text",
    x = 37.5, y = 14.85,
    label = "Bubble size represents\nindividual body mass",
    family = "Neutraface Text Book Italic",
    color = "grey50",
    size = 3,
    lineheight = .9
  ) +
  annotate(
    "text",
    x = 40.1, y = 21.95,
    label = "Pygoscelis adéliae (Adélie penguin)  •  P. antarctica (Chinstrap penguin)  •  P. papua (Gentoo penguin)\n\n\n\n\n\n\n\n",
    family = "Neutraface Text Book Italic",
    color = "black",
    size = 3.9
  ) +
  annotation_custom(i1, ymin = 19.95, ymax = 26.95, xmin = 52.4, xmax = 60.2) +
  coord_cartesian(clip = "off") +
  scale_x_continuous(
    limits = c(30, 60),
    breaks = seq(30, 60, by = 5),
    expand = c(0, 0)
  ) +
  scale_y_continuous(
    limits = c(12, 22),
    breaks = seq(12, 22, by = 2),
    expand = c(0, 0)
  ) +
  scale_color_manual(
    values = pal,
    guide = F
  ) +
  scale_fill_manual(
    values = pal,
    guide = F
  ) +
  scale_size(
    name = "",
    breaks = 3:6 * 1000,
    labels = c("3 kg", "4 kg", "5 kg", "6 kg")
  ) +
  guides(size = guide_legend(label.position = "bottom", 
                             override.aes = list(color = pal[2], stroke = .8, fill = NA))) +
  theme(legend.position = c(.24, .21), legend.direction = "horizontal", legend.key.width = unit(.01, "lines"), legend.text = element_text(size = 8, family = "Neutraface Text Book Italic", color = "grey50")) +
  labs(
    x = "Bill length (mm)",
    y = "Bill depth (mm)",
    title = "Bill dimensions of brush-tailed penguins",
    subtitle = "A. Scatterplot of bill length versus bill depth (error bars show median +/- sd)"
  )


#Rain cloud prep #########
df_rect <-
  tibble(
    xmin = c(-Inf, 2.46, 3.27),
    xmax = c(Inf, Inf, Inf),
    ymin = c(3, 2, 1),
    ymax = c(Inf, Inf, Inf)
  )

df_peng_iqr <- 
  df_penguins %>% 
  mutate(bill_ratio = bill_length_mm / bill_depth_mm) %>% 
  filter(!is.na(bill_ratio)) %>% 
  group_by(species) %>% 
  mutate(
    median = median(bill_ratio),
    q25 = quantile(bill_ratio, probs = .25),
    q75 = quantile(bill_ratio, probs = .75),
    n = n()
  ) %>% 
  ungroup() %>% 
  mutate(species_num = as.numeric(fct_rev(species))) 

url <- "https://raw.githubusercontent.com/allisonhorst/palmerpenguins/master/man/figures/lter_penguins.png"
img <- png::readPNG(RCurl::getURLContent(url))
i2 <- grid::rasterGrob(img, interpolate = T)


# Rain cloud ##########

rain <- NULL

rain <- 
  ggplot(df_peng_iqr, aes(bill_ratio, species_num - .2)) +
  geom_rect(
    data = df_rect,
    aes(
      xmin = xmin, xmax = xmax,
      ymin = ymin, ymax = ymax
    ),
    inherit.aes = F,
    fill = "white"
  )

rain


rain <- rain +
  geom_linerange(
    data = df_peng_iqr %>% 
      group_by(species, species_num) %>% 
      summarize(m = unique(median)),
    aes(
      xmin = -Inf, 
      xmax = m, 
      y = species_num,
      color = species
    ),
    inherit.aes = F,
    linetype = "dotted",
    size = .7
  ) 

rain

rain <- rain +
  geom_boxplot(
    aes(
      color = species,
      color = after_scale(darken(color, .1, space = "HLS"))
    ),
    width = 0,
    size = .9
  )

rain


rain <- rain +
  geom_rect(
    aes(
      xmin = q25,
      xmax = median,
      ymin = species_num - .05,
      ymax = species_num - .35
    ),
    fill = "grey89"
  )

rain

rain <- rain +
  geom_rect(
    aes(
      xmin = q75,
      xmax = median,
      ymin = species_num - .05,
      ymax = species_num - .35
    ),
    fill = "grey79"
  )

rain

rain <- rain +
  geom_segment(
    aes(
      x = q25, 
      xend = q25,
      y = species_num - .05,
      yend = species_num - .35,
      color = species,
      color = after_scale(darken(color, .05, space = "HLS"))
    ),
    size = .25
  )

rain


rain <- rain +
  geom_segment(
    aes(
      x = q75, 
      xend = q75,
      y = species_num - .05,
      yend = species_num - .35,
      color = species,
      color = after_scale(darken(color, .05, space = "HLS"))
    ),
    size = .25
  )

rain

rain <- rain +
  geom_point(
    aes(
      color = species
    ), 
    shape = "|",
    size = 5,
    alpha = .33
  )

rain

rain <- rain +
  ggdist::stat_halfeye(
    aes(
      y = species_num,
      color = species,
      fill = after_scale(lighten(color, .5))
    ),
    shape = 18,
    point_size = 3,
    interval_size = 1.8,
    adjust = .5,
    .width = c(0, 1)
  )

rain

rain <- rain +
  geom_text(
    data = df_peng_iqr %>% 
      group_by(species, species_num) %>% 
      summarize(m = unique(median)),
    aes(
      x = m, 
      y = species_num + .12,
      label = format(round(m, 2), nsmall = 2)
    ),
    inherit.aes = F,
    color = "white",
    family = "Neutraface Slab Display TT Titl",
    size = 3.5
  )

rain

rain <- rain +
  geom_text(
    data = df_peng_iqr %>% 
      group_by(species, species_num) %>% 
      summarize(n = unique(n), max = max(bill_ratio, na.rm = T)),
    aes(
      x = max + .01, 
      y = species_num + .02,
      label = glue::glue("n = {n}"),
      color = species
    ),
    inherit.aes = F,
    family = "Neutraface Slab Display TT Bold",
    size = 3.5,
    hjust = 0
  )

rain

rain <- rain +
  annotation_custom(i2, ymin = 2.5, ymax = 3.6, xmin = 3, xmax = 3.7) +
  coord_cartesian(clip = "off")

rain 


rain <- rain +
  scale_x_continuous(
    limits = c(1.57, 3.7),
    breaks = seq(1.6, 3.6, by = .2),
    expand = c(.001, .001)
  ) +
  scale_y_continuous(
    limits = c(.55, NA),
    breaks = 1:3,
    labels = c("Gentoo", "Chinstrap", "Adélie"),
    expand = c(0, 0)
  )

rain

rain <- rain +
  scale_color_manual(
    values = pal,
    guide = F
  ) +
  scale_fill_manual(
    values = pal,
    guide = F
  ) +
  labs(
    x = "Bill ratio",
    y = NULL,
    subtitle = "B. Distribution of the bill ratio, estimated as bill length divided by bill depth",
    caption = 'Note: In the original data, bill dimensions are recorded as "culmen length" and "culmen depth". The culmen is the dorsal (upper) ridge of a bird’s bill.\nVisualization: Cédric Scherer  •  Data: Gorman, Williams & Fraser (2014) DOI: 10.1371/journal.pone.0090081  •  Illustrations: Allison Horst'
  ) 

rain

rain <- rain +
  theme(
    panel.grid.major.y = element_blank(),
    axis.text.y = element_text(family = "Neutraface Slab Display TT Titl", 
                               color = rev(pal), size = 14, lineheight = .9),
    axis.ticks.length = unit(0, "lines"),
    plot.subtitle = element_text(margin = margin(0, 0, -10, 0))
  )

rain


path <- here::here("2020_31_PalmerPenguins")

plot_grid(scat, rain, ncol = 1, rel_heights = c(1, .75)) +
  ggsave(glue::glue("{path}.pdf"), width = 9, height = 14, device = cairo_pdf)

library(cowplot)  # for plot_grid()

# Create the combined plot using plot_grid
combined_plot <- plot_grid(scat, rain, ncol = 1, rel_heights = c(1, 0.75))

# Save the combined plot
ggsave(glue::glue("{path}.pdf"), plot = combined_plot, width = 9, height = 14, device = cairo_pdf)


```
