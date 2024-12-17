## Gunzenhausen

```r
# Load necessary libraries
library(tidyverse)
library(osmdata)
library(ggplot2)
library(showtext)


# Add custom font for the map
font_add_google(name = "Fraunces", family = "Fraunces")
showtext_auto()


# Fetching street data for Gunzenhausen, Bavaria
small_streets <- getbb("Gunzenhausen, Bavaria, Germany") |>
  opq() |>
  add_osm_feature(key = "highway",
                  value = c("residential", "living_street", "unclassified", "service", "footway")) |>
  osmdata_sf()

#Fetching medium and big streets
med_streets <- getbb("Gunzenhausen, Bavaria, Germany") |>
  opq() |>
  add_osm_feature(key = "highway",
                  value = c("secondary", "tertiary", "secondary_link", "tertiary_link")) |>
  osmdata_sf()

big_streets <- getbb("Gunzenhausen, Bavaria, Germany") |>
  opq() |>
  add_osm_feature(key = "highway",
                  value = c("motorway", "primary", "motorway_link", "primary_link")) |>
  osmdata_sf()

# Fetching water data
water <- getbb("Gunzenhausen, Bavaria, Germany") |>
  opq() |>
  add_osm_feature(key = "water", value = c("lake", "reservoir", "river", "wetland", "pond", "bay")) |>
  osmdata_sf()

# Fetching waterway data
waterways <- getbb("Gunzenhausen, Bavaria, Germany") |>
  opq() |>
  add_osm_feature(key = "waterway", value = c("river", "stream", "canal", "ditch", "drain", "weir", "lock")) |>
  osmdata_sf()


# Example coordinates for a specific location in Gunzenhausen
lat <- 49.121224641898735 # Latitude for 4QCJ+9F Gunzenhausen
lon <- 10.781111423943116  # Longitude for 4QCJ+9F Gunzenhausen


# Plotting the map
ggplot() +
  theme_minimal(base_family = "Fraunces") +
  geom_sf(data = small_streets$osm_lines,
          inherit.aes = FALSE,
          color = "#495057",
          size = .3,
          alpha = .7) +
  geom_sf(data = med_streets$osm_lines,
          inherit.aes = FALSE,
          color = "#343a40",
          size = .3,
          alpha = .7) +
  geom_sf(data = big_streets$osm_lines,
          inherit.aes = FALSE,
          color = "#212529",
          size = .3,
          alpha = .5) +
  geom_sf(data = water$osm_polygons,
          color = "#0062A1",
          fill = "#0062A1",
          alpha = .5) +
  geom_sf(data = waterways$osm_lines,
          color = "#0062A1",
          size = 1.5,
          alpha = .7) +
  coord_sf(xlim = c(10.69, 10.81),
           ylim = c(49.09, 49.16),
           expand = TRUE) +
  geom_point(aes(x = lon, y = lat), color = "#e63946",
             size = 2.5,
             stroke = 1,
             shape = 8) +
  labs(
    title = "91710 Gunzenhausen",
    caption = "<span style='color:#e63946;'>*</span>here::here()",
    x = "",
    y = ""
  )+
  theme(text = element_text(color = "black"),
        plot.margin = margin(10, 30, 10, 10),
        plot.title = element_text(size = 44,
                                  family = "Fraunces", hjust = .5, color = "#495057"),
        plot.caption = ggtext::element_markdown(size = 16, hjust = 1, lineheight = 1.2)
        )




```


## New York

