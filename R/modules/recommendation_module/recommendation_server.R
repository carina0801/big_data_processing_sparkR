source("R/modules/recommendation_module/recommendation_helper.R")


recommendationServer <- function(id, sc) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    reactive_text <- debounce(reactive({ input$movie_name }), 300)
    
    observe({
      input_text <- reactive_text()
      if (!is.null(input_text) && nchar(input_text) > 0) {
        pattern <- paste0("(?i)", input_text)
        query <- sprintf("SELECT original_title FROM movie_titles WHERE original_title RLIKE '%s'", pattern)
        suggestions <- sparklyr::sdf_sql(sc, query) %>% collect()
        output$dynamic_suggestions <- renderUI({
          if (nrow(suggestions) > 0) {
            tagList(
              div(
                style = "margin-bottom: 10px; padding: 5px; background-color: #f9f9f9; border: 1px solid #ccc; border-radius: 5px;",
                strong("Suggestions:"),
                tags$ul(
                  lapply(suggestions$original_title, function(title) {
                    tags$li(
                      title,
                      style = "padding: 5px; list-style: none; border-bottom: 1px solid #ccc; cursor: pointer;",
                      onclick = sprintf("Shiny.setInputValue('%s', '%s')", ns("selected_suggestion"), title)
                    )
                  })
                )
              )
            )
          } else {
            div()  # Empty div to clear suggestions if none found
          }
        })
      } else {
        output$dynamic_suggestions <- renderUI({ div() })  # Clear suggestions
      }
    })
    
    observeEvent(input$selected_suggestion, {
      updateTextInput(session, "movie_name", value = input$selected_suggestion)
      output$dynamic_suggestions <- renderUI({ div() })  # Clear suggestions after selection
    })
    
    observeEvent(input$submit, {
      entered_text <- reactive_text()
      tryCatch({
        pattern <- paste0("(?i)^", entered_text, "$")
        query <- sprintf("SELECT * FROM movie_titles WHERE original_title RLIKE '%s'", pattern)
        matches <- sparklyr::sdf_sql(sc, query) %>% collect()
        
        if (nrow(matches) > 0) {
          selected_id <- matches$id[1]
          similar_movies <- ml_recommend(loaded_als_model$stages[[2]], type = "item", selected_id)
          api_key <- "31b50f0683d817c0be2dc5e17dd47e2c"
          print(similar_movies)
          num_rows <- sdf_nrow(similar_movies)
          print(num_rows)
          
          similar_movies_limited <- head(similar_movies, 20)
          print(similar_movies_limited)
          
          
          # Now, join this limited DataFrame with your movie titles information
          similar_movies_df <- similar_movies_limited %>%
            left_join(movie_titles_df, by = c("movieId" = "id")) %>%
            collect()
          print(similar_movies_df)
          
          similar_movies_df$poster_url <- sapply(similar_movies_df$imdb_id, get_tmdb_id_from_imdb_id, api_key)
          print(similar_movies_df)
          
          # Apply the get_movie_poster_url function after the data is in R
          
          
          output$movie_cards <- renderUI({
            fluidRow(
              lapply(seq_len(nrow(similar_movies_df)), function(i) {
                movie <- similar_movies_df[i, ]
                column(4,
                       div(
                         class = "card",
                         style = "background-color: #ffcccb; width: 18rem; margin-bottom: 20px;",
                         div(class = "card-body",
                             img(src = movie$poster_url, style = "height:200px;"),  # Display the poster
                             h5(class = "card-title", movie$original_title),
                             
                             a(href = "#", class = "btn btn-primary", "More Info")
                         )
                       )
                )
              })
            )
          })
          
        } else {
          output$not_found_message <- renderText({
            similar_pattern <- paste0("(?i)", entered_text)
            query <- sprintf("SELECT original_title FROM movie_titles WHERE original_title RLIKE '%s'", similar_pattern)
            suggestions <- sparklyr::sdf_sql(sc, query) %>%
              collect()
            
            if (nrow(suggestions) > 0) {
              paste0(
                "Movie ", entered_text, " is not available. ",
                "Maybe you were searching for: ",
                paste(suggestions$original_title, collapse = ", ")
              )
            } else {
              paste("Movie", entered_text, "is not available.")
            }
          })
        }
        
      }, error = function(e) {
        print("Error: Unable to retrieve recommendations")
        print(e$message)
      })
      
      output$dynamic_suggestions <- renderUI({ div() })  # Clear suggestions after submission
    })
  })
}
