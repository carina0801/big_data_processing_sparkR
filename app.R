library(shiny)
library(shinydashboard)


source("R/modules/recommendation_module/recommendation_ui.R")
source("R/modules/recommendation_module/recommendation_server.R")

ui <- dashboardPage(
    dashboardHeader(title = "Movie Analysis Dashboard"),
    dashboardSidebar(
        sidebarMenu(
            menuItem("Home", tabName = "home", icon = icon("home")),
            menuItem("Recommendations", tabName = "recommendations", icon = icon("film")),
            menuItem("Visualizations", tabName = "visualizations", icon = icon("bar-chart-o"))
        )
    ),
    dashboardBody(
        tabItems(
            tabItem(tabName = "home",
                    h2("Welcome to the Movie Analysis Dashboard"),
                    actionButton("go_to_rec", "Go to Recommendations"),
                    actionButton("go_to_vis", "Go to Visualizations")
            ),
            tabItem(tabName = "recommendations",
                    # Include your recommendations UI here or call a module UI function
                    recommendationUI("recommendation_mod")
            ),
            tabItem(tabName = "visualizations",
                    # Include your visualizations UI here or call a module UI function
                    h2("Visualizations Page")
            )
        )
    )
)

server <- function(input, output, session) {
    
    observeEvent(input$go_to_rec, {
        updateTabItems(session, "sidebar", "recommendations")
    })
    
    observeEvent(input$go_to_vis, {
        updateTabItems(session, "sidebar", "visualizations")
    })
    
    # Server logic for each page content would go here
    
    recommendationServer("recommendation_mod")
}

shinyApp(ui, server)