```r
library(tidyverse)
library(osmdata)
library(showtext) # for custom fonts
library(ggmap)
library(sf) # For handling geometries and buffering
library(cowplot)

# Fetching street data for different types of streets in New York City
med_streets <- getbb("New York City, USA") %>%
  opq() %>%
  add_osm_feature(key = "highway", 
                  value = c("secondary", "tertiary", "secondary_link", "tertiary_link")) %>%
  osmdata_sf()

small_streets <- getbb("New York City, USA") %>%
  opq() %>%
  add_osm_feature(key = "highway", 
                  value = c("residential", "living_street", "unclassified", "service", "footway")) %>%
  osmdata_sf()

big_streets <- getbb("New York City, USA") %>%
  opq() %>%
  add_osm_feature(key = "highway", 
                  value = c("motorway", "primary", "motorway_link", "primary_link")) %>%
  osmdata_sf()

# Fetching water bodies (e.g., lakes, rivers, reservoirs, wetland, bay) as polygons
water <- getbb("New York City, USA") %>%
  opq() %>%
  add_osm_feature(key = "water", value = c("river", "reservoir", "lake", "wetland", "bay")) %>%
  osmdata_sf()

# Fetching waterways (e.g., smaller rivers, streams, canals) as lines
waterways <- getbb("New York City, USA") %>%
  opq() %>%
  add_osm_feature(key = "waterway", value = c("river", "stream", "canal", "ditch", "drain", "weir", "lock")) %>%
  osmdata_sf()

# Fetching sea/coastline areas (natural = coastline)
sea <- getbb("New York City, USA") %>%
  opq() %>%
  add_osm_feature(key = "natural", value = "coastline") %>%
  osmdata_sf()

# Buffering the waterways (rivers, streams) to create polygons
river_buffer <- st_buffer(waterways$osm_lines, dist = 0.05)  # Buffer size increased
river_buffer <- st_make_valid(river_buffer)  # Ensure valid geometry

# Add custom font for the map (optional)
font_add_google(name = "Arvo", family = "Arvo") # Add custom fonts
showtext_auto()

# Plot
ggplot() +
  theme_map() +
  # geom_sf(data = small_streets$osm_lines,
  #         inherit.aes = FALSE,
  #         color = "darkgray",
  #         size = .3,
  #         alpha = .7) +
  geom_sf(data = med_streets$osm_lines,
          inherit.aes = FALSE,
          color = "black",
          size = .3,
          alpha = .7) +
  geom_sf(data = big_streets$osm_lines,
          inherit.aes = FALSE,
          color = "black",
          size = .3,
          alpha = .5) +
  # Water bodies as polygons (lakes, reservoirs, rivers, etc.)
  geom_sf(data = water$osm_polygons,
          color = "#003566",   # Dark blue for water
          fill = "#003566",    # Dark blue for water
          alpha = .5) +        # Slight transparency for water bodies
  # Waterways as buffered polygons (rivers, streams, canals)
  geom_sf(data = river_buffer,
          color = "#003566",   # Dark blue for rivers
          fill = "#003566",    # Dark blue for rivers
          alpha = .5) +        # Slight transparency for rivers
  geom_sf(data = sea$osm_polygons,
          color = "#003566",   # Dark blue for the sea
          fill = "#003566",    # Dark blue fill for the sea
          alpha = .5) +        # Slight transparency for the sea
  # Coordinates to zoom into New York City
  coord_sf(xlim = c(-74.05, -73.85),  # Longitude bounds for New York City
           ylim = c(40.68, 40.85),      # Latitude bounds for New York City
           expand = FALSE) +
  # Map title and subtitle
  labs(title = "New York City", 
       subtitle = "40° 42‘ 46.56\" N, 74° 0‘ 23.64\" W") +
  # Customize title and subtitle appearance
  theme(plot.title = element_text(size = 36,
                                  family = "Arvo",
                                  face = "bold", hjust = .5),
        plot.subtitle = element_text(family = "Arvo",
                                     size = 14, hjust = .5,
                                     margin = margin(2, 0, 5, 0)))



#Further ado#################################################################

library(tidyverse)
library(osmdata)
library(sf)
library(ggplot2)

# Fetch subway lines
subway_routes <- getbb("New York City, USA") %>%
  opq() %>%
  add_osm_feature(key = "route", value = "subway") %>%
  osmdata_sf()

# Fetch bus routes
bus_routes <- getbb("New York City, USA") %>%
  opq() %>%
  add_osm_feature(key = "route", value = "bus") %>%
  osmdata_sf()

# Fetch tram routes
tram_routes <- getbb("New York City, USA") %>%
  opq() %>%
  add_osm_feature(key = "route", value = "tram") %>%
  osmdata_sf()

# Fetch subway stations (stations where people get on/off)
subway_stations <- getbb("New York City, USA") %>%
  opq() %>%
  add_osm_feature(key = "railway", value = "station") %>%
  osmdata_sf()

# Plotting the map with Public Transport Routes
ggplot() +
  theme_minimal() +
  
  # Plot Subway Routes - as thick purple lines
  geom_sf(data = subway_routes$osm_lines, 
          color = "purple", size = 1, alpha = 0.7) +
  
  # Plot Bus Routes - as blue dashed lines
  geom_sf(data = bus_routes$osm_lines, 
          color = "blue", linetype = "dashed", size = 0.5, alpha = 0.7) +
  
  # Plot Tram Routes - as red dashed lines
  # geom_sf(data = tram_routes$osm_lines, 
  #         color = "red", linetype = "dashed", size = 0.5, alpha = 0.7) +
  # 
  # # Plot Subway Stations - as yellow points
  # geom_sf(data = subway_stations$osm_points, 
  #         aes(color = "Subway Station"), size = 2, shape = 16) +
  # 
  # scale_color_manual(values = c("Subway Station" = "yellow")) +
  
  # Coordinates for New York City (zoom into Manhattan area)
  coord_sf(xlim = c(-74.03, -73.85), ylim = c(40.68, 40.85), expand = FALSE) +
  
  labs(title = "Public Transport Routes and Subway Stations in New York City",
       subtitle = "Subway (Purple), Bus (Blue), Tram (Red) and Subway Stations (Yellow)") +
  theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
        plot.subtitle = element_text(size = 10, hjust = 0.5))


```


