library(shiny)
library(sf)
library(tidyverse)

##Reading the map of Canada 

geo1 <- sf::st_read("data/canada_cd_sim.geojson", layer = "canada_cd_sim") 
  sf::st_transform(crs = 4326)

##Changing the projection according to the Canada's favorite

geo1 <- st_transform(geo1, crs = "+proj=lcc +lat_1=49 +lat_2=77 +lon_0=-91.52 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs")


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
      sliderInput("lon", label = "Longitude", value = c(-120, -15), min = -120, max = -15), 
      sliderInput("lat", label = "Latitude", value = c(31, 85), min = 31, max = 85), 
      
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
  
  geo_data <- reactive({
    dat <- dplyr::group_by(
      covid_filter()
    ) |> 
      
      dplyr::summarize(Deaths = sum(Deaths, na.rm = T))
    
    ##Join with spatial data
    dplyr::left_join(geo_filter(), dat)
    dplyr::select(Deaths)
  })
  
  
  ##Table output
  output$table <- renderDataTable(
    covid_filter(),
    options = list(pageLength = 10)
  )
  
  output$map <- renderLeaflet({
    
    rgeo <- range(geo_data()$Deaths, na.rm = T)
    pal <- leaflet:colorNumeric(
      viridis::viridis_pal(option = "D")(100), 
      domain = rgeo
      
    )
    
    ##Map 
    
    leaflet(geo_data()) |>
      setView(lng = -50, lat = 60, zoom = 5) |>
      addProviderTiles("Mapbox") |>
      addPolygons(
        opacity = 1,
        weight = 1,
        color = ~ pal(geo_data()$Deaths)
      ) |>
      
      addLegend(
        position = "bottomright",
        pal = pal, 
        values = seq(rgeo[1], rgeo[2], length.out = 5),
        opacity = 1, 
        title = "Covid Deaths"
      )
  })
  
}



##Calling shiny application 

shinyApp(ui,server)