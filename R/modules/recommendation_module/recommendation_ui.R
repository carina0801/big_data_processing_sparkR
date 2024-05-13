recommendationUI <- function(id) {
  ns <- NS(id)
  tagList(
    tags$head(
      tags$style(HTML(sprintf("
        /* Style for the movie name input field */
        #%s {
          width: 120%% !important;
          font-size: 20px;
          height: 90%% !important;
          background-color: white !important;
          outline: 0;
          border-radius: 0.5rem;
        }

        /* Style for the submit button */
        #%s {
          margin-left: 65px !important;
          margin-top: 23px !important;
          font-size: 18px;
          border-radius: 0.5rem;
          color: white;
          background-color: black;
        }

        /* Style for the label of the movie name input to make it larger */
        label[for='%s'] {
          font-size: 24px !important; /* Increasing the font size */
        }
      ", ns("movie_name"), ns("submit"), ns("movie_name"))))
    ),
    div(
      style = "display: flex; align-items: center;",
      textInput(ns("movie_name"), "Enter a movie name:", ""),
      actionButton(ns("submit"), "Search")
    ),
    uiOutput(ns("dynamic_suggestions")),
    h3("Recommendations:"),
    uiOutput(ns("movie_cards")),
    textOutput(ns("not_found_message"))
  )
}
