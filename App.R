library(shiny)
library(sf)


##Reading the data
covid <- read.csv("covid-deaths.csv")
tail(covid)

##Writing ui

ui <- fluidPage(
  
  ##Title of the application
  titlePanel("Covid-Deaths in Canada during 2021"),
  
  ##Trying to make more pleasing using the themes
  theme = bslib::bs_theme(bootswatch = "minty", version = 5),
  
  sidebarLayout(
    
    sidebarPanel(
      
      ##Sorting the data in filtered manner 
      selectInput("region", label = "Select any Region:", choices = sort(unique(covid$REGIONS))),
      selectInput("gender", label = "Select any Gender:", choices = sort(unique(covid$Gender))),
      selectInput("age", label = "Select any age-group:", choices = sort(unique(covid$Age_group))),
      
      width = 3
    ),
    
    ##Main panel for outputs 
    mainPanel(
      tabsetPanel(
        
        ##Panel 1
        tabPanel(
        "Data",
        dataTableOutput("table")
        )
      ),
      
      width = 9
    )
    
  )
)


##Writing server part 

server <- function(input,output,session) {
  
  ##Table output
  output$table <- renderDataTable({
  })
  
}



##Calling shiny application 

shinyApp(ui,server)