## Cologne

```r
library(tidyverse)
library(osmdata)
library(showtext) # for custom fonts
library(ggmap)
library(rvest)
library(cowplot)

#available_features()
#available_tags("landuse")

med_streets <- getbb("Cologne Germany")%>%
  opq()%>%
  add_osm_feature(key = "highway",
                  value = c("secondary", "tertiary", "secondary_link", "tertiary_link")) %>%
  osmdata_sf()


small_streets <- getbb("Cologne Germany")%>%
  opq()%>%
  add_osm_feature(key = "highway",
                  value = c("residential", "living_street",
                            "unclassified",
                            "service", "footway"
                  )) %>%
  osmdata_sf()


big_streets <- getbb("Cologne Germany")%>%
  opq()%>%
  add_osm_feature(key = "highway",
                  value = c("motorway", "primary", "motorway_link", "primary_link")) %>%
  osmdata_sf()


waterway_ams <- available_tags("waterway")

waterways <- getbb("Cologne Germany")%>%
  opq()%>%
  add_osm_feature(key = "waterway", value = waterway_ams) %>%
  osmdata_sf()

water_ams <- available_tags("water")

water <- getbb("Cologne Germany")%>%
  opq()%>%
  add_osm_feature(key = "water", value = water_ams) %>%
  osmdata_sf()

font_add_google(name = "Arvo", family = "Arvo") # add custom fonts
showtext_auto()



#Plot
ggplot() +
  theme_map()+
  geom_sf(data = small_streets$osm_lines,
          inherit.aes = FALSE,
          color = "darkgray",
          size = .3,
          alpha = .7) +
  geom_sf(data = med_streets$osm_lines,
          inherit.aes = FALSE,
          color = "black",
          size = .3,
          alpha = .7) +
  geom_sf(data = big_streets$osm_lines,
          inherit.aes = FALSE,
          color = "black",
          size = .3,
          alpha = .5) +
  geom_sf(data = water$osm_polygons,
          color = "#003566",
          fill = "#003566", 
          alpha = .5)+
  # coord_sf(xlim = c(6.9,  7.05),
  #          ylim = c(50.91, 50.97),
  #          expand = FALSE)
  coord_sf(xlim = c(6.85,  7.10),
           ylim = c(50.85, 51),
           expand = FALSE)
  #labs(title = "Köln", subtitle = "50° 56‘ 28.68 N 6° 57‘ 29.88 E")+
  # theme(plot.title = element_text(size = 36,
  #                                 family = "Arvo",
  #                                 face="bold", hjust=.5),
  #       plot.subtitle = element_text(family = "Arvo",
  #                                    size = 12, hjust=.5,
  #                                    margin=margin(2, 0, 5, 0)))

```

## Gunzenhausen

