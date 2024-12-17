Create a shiny app with the city view and osmdata

```r
# 1. Packages
require(shiny)
require(shinythemes)
require(ggplot2)
require(osmdata)
require(sf)
require(cowplot)
require(sysfonts)
require(showtext)
require(colourpicker)
require(leaflet)
require(leaflet.extras)
require(svglite)
require(ggspatial)

# 2. Preparatory work
sysfonts::font_add_google("Cinzel")
showtext_auto()

# 3. Drawing function
draw_plot <- function(input) {
    shiny::withProgress(message = 'Creating preview', value = 0, min = 0, max = 1, expr = {
        box <- as.numeric(c(input$osm_bounds$east, input$osm_bounds$south, input$osm_bounds$west, input$osm_bounds$north))
        shiny::incProgress(1/13, detail = "[1/13] Downloading water bodies")
        water <- osmdata::osmdata_sf(q = osmdata::opq(bbox = box, timeout = 1000) %>% 
                                         osmdata::add_osm_feature(key = "natural", value = c("water", "strait", "coastline", "beach", "peninsula")))
        water_multi <- water$osm_multipolygons$geometry
        water_poly <- water$osm_polygons$geometry
        shiny::incProgress(1/13, detail = "[2/13] Downloading waterways")
        waterway <- osmdata::osmdata_sf(q = osmdata::opq(bbox = box, timeout = 1000) %>% 
                                            osmdata::add_osm_feature(key = "waterway"))$osm_polygons$geometry
        shiny::incProgress(1/13, detail = "[3/13] Downloading coastlines")
        coastlines <- osmdata::osmdata_sf(q = osmdata::opq(bbox = box, timeout = 1000) %>% 
                                              osmdata::add_osm_feature(key = "natural", value = c("coastline", "beach", "peninsula")))$osm_lines$geometry
        shiny::incProgress(1/13, detail = "[4/13] Downloading train tracks")
        rails <- osmdata::osmdata_sf(q = osmdata::opq(bbox = box, timeout = 1000) %>% 
                                         osmdata::add_osm_feature(key = 'railway', value = "rail"))$osm_lines$geometry
        shiny::incProgress(1/13, detail = "[5/13] Downloading runways")
        runway <- osmdata::osmdata_sf(q = osmdata::opq(bbox = box, timeout = 1000) %>% 
                                          osmdata::add_osm_feature(key = 'aeroway', value = "runway"))$osm_lines$geometry
        shiny::incProgress(1/13, detail = "[6/13] Downloading taxiways")
        taxiway <- osmdata::osmdata_sf(q = osmdata::opq(bbox = box, timeout = 1000) %>% 
                                           osmdata::add_osm_feature(key = 'aeroway', value = "taxiway"))$osm_lines$geometry
        shiny::incProgress(1/13, detail = "[7/13] Downloading large streets")
        lstreets <- osmdata::osmdata_sf(q = osmdata::opq(bbox = box, timeout = 1000) %>% 
                                            osmdata::add_osm_feature(key = 'highway', value = c("motorway", "primary", "motorway_link", "primary_link")))$osm_lines$geometry
        shiny::incProgress(1/13, detail = "[8/13] Downloading medium streets")
        mstreets <- osmdata::osmdata_sf(q = osmdata::opq(bbox = box, timeout = 1000) %>% 
                                            osmdata::add_osm_feature(key = 'highway', value = c("secondary", "tertiary", "secondary_link", "tertiary_link")))$osm_lines$geometry
        shiny::incProgress(1/13, detail = "[9/13] Downloading small streets")
        sstreets <- osmdata::osmdata_sf(q = osmdata::opq(bbox = box, timeout = 1000) %>% 
                                            osmdata::add_osm_feature(key = 'highway', value = c("residential", "living_street", "unclassified", "service", "footway", "cycleway")))$osm_lines$geometry
        shiny::incProgress(1/13, detail = "[10/13] Downloading trunk streets")
        tstreets <- osmdata::osmdata_sf(q = osmdata::opq(bbox = box, timeout = 1000) %>% 
                                            osmdata::add_osm_feature(key = 'highway', value = c("trunk", "trunk_link", "trunk_loop")))$osm_lines$geometry
        shiny::incProgress(1/13, detail = "[11/13] Downloading buildings")
        buildings <- osmdata::osmdata_sf(q = osmdata::opq(bbox = box, timeout = 1000) %>% 
                                             osmdata::add_osm_feature(key = 'building'))$osm_polygons$geometry
        incProgress(1/13, detail = "[12/13] Putting it all together")
        int_p <- ggplot2::ggplot() +
            ggplot2::geom_sf(data = water_poly, fill = input$waterColor, color = input$lineColor, size = 0.1, inherit.aes = FALSE, alpha = 0.3) +
            ggplot2::geom_sf(data = water_multi, fill = input$waterColor, color = input$lineColor, size = 0.1, inherit.aes = FALSE, alpha = 0.3) +
            ggplot2::geom_sf(data = waterway, fill = input$waterColor, color = input$lineColor, size = 0.1, inherit.aes = FALSE, alpha = 0.3) +
            ggplot2::geom_sf(data = coastlines, color = input$lineColor, size = 0.125, inherit.aes = FALSE, alpha = 0.5) +
            ggplot2::geom_sf(data = rails, color = input$lineColor, size = 0.2, inherit.aes = FALSE, alpha = 0.9) +
            ggplot2::geom_sf(data = runway, color = input$lineColor, size = 3, inherit.aes = FALSE, alpha = 0.2) +
            ggplot2::geom_sf(data = taxiway, color = input$lineColor, size = 0.7, inherit.aes = FALSE, alpha = 0.1) +
            ggplot2::geom_sf(data = mstreets, color = input$lineColor, size = 0.15, inherit.aes = FALSE, alpha = 0.6) +
            ggplot2::geom_sf(data = sstreets, color = input$lineColor, size = 0.125, inherit.aes = FALSE, alpha = 0.5) +
            ggplot2::geom_sf(data = lstreets, color = input$lineColor, size = 0.175, inherit.aes = FALSE, alpha = 0.7) + 
            ggplot2::geom_sf(data = tstreets, color = input$lineColor, size = 0.175, inherit.aes = FALSE, alpha = 0.7) + 
            ggplot2::geom_sf(data = buildings, fill = input$mapColor, color = input$lineColor, size = 0.1, inherit.aes = FALSE) +
            ggplot2::coord_sf(xlim = c(box[1], box[3]), ylim = c(box[2], box[4]), expand = TRUE) +
            ggplot2::theme_void() +
            ggplot2::theme(plot.margin = ggplot2::margin(5, 1, 1, 1, "cm"))
        p <- cowplot::ggdraw(int_p) +
            cowplot::draw_text(text = input$plotTitle, x = 0.5, y = 0.93, size = 100, color = input$lineColor, family = "Cinzel", fontface = "bold") +
            #cowplot::draw_text(text = input$country, x = 0.5, y = 0.97, size = 35, color = input$lineColor, family = "Cinzel") +
            ggspatial::annotation_north_arrow(location = "bl", height = ggplot2::unit(3, "cm"), width = ggplot2::unit(3, "cm"), 
                                              pad_x = ggplot2::unit(1, "cm"), pad_y = ggplot2::unit(1, "cm"),
                                              style = ggspatial::north_arrow_nautical(line_col = input$lineColor, text_size = 20, text_face = "bold", text_family = "Cinzel", text_col = input$lineColor, fill = c(input$lineColor, input$mapColor))) +
            ggplot2::theme(plot.background = ggplot2::element_rect(fill = input$mapColor, color = input$mapColor),
                           panel.background = ggplot2::element_rect(fill = input$mapColor, color = input$mapColor))
        lat <- min(box[1], box[3]) + abs(box[3] - box[1]) / 2
        if (lat < 0) {
            lat <- paste0(format(abs(lat), digits = 6), "\u00B0 W")
        } else {
            lat <- paste0(format(lat, digits = 6), "\u00B0 E")
        }
        long <- min(box[2], box[4]) + abs(box[4] - box[2]) / 2
        if (long < 0) {
            long <- paste0(format(abs(long), digits = 6), "\u00B0 S")
        } else {
            long <- paste0(format(long, digits = 6), "\u00B0 N")
        }
        p <- p + cowplot::draw_text(text = paste0(long, " / ", lat), x = 0.97, y = 0.03, size = 30, color = input$lineColor, family = "Cinzel", hjust = 1)
        incProgress(1/13, detail = "[13/13] Rendering plot")
    })
    return(p)
}

# 3. UI
ui <- fluidPage(
    theme = shinytheme("flatly"),
    tags$head(HTML("<title>R City Views</title>")),
    shiny::fluidRow(align = "center", titlePanel(HTML("<h1><b>R City Views</b></h1>"))),
    hr(),
    fluidRow(
        column(4,
               HTML("<p>Drag the map to the area that you want to render and click the <b>Preview</b> button to preview the image in the panel below. Once the image is rendered you can click the <b>Download</b> button to export it.</p>
                    <p><b>Note:</b> Previewing a (too) large or populated area may disconnect you from the server due to a data limit of 1 GB for free Shiny subscriptions. In this case, download <a href='https://raw.githubusercontent.com/koenderks/rcityviews/master/app.R' target='_blank'>app.R</a> from GitHub and run on you own computer.</p>"),
               shiny::fluidRow(align = "center", leafletOutput(outputId = 'osm', width = "500px", height = "410px")),
        ),
        column(3, offset = 1,
               shiny::fluidRow(align = "center", shiny::textInput(inputId = "plotTitle", label = "City name", value = "Vatican City")),
               shiny::fluidRow(column(width = 3, offset = 2, shiny::actionButton(inputId = "run", label = "Preview", icon = icon("search-location"))),
                               column(width = 3, offset = 1, shiny::downloadButton(outputId = "downloadPlot", label = "Download"))),
               HTML("<br>"),
               shiny::fluidRow(align = "center",
                               tags$a(href="https://koenderks.shinyapps.io/rcityviews/", "Tweet", class="twitter-share-button"),
                               includeScript("http://platform.twitter.com/widgets.js")
               )
        ),
        column(3, offset = 1,
               colourpicker::colourInput(inputId = "lineColor", label = "Streets / Rails", value = "#32130f"),
               colourpicker::colourInput(inputId = "mapColor", label = "Background", value = "#fdf9f5"),
               colourpicker::colourInput(inputId = "waterColor", label = "Water", value = "#fdf9f5")
        )),
    hr(),
    mainPanel(
        column(12, align="center",
               plotOutput(outputId = "plotObject", width = "1400px", height = "1600px")
        )
    )
)

# 4. Server
server <- function(input, output) {
    output$osm = renderLeaflet({
        leaflet() %>% addTiles() %>% setView(lng = 12.45685, lat = 41.90015, zoom = 14) %>% leaflet.extras::addSearchOSM()
    })
    output$plotObject <- renderPlot(NULL)
    observeEvent(input$run, {
        p <- draw_plot(input)
        output$plotObject <- shiny::renderPlot(p)
        output$downloadPlot <- downloadHandler(
            filename = function() 
            { 
                paste0(input$plotTitle, ".svg") 
            },
            content = function(file) 
            { 
                ggplot2::ggsave(file, plot = p, height = 500, width = 500, units = "mm")
            }
        )
    })
}

# 5. Run app
shinyApp(ui = ui, server = server)

```

