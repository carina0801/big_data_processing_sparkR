# recommendation_ui.R

# Define the UI part of the module
recommendationUI <- function(id) {
  ns <- NS(id)
  tagList(
    div(
      style = "display: flex; align-items: center;",
      textInput(ns("movie_name"), "Favorite Movie Name", "", width = "300px"),
      actionButton(ns("submit"), "Submit", style = "margin-left: 10px;")
    ),
    uiOutput(ns("dynamic_suggestions")),  # Dynamic UI for search suggestions
    h3("Recommendations:"),
    uiOutput(ns("movie_cards")),  # Updated to use uiOutput for cards
    textOutput(ns("not_found_message"))  # Output for no results or error messages
  )
}
