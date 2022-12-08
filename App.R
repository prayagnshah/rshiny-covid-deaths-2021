library(shiny)
library(tidyverse)
library(dplyr)

## Reading the data
covid <- read.csv("covid-deaths.csv")
tail(covid)
# filtered_regions <- filter(covid, REGIONS == 'Atlantic Region')

## Writing ui

ui <- fluidPage(

  ## Title of the application
  titlePanel("Covid-Deaths in Canada during 2021"),

  ## Trying to make more pleasing using the themes
  theme = bslib::bs_theme(bootswatch = "minty", version = 5),
  sidebarLayout(
    sidebarPanel(

      ## Sorting the data in filtered manner
      selectInput("Regions", label = "Select any Region:", choices = sort(unique(covid$Regions))),
      selectInput("Gender", label = "Select any Gender:", choices = sort(unique(covid$Gender))),
      selectInput("Age_group", label = "Select any age-group:", choices = sort(unique(covid$Age_group))),
      width = 3
    ),

    ## Main panel for outputs
    mainPanel(
      tabsetPanel(

        ## Panel 1
        tabPanel(
          "Data",
          dataTableOutput("table")
        )
      ),
      width = 9
    )
  )
)


## Writing server part

server <- function(input, output, session) {
  covid_filter <- reactive({
    # ##using the filter package to print the filtered values
    dplyr::filter(
      covid,
      Regions %in% covid$Regions,
      Gender %in% covid$Gender,
      Age_group %in% covid$Age_group
    )
    #   # covid %>%
    #   #   select(REGIONS, Gender, Age_group, DEATHS)
    #   #   # filter(Gender == input$regions & Age_group == input$age)
    #
  })


  ## Table output
  output$table <- renderDataTable(
    covid_filter(),
    options = list(pageLength = 10)
  )
}



## Calling shiny application

shinyApp(ui, server)