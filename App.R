library(shiny)
library(sf)
library(tidyverse)

##Reading the map of Canada 

geo1 <- sf::st_read("data/canada_cd_sim.geojson", layer = "canada_cd_sim") |>
  sf::st_transform(crs = 4326)


##Reading the data
covid <- read.csv("data/covid-deaths.csv")
tail(covid)
# filtered_regions <- filter(covid, REGIONS == 'Atlantic Region')

##Writing ui

ui <- fluidPage(
  
  ##Title of the application
  titlePanel("Covid-Deaths in Canada during 2021"),
  
  ##Trying to make more pleasing using the themes
  theme = bslib::bs_theme(bootswatch = "minty", version = 5),

  
  sidebarLayout(
    
    sidebarPanel(
       
      ##Sorting the data in filtered manner 
      selectInput("Regions", label = "Select any Region:", choices = sort(unique(covid$Regions)), multiple = T, selected = covid$Regions[1]),
      selectInput("Gender", label = "Select any Gender:", choices = sort(unique(covid$Gender)), multiple = T, selected = covid$Gender[1]),
      selectInput("Age_group", label = "Select any age-group:", choices = sort(unique(covid$Age_group)), multiple = T, selected = covid$Age_group[1]),
      br(), 
      h4("Spatial filtering"), 
      sliderInput("lon", label = "Longitude", value = c(-110, -16), min = -120, max = -15), 
      sliderInput("lat", label = "Latitude", value = c(35, 83), min = 31, max = 85), 
      
      width = 3
    ),
    
    ##Main panel for outputs 
    mainPanel(
      tabsetPanel(
        
        ##Panel 1
        tabPanel(
        "Data",
        dataTableOutput("table")
        ),
        
        ##Panel 2
        tabPanel(
          "Map",
          leafletOutput("map", width = "100%")
        )
      ),
      
      width = 9
    )
    
  )
)


##Writing server part 

server <- function(input,output,session) {
  
  
  covid_filter <- reactive({

    ##using the filter package to print the filtered values as per user's input
    dplyr::filter(
      covid,
        Regions %in% input$Regions,
        Gender %in% input$Gender,
        Age_group %in% input$Age_group
    )
  })

  geo_filter <- reactive({
    
    ##Creating the bounding box 
    bbox <- c(
      xmin = input$lon[1], ymin = input$lat[1],
      xmax = input$lon[2], ymax = input$lat[2]
    ) |>
      
      sf::st_bbox(crs = sf::st_crs(4326))  |>
      sf::st_as_sfc()
    
      ##Intersecting with the atlas grid 
      geo1[bbox, ]
  })
  
  
  ##Table output
  output$table <- renderDataTable(
    covid_filter(),
    options = list(pageLength = 10)
  )
  
  output$map <- renderLeaflet({
    pal <- leaflet:colorNumeric(
      viridis::viridis_pal(option = "D")(100), 
      
    )
    
    ##Map 
    
    leaflet(geo_filter()) |>
      setView(lng = -50, lat = 60, zoom = 5) |>
      addProviderTiles("CartoDB.Positron") |>
      addPolygons(
        opacity = 1,
        weight = 1,
        color = pal(geo_filter)
      ) |>
      
      addLegend(
        position = "bottomright",
        pal = pal, 
        values = seq(length.out = 5),
        opacity = 1, 
        title = "Covid Deaths"
      )
  })
  
}



##Calling shiny application 

shinyApp(ui,server)