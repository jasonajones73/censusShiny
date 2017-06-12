library(shiny)
library(RColorBrewer)
library(leaflet)
library(readr)
library(DT)
library(htmltools)
library(ggplot2)
library(plotly)
library(rgdal)
library(tigris)


### Define server logic ###
shinyServer(function(input, output) {
  
  ### Read in data ###
  acs <- read_csv("C:/Users/jjones6/Desktop/censusShiny/data/acsForR2.csv")
  ### Read in shapefile ###
  shape <- readOGR(dsn = "C:/Users/jjones6/Desktop/censusShiny/tempdir", layer = "bg" )
  ### Merge data and shapefile ###
  final <- geo_join(shape, acs, "GEOID", "Geo_FIPS")
  
  ### Subset data based on school input ###
  schoolsFilter <- reactive({
    final[final@data$elementary == input$selectSchool | final@data$middle == input$selectSchool | final@data$high == input$selectSchool, ]
    })
  
  acsFilter <- reactive({
    acs[acs$elementary == input$selectSchool | acs$middle == input$selectSchool | acs$high == input$selectSchool, ]
  })
  
  
  output$map <- renderLeaflet({
    ### Construct Intro map w/ school markers ###
    leaflet(final) %>%
      addTiles(urlTemplate="https://api.mapbox.com/styles/v1/jasonajones73/cj3ohxtbf000b2snuj3hsjlp2/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1IjoiamFzb25ham9uZXM3MyIsImEiOiJjajE0YnNjY2UwMDQ4MnFvN2dvdWd4MHNxIn0.yZLkU--A8y1XwkMOfQFfSQ", group="Moonlight") %>%
      addTiles(urlTemplate="https://api.mapbox.com/styles/v1/mapbox/light-v9/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1IjoiamFzb25ham9uZXM3MyIsImEiOiJjajE0YnNjY2UwMDQ4MnFvN2dvdWd4MHNxIn0.yZLkU--A8y1XwkMOfQFfSQ", group="Light") %>%
      addTiles(group="Default Street") %>%
      addTiles(urlTemplate="https://api.mapbox.com/styles/v1/mapbox/streets-v10/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1IjoiamFzb25ham9uZXM3MyIsImEiOiJjajE0YnNjY2UwMDQ4MnFvN2dvdWd4MHNxIn0.yZLkU--A8y1XwkMOfQFfSQ", group="Mapbox") %>%
      
      ### Layers Control ###
      addLayersControl(baseGroups=c("Moonlight", "Light", "Default Street", "Mapbox"), 
                       options=layersControlOptions(collapsed=TRUE)) %>%
      
      ### Add school markers ###    
      addPolygons(stroke=FALSE, weight=1)
    
  })

  
  observe({
    colorBy <- input$selectVariable
    colorData <- acs[[colorBy]]
    
    pal <- colorBin("YlGnBu", colorData, 7, pretty = TRUE)
    
    leafletProxy("map", data = schoolsFilter()) %>%
                  clearShapes() %>%
                  clearPopups()%>%
                  addPolygons(stroke=TRUE,
                              weight=2,
                              opacity = 1,
                              color = pal(colorData),
                              label = paste(sep=" - ", input$selectSchool, paste(colorBy,": ",acs[[colorBy]] ))) %>%
      
      ### Add Reactive Legend ###
      addLegend("bottomleft",
                pal=pal,
                values=colorData,
                title=colorBy,
                layerId="legend")
  })
  
  observe({
    chartBy <- input$selectVariable
    chartBy2 <- input$selectVariable2
    chartBy3 <- input$selectSchool
    chartby4 <- acsFilter()$`Qualifying Name`
    chartData <-  acsFilter()[[chartBy]]
    chartData2 <- acsFilter()[[chartBy2]]
    chartData3 <- acsFilter()[[chartBy3]]
    
    output$chart <- renderPlotly(plot_ly(data = acsFilter(), x=~chartby4, y=~chartData))
    output$scat <- renderPlotly(plot_ly(data = acsFilter(), x=~chartData2, y=~chartData))
  })
  
### End Server Function ###  
})
