recommendationServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    
    # Reactive expression to store and react to the input text
    reactive_text <- reactive({
      input$input_id
    })
    
    # Observer to react when the submit button is pressed
    observeEvent(input$submit_btn, {
      # Access the text from the reactive expression
      entered_text <- reactive_text()
      
      # You can add your logic here that uses the entered_text
      # For example, displaying it or using it in a calculation or query
      print(paste("Text entered:", entered_text))
    })
    
    # Further server logic can be added here
  })
}
