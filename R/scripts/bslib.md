bs_theme_preview:

```r
library(bslib)

material <- bs_theme(
  bg = "white", 
  fg = "green", 
  primary = "#EA80FC", 
  secondary = "#00DAC6",
  success = "#4F9B29",
  info = "#28B3ED",
  warning = "#FD7424",
  danger = "#F7367E",
  base_font = font_google("Open Sans"),
  heading_font = font_google("Proza Libre"),
  code_font = font_google("Fira Code")
)

bs_theme_preview(material, with_themer = FALSE)

```
