if (!requireNamespace("httr", quietly = TRUE)) install.packages("httr")
if (!requireNamespace("jsonlite", quietly = TRUE)) install.packages("jsonlite")
if (!requireNamespace("dplyr", quietly = TRUE)) install.packages("dplyr")

library(httr)
library(jsonlite)
library(dplyr)

library(sparklyr)

Sys.setenv(SPARK_HOME = "/usr/lib/spark")
sc <- spark_connect(master = "yarn")

loaded_als_model <- ml_load(sc, path = "s3a://mymodelbucket1/als_model3")
print(loaded_als_model)

metadata_s3_path <- "s3://mymoviesdatasetstorage/archive (1)/movies_metadata.csv"
metadata <- spark_read_csv(sc, "metadata", metadata_s3_path)


links_s3_path <- "s3://mymoviesdatasetstorage/archive (1)/links.csv"
links <- spark_read_csv(sc, "links", links_s3_path)





s3_uri <- "s3://mymoviesdatasetstorage/archive (1)/ratings_small.csv"
ratings <- spark_read_csv(sc, "ratings", s3_uri)


movie_titles_df <- metadata %>%
  mutate(id = as.integer(id)) %>%
  select(id,imdb_id, original_title) %>%
  sdf_register("movie_titles")


poster_path <- metadata %>%
  mutate(id = as.integer(id)) %>%
  select(id, poster_path) %>%
  sdf_register("poster_path")


movie_titles_df <- movie_titles_df %>%
  inner_join(ratings, by = c("id" = "movieId")) %>%
  select(id,imdb_id, original_title) %>%
  distinct() # Ensure unique results if needed

# Step 4: Register the filtered DataFrame as a temporary table again (if needed)
sdf_register(movie_titles_df, "movie_titles")

# Step 5: Count the number of entries in the filtered DataFrame
entry_count <- movie_titles_df %>% sdf_nrow()

# Print out the number of filtered movie titles
print(entry_count)



links <- links %>% mutate(movieId = as.integer(movieId))

# Continue with your operations
links_tmdb <- links %>%
  select(movieId, tmdbId) %>%
  sdf_register("links_tmdb")

filtered_links <- links_tmdb %>%
  semi_join(movie_titles_df, by = c("movieId" = "id"))

# Review the result to confirm it has the expected structure and data
print(filtered_links)



movie_titles_df <- movie_titles_df %>%
  left_join(links_tmdb, by = c("id" = "movieId"))%>%
  sdf_register("movie_titles")

print(movie_titles_df)
