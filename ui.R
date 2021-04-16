library(shiny)

shinyUI(fluidPage(
  titlePanel(title = h2("Historical Stats of English Soccer", align="center", 
                        style = "font-family: 'Lobster', cursive;
                        font-weight: 500; line-height: 1.1; 
                        color: blue;")),
  sidebarLayout(sidebarPanel(
    
    #using ConditionalPanel to define different sidebarPanel options for each tab
    conditionalPanel(condition="input.tabselected==1", br(),
                     helpText(" This map is used to pin point the location of each club.
                              (Hover over the marker for more information)"),
                     selectizeInput("team", "Select Club", choices = sort(location$Club), 
                                    selected = location$Club[1], multiple = TRUE)),
    
    conditionalPanel(condition="input.tabselected==2", br(),
                     selectInput("club", "Select Club", choices = stat$Team, 
                                 selected = "All"),
                     selectInput("season", "Select Season", choices = stat$Season, 
                                 selected = "All")),

    conditionalPanel(condition="input.tabselected==3",
                     helpText("Select team name to view the over-all win, loss and draw records. 
                              The bar chart determines the win-loss record of individual team.
                              (Hover over the bar for the numbers)"),
                     br(),
                     selectizeInput("r_teams", "Select Team", 
                                    choices = win_loss$Team,
                                    selected = win_loss$Team[1]),
                     br(),
                     br(),
                     br(),
                     br(),
                     br(),
                     br(),
                     br(),
                     br(),
                     br(),
                     br(),
                     br(),
                     br(),
                     br(),
                     br(),
                     helpText("Make Selection to compare the win,loss and draw record of every team."),
                     br(),
                     selectInput("win_loss", "Make Selection", choices = c("Overall Wins" = "T_wins",
                                                                           "Overall Losses"="T_loss",
                                                                           "Overall Draws"="T_draws")),
                     helpText("This bar chart helps to compare win,loss and draw record of all the teams at the same time.")),
    
    conditionalPanel(condition = "input.tabselected==4", br(),
                     selectInput("goal", "Make Selection", choices = c("Total goals"="Total_goals",
                                                                       "Goals per match" = "goals_match")),
                     checkboxInput("trend", "Show trendlines", FALSE)
                                   ),
    
    conditionalPanel(condition = "input.tabselected == 5",
                     selectizeInput("c_transfer", "Select Club", choices = transfer$Club,
                                    selected = transfer$Club[1])),
    
    #To display image on the sidebar
    conditionalPanel(condition = "input.tabselected == 6", img(src="logo.png", height = 300, width = 400)),
    
    tags$style("body{background-color:white; color:black}")),
    
    
                mainPanel(
                  
                  #Different visualizations are shown in the form of tabs
                  tabsetPanel(type='tab',
                              
                              tabPanel(h4("Intro",
                                          style = "font-family: 'Lobster', cursive;
                                      font-weight: 500; line-height: 1.1; 
                                          color: black;"), value = 6, h1(strong("The English Premier league!"), style = "font-family: 'bookman'; font-size: 30px;"),
                                       p("The Premier League (often referred to as the English Premier League (EPL) outside England) is the top level of the English football league system. 
                                         Contested by 20 clubs, it operates on a system of promotion and relegation with the English Football League (EFL).", style = "font-family: 'georgia'; font-size: 18px;"),
                                       p("Forty-nine clubs have competed since the inception of the Premier League in 1992. Six of them have won the title since then:", style = "font-family: 'georgia'; font-size: 18px;", 
                                         strong(" Manchester United (13), Chelsea (5), Manchester City (4), Arsenal (3), Blackburn Rovers (1), and Leicester City (1).", style = "font-family: 'georgia'; font-size: 18px;"), 
                                          "The record of most points in a Premier League season is 100, set by Manchester City in 2017â18.", style = "font-family: 'georgia'; font-size: 18px;"),
                                       p("The visualization explores the historic stats of premier league comapring various statistics
                                         between the football clubs. Navigate through different tabs to view the interacting data visualizations.",
                                         style = "font-family: 'georgia'; font-size: 18px;")),
                              
                              tabPanel(h4("Geo-Location",
                                      style = "font-family: 'Lobster', cursive;
                                      font-weight: 500; line-height: 1.1; 
                                        color: black;"), value=1,
                                       leafletOutput("map1", width = "100%", height = 600)
                                       ),
                              
                              tabPanel(h4("Stats",
                                          style = "font-family: 'Lobster', cursive;
                                          font-weight: 500; line-height: 1.1; 
                                          color: black;"), value=2, shiny::tableOutput("tab2_table")),
                              
                              tabPanel(h4("Win-Loss Record", style = "font-family: 'Lobster', cursive;
                                          font-weight: 500; line-height: 1.1; 
                                          color: black;"), value = 3, 
                                       highchartOutput("win_loss_plot"), plotOutput("barchart")),
                              
                              tabPanel(h4("Goals Trend", 
                                          style = "font-family: 'Lobster', cursive;
                                          font-weight: 500; line-height: 1.1; 
                                          color: black;"), value = 4, 
                                       br(),
                                       p("English Premier league is one of the most competivie leagues in Europe.
                                         About 1000 goals are scored every year with every match producing about 2.6 goals on an average.
                                         The scatterplot helps to find the correlation between the goals and years.",
                                         style = "font-family: 'georgia'; font-size: 18px;" ),
                                       br(),
                                       plotOutput("goal_graph")),
                              
                              tabPanel(h4("Club Spendings", 
                                          style = "font-family: 'Lobster', cursive;
                                          font-weight: 500; line-height: 1.1; 
                                          color: black;"), value = 5, 
                                       br(),
                                       p("Football Clubs invest heavily in transfer market to get top players across the world.
                                         The top 20 spenders of EPL since 2003 is projected below. With the nett spending of over 1000 million pounds, 
                                         manchester city leads the pack.", style = "font-family: 'georgia'; font-size: 18px;" ),
                                       br(),
                                       highchartOutput("transfer_plot")),
                              
                              id="tabselected"
                              )
                         )
                 )
              ))
  
