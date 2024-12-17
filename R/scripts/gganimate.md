
![dinosaurus animated](Zzzz/dinosaurus_animated.gif)
## Some example how to use gganimate

```r
#install.packages("datasauRus")
library(datasauRus)
library(gganimate)
library(ggplot2)



ggplot(mtcars, aes(factor(cyl), mpg)) +
  geom_boxplot() +
  # Here comes the gganimate code
  transition_states(gear, transition_length = 2, state_length = 1) +
  enter_fade() +
  exit_shrink() +
  ease_aes('sine-in-out')


```

With Dinsaurus

```r
# Example code with gganimate
p <- ggplot(datasaurus_dozen, aes(x = x, y = y)) +
  geom_point() +
  theme_minimal() +
  transition_states(dataset, 3, 1)

# Save the animation with high resolution
anim_save(
  "high_resolution_animation.gif",
  p,
  width = 800,
  height = 600,
  dpi = 300
)

# WebP renderer
anim_save(
  "high_resolution_animation.webp",
  p,
  width = 1600,
  height = 1200,
  dpi = 300,
  renderer = av_renderer()
)
```
