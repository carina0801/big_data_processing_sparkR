# app.R
library(shiny)
library(shinydashboard)

# Source required files
source("R/modules/recommendation_module/recommendation_ui.R")
source("R/modules/recommendation_module/recommendation_server.R")
source("R/global.R")  # Ensure that this is sourced before calling the server functions

ui <- dashboardPage(
    dashboardHeader(title = "Movie Analysis Dashboard"),
    dashboardSidebar(
        sidebarMenu(
            menuItem("Home", tabName = "home", icon = icon("home")),
            menuItem("Recommendations", tabName = "recommendations", icon = icon("film")),
            menuItem("Visualizations", tabName = "visualizations", icon = icon("chart-bar"))
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
                    recommendationUI("recommendation_mod")
            ),
            tabItem(tabName = "visualizations",
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
    
    # Pass the Spark dataframe to the recommendation server module
    recommendationServer("recommendation_mod", sc)
}

shinyApp(ui = ui, server = server)
