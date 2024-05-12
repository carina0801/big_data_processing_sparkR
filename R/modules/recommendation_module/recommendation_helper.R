if (!requireNamespace("httr", quietly = TRUE)) install.packages("httr")
if (!requireNamespace("jsonlite", quietly = TRUE)) install.packages("jsonlite")
if (!requireNamespace("dplyr", quietly = TRUE)) install.packages("dplyr")

library(httr)
library(jsonlite)
library(dplyr)


get_movie_details <- function(tmdb_id, api_key) {
  base_url <- "https://api.themoviedb.org/3/movie/"
  query <- paste0(base_url, tmdb_id, "?api_key=", api_key)
  
  response <- GET(query)
  content <- content(response, "text", encoding = "UTF-8")
  parsed_data <- fromJSON(content)
  
  return(parsed_data)
}


get_movie_poster_url <- function(tmdb_id, api_key) {
  movie_details <- get_movie_details(tmdb_id, api_key)
  
  if (!is.null(movie_details$poster_path)) {
    poster_url <- paste0("https://image.tmdb.org/t/p/w500", movie_details$poster_path)
    return(poster_url)
  } else {
    return(NA)  # Return NA if there is no poster
  }
}

tmdb_id <- 17133
api_key <- "31b50f0683d817c0be2dc5e17dd47e2c"

poster_url <- get_movie_poster_url(tmdb_id, api_key)
print(poster_url)


get_tmdb_id_from_imdb_id <- function(imdb_id, api_key) {
  url <- paste0("https://api.themoviedb.org/3/find/", imdb_id, 
                "?api_key=", api_key, "&external_source=imdb_id")
  response <- GET(url)
  data <- content(response, "text")
  parsed <- fromJSON(data)
  
  # Check if movie results are present and not empty
  if (!is.null(parsed$movie_results) && nrow(parsed$movie_results) > 0) {
    # Access the 'id' column directly as it's a data frame
    poster <- get_movie_poster_url(parsed$movie_results$id[1], api_key)
    return(poster)
  } else {
    return(NULL)
  }
}




imdb_id <- "tt0343660"  # Example: IMDb ID for "Toy Story"

# Get the TMDb ID from the IMDb ID
tmdb_id <- get_tmdb_id_from_imdb_id(imdb_id, api_key)

# If a TMDb ID was found, get the poster URL
tmdb_id <- get_tmdb_id_from_imdb_id(imdb_id, api_key)
if (!is.null(tmdb_id)) {
  print(paste("TMDB ID:", tmdb_id))
} else {
  print("No corresponding TMDb ID found for the given IMDb ID.")
  

}


get_movie_poster_url(tmdb_id, api_key)
