library(shiny)
library(sparklyr)
library(dplyr)

source("R/modules/recommendation_module/recommendation_helper.R")



# Server function
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
          
          num_rows <- sdf_nrow(similar_movies)
          similar_movies_limited <- head(similar_movies, 10)
          
          similar_movies_df <- similar_movies_limited %>%
            left_join(movie_titles_df, by = c("movieId" = "id")) %>%
            collect()
          
          similar_movies_df$poster_url <- sapply(similar_movies_df$imdb_id, get_tmdb_id_from_imdb_id, api_key)
          
          output$movie_cards <- renderUI({
            fluidRow(
              lapply(seq_len(nrow(similar_movies_df)), function(i) {
                movie <- similar_movies_df[i, ]
                column(4,
                       div(
                         class = "card",
                         style = " width: 18rem; margin-bottom: 20px;",
                         div(class = "card-body",
                             img(src = movie$poster_url, style = "height:250px;width:100%"),  # Display the poster
                             h5(class = "card-title", movie$original_title),
                             actionButton(ns(paste0("info_", movie$movieId)), "More Info")
                         )
                       )
                )
              })
            )
          })
          
          lapply(similar_movies_df$movieId, function(movie_id) {
            observeEvent(input[[ns(paste0("info_", movie_id))]], {
              selected_movie <- similar_movies_df[similar_movies_df$movieId == movie_id, ]
              showModal(modalDialog(
                title = sprintf("More Information on %s", selected_movie$original_title),
                p("Here is more detailed information about the movie."),
                footer = modalButton("Close")
              ))
            })
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

# Full Shiny app
shinyApp(
  ui = fluidPage(
    recommendationUI("recommendation_module")
  ),
  server = function(input, output, session) {
    sc <- spark_connect(master = "local")
    recommendationServer("recommendation_module", sc)
  }
)
