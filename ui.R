library(shiny)
library(leaflet)
library(shinythemes)
library(RColorBrewer)
library(readr)
library(plotly)

### Read in data ###
acs <- read_csv("C:/Users/jjones6/Desktop/censusShiny/data/acsForR2.csv")

vars <- c(colnames(acs[65:1595]))

### Define UI for application ###
shinyUI(navbarPage("Mapping ACS Data", theme=shinytheme("cerulean"),collapsible = TRUE,
                   
                   tabPanel("Schools",
  ### Sidebar ### 
  sidebarLayout(
    sidebarPanel(
      selectInput("selectSchool", 
                  label = h3("Please select a school"), 
                  choices = c(unique(acs$elementary), unique(acs$middle), unique(acs$high)),
                  selectize = TRUE
                  ),
      
      hr(),
      
      selectInput("selectVariable", 
                  label = h3("Please select a variable"), 
                  choices = vars,
                  selectize = TRUE
                  ),
      
      hr(),
      
      selectInput("selectVariable2", 
                  label = h3("Please select a second variable for scatter plot"), 
                  choices = vars,
                  selectize = TRUE
      ),
      
      submitButton("Update Map")
    ),
    

    mainPanel(
      leafletOutput("map"),
      
      hr(),
      
      fluidRow(
        column(6, plotlyOutput("chart")),
               
        column(6, plotlyOutput("scat"))
      )
    )
  )
  )
))
