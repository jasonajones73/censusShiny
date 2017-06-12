library(tigris)
library(readr)


bg <- block_groups("37", "81")


acs <- read_csv("C:/Users/jjones6/Desktop/censusShiny/data/acsForR2.csv")



final <- geo_join(shape, acs, "GEOID", "Geo_FIPS")


library(GISTools)
library(rgdal)

writeOGR(obj=bg, dsn="tempdir", layer="bg", driver="ESRI Shapefile")
