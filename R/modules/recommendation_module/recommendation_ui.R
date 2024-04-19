# recommendation_module_ui.R
recommendationUI <- function(id) {
  ns <- NS(id)
  fluidPage(
    textInput(ns("input_id"), "Favourite Movie name", value = ""),
    
    actionButton(ns("submit_btn"), "Submit")
  )
}
