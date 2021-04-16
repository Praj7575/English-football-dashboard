library(dplyr)
library(leaflet)
library(highcharter)
library(ggplot2)
library(shiny)

#load location dataset
location <- read.csv('fc_city.csv')
#View(location )

#load epl dataset
epl <- read.csv('epl_data.csv')
#View(epl)

#read new dataset stats, some changes are included manually 
stat <- read.csv('epl_stats.csv')
#View(stat)
#str(stat)

#converting factors to character datatype
stat$Team <- as.character(stat$Team)
stat$Season <- as.character(stat$Season)

#a new dataframe is created
total_goals <- epl %>%
  group_by(Season) %>%
  summarise(Total_goals = sum(MatchGoals),
            goals_match = round(mean(MatchGoals),2))


require(stringr)
total_goals$Season <-  as.numeric(str_sub(as.character(total_goals$Season), 1, 4))

#View(total_goals)
#str(total_goals)

#calculate win-loss reacord for each team
win_loss <- stat %>%
  group_by(Team) %>%
  summarise(Total_wins = sum(T_wins),
            Total_draw = sum(T_draws),
            Total_loss = sum(T_loss))

#removing record with "All" variable
win_loss <- win_loss[-c(1),]

#View(win_loss)
#str(win_loss)


#dataset containing transfer records of football clubs
transfer <- read.csv("transfer.csv", stringsAsFactors = FALSE)

shinyServer(
  function(input, output, session){
    
    filterdata <- reactive({
      location[location$Club %in% input$team,]
    })
    
    #creating reactive map
    output$map1 <- renderLeaflet({
      leaflet(data=filterdata())%>%
        addProviderTiles("OpenStreetMap.Mapnik")%>%
        setView(lat=53.4084,lng=-2.9916, zoom = 6) %>%
        addMarkers(lng = ~Longitude, lat = ~Latitude,
                   label = paste("Club: ", filterdata()$Club, ",",
                                 "Located at: ",filterdata()$City, ","),
                   labelOptions = labelOptions(textsize="14px"))
    })
    
    
    observe(leafletProxy("maps", data = filterdata()) %>%
              clearMarkers() %>%
              addProviderTiles("OpenStreetMap.Mapnik") %>%
              setView(lat=53.4084,lng=-2.9916, zoom = 6) %>%
              addMarkers(lng = ~Longitude, lat = ~Latitude,
                         label = paste("Club: ", filterdata()$Club, ",",
                                       "Located at: ",filterdata()$City, ","),
                         labelOptions = labelOptions(textsize="14px")))
    
    filter_stat <- reactive({
      rows <- (input$club == "All" | stat$Team == input$club) &
        (input$season == "All" | stat$Season == input$season)
      stat[rows,,drop=FALSE]
    })
    
    output$tab2_table <- renderTable(filter_stat())
    
    reactivedf <- reactive({
      filtereddf <- win_loss %>%
        dplyr::filter(Team==input$r_teams)
      filtereddf
    })
    
    
    output$win_loss_plot <- renderHighchart({
      highchart() %>%
        hc_add_series(type = "column", reactivedf()$Total_wins, name = "wins") %>%
        hc_add_series(type = "column", reactivedf()$Total_draw, name = "draw") %>%
        hc_add_series(type = "column", reactivedf()$Total_loss, name = "loss") %>%
        hc_xAxis(labels = list(enabled = FALSE)) %>%
        hc_title(text = input$w_team)
    })
    
    output$barchart <- renderPlot({
      win_loss_agg <- aggregate(stat[,input$win_loss]~Team, stat ,sum)
      x <- barplot(win_loss_agg[,2], names.arg=win_loss_agg$Team, las =2)
    })
    
    
    output$goal_graph <- renderPlot({
      
      g <- ggplot(total_goals, aes_string(x=total_goals$Season,
                                          y=input$goal)) +
        geom_line(stat = "Identity", linetype = "dashed") + geom_point() +
        geom_point(stat = "Identity", shape=19, size=3, colour = "red") +
        ylab("Goals") + xlab("Season") +
        theme(legend.title=element_blank(), legend.position = "None",
              text = element_text(color="grey23", size=14),
              axis.text.x = element_text(color="grey23",size=rel(1.2), angle = 45),
              axis.text.y = element_text(color="grey23", size=rel(1.2)),
              axis.title.x = element_text(size=rel(1.2)),
              axis.title.y = element_text(size=rel(1.2)),
              axis.ticks.x = element_blank(),
              axis.ticks.y = element_blank(),
              panel.grid.major.y = element_line(color="grey80"),
              panel.grid.major.x = element_line(color="grey80"),
              panel.grid.minor = element_blank(),
              panel.background = element_rect(fill="ghostwhite"),
              plot.background = element_rect(fill="ghostwhite"))
      
      
      g1 <- ggplot(total_goals, aes_string(x=total_goals$Season,
                                           y=input$goal)) +
        geom_point(stat = "Identity", shape=19, size=3, colour = "red") +
        geom_line(stat = "Identity", linetype = "dashed") + geom_point() +
        geom_smooth(size=1, alpha = 0.05) +
        ylab("Goals") + xlab("Season") +
        theme(legend.title=element_blank(), legend.position = "None",
              text = element_text(color="grey23", size=14),
              axis.text.x = element_text(color="grey23",size=rel(1.2), angle = 45),
              axis.text.y = element_text(color="grey23", size=rel(1.2)),
              axis.title.x = element_text(size=rel(1.2)),
              axis.title.y = element_text(size=rel(1.2)),
              axis.ticks.x = element_blank(),
              axis.ticks.y = element_blank(),
              panel.grid.major.y = element_line(color="grey80"),
              panel.grid.major.x = element_line(color="grey80"),
              panel.grid.minor = element_blank(),
              panel.background = element_rect(fill="ghostwhite"),
              plot.background = element_rect(fill="ghostwhite")) 
      
      ifelse(input$trend==T,
             print (g1),
             print(g))
      
    })
    
    transfer_data <- reactive({
      f_transfer <- transfer %>%
        dplyr::filter(Club==input$c_transfer)
      f_transfer
    })
    
    output$transfer_plot <- renderHighchart({
      highchart() %>%
        hc_add_series(type = "bar", transfer_data()$Purchased, name = "Purchased") %>%
        hc_add_series(type = "bar", transfer_data()$Sold, name = "Sold") %>%
        hc_add_series(type = "bar", transfer_data()$Nett, name = "Nett") %>%
        hc_add_series(type = "bar", transfer_data()$Per.Season, name = "Per/Season") %>%
        hc_xAxis(labels = list(enabled = FALSE)) %>%
        hc_title(text = input$c_transfer) %>%
        hc_subtitle(text = "Total Money Spent in Million Pounds")
    })
    
  }
)
