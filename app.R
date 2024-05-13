library(shiny)
library(shinydashboard)

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
        tags$head(
            tags$link(rel="preconnect", href="https://fonts.googleapis.com"),
            tags$link(rel="preconnect", href="https://fonts.gstatic.com", crossorigin="anonymous"),
            tags$link(href="https://fonts.googleapis.com/css2?family=Reddit+Sans:ital,wght@0,200..900;1,200..900&family=Roboto:ital,wght@0,100;0,300;0,400;0,500;0,700;0,900;1,100;1,300;1,400;1,500;1,700;1,900&display=swap", rel="stylesheet"),
            tags$style(HTML("
                /* Entire navbar styling */
                .main-header {
                    font-family: 'Reddit Sans', sans-serif !important;
                    background-color: white !important;
                    border-bottom: 1px solid grey !important;
                }
                
                .skin-blue .main-header .navbar {
                background-color: #eee;
                }
                .skin-blue .main-header .logo {
    background-color: #eee;
    color: black;
                }

.skin-blue .main-header .logo:hover {
    background-color: #eee;
}

                /* Navbar links and hamburger icon styling */
                .main-header .navbar .sidebar-toggle,
                .main-header .navbar .navbar-custom-menu a {
                    color: black !important; /* Change text and icon color to black */
                }

                /* Hover effect for hamburger icon */
                .main-header .navbar .sidebar-toggle:hover {
                    background-color: #eee !important; /* Light grey background on hover */
                }

                /* Apply Roboto font to the rest of the dashboard */
                body, .content-wrapper {
                    font-family: 'Roboto', sans-serif !important;
                    background-color: white !important;
                }
            "))
        ),
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
    
    recommendationServer("recommendation_mod", sc)
}

shinyApp(ui = ui, server = server)