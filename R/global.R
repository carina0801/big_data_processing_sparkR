library(sparklyr)

Sys.setenv(SPARK_HOME = "/usr/lib/spark")
sc <- spark_connect(master = "yarn")