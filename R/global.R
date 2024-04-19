library(sparklyr)

Sys.setenv(SPARK_HOME = "/usr/lib/spark")
sc <- spark_connect(master = "yarn")

metadata_s3_path <- "s3://mymoviesdatasetstorage/archive (1)/movies_metadata.csv"
credits_s3 <- "s3://mymoviesdatasetstorage/archive (1)/credits.csv"
metadata <- spark_read_csv(sc, "metadata", metadata_s3_path)
credits <- spark_read_csv(sc, "credits", credits_s3)

movie_titles_df <- metadata %>%
  mutate(id = as.integer(id)) %>%
  select(id, original_title) %>%
  sdf_register("movie_titles")

credits_df2 <- credits %>%

  select(id) %>%
  sdf_register("creditdf2")


# Read the data as text
df_text <- spark_read_text(sc, 
                           name = "credits_text",
                           path = "s3://mymoviesdatasetstorage/archive (1)/credits.csv")

# Parse the text into columns
df_text <- spark_read_text(sc, 
                           name = "credits_text",
                           path = "s3://mymoviesdatasetstorage/archive (1)/credits.csv")

# View the structure of the DataFrame to confirm the column names
sdf_schema(df_text)

df_parsed <- df_text %>%
  mutate(cast = regexp_extract(line, '"cast":\\[.*?\\]', 0),
         crew = regexp_extract(line, '"crew":\\[.*?\\]', 0),
         id = regexp_extract(line, '"id":\\d+', 0)) %>%
  mutate(id = regexp_replace(id, ".*\"id\":", ""))




df_parsed <- df_text %>%
  mutate(cast = regexp_extract(line, '^([^,]*),', 1),  # Extracts the first value
         crew = regexp_extract(line, '^[^,]*,([^,]*),', 1),  # Extracts the second value
         id = regexp_extract(line, '([^,]*)$', 1))  # Extracts the last value


# To view the 'id' column
df_parsed %>%
  select(id) %>%
  collect() %>%
  head() # This will print the first few rows of the 'id' column


# Assuming `movie_titles_df` is already loaded and available
number_of_movies <- sdf_nrow(movie_titles_df)
print(number_of_movies)
