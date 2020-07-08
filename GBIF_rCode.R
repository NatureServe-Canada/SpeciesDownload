#This code uses r packages rgbif: https://cran.r-project.org/web/packages/rgbif/index.html and tidyverse: https://www.tidyverse.org/

#Install packages
install.packages("rgbif")
install.packages("tidyverse")

#Load packages 
library(rgbif)
library(tidyverse)

#List species you would like to search
list_sciNames <- c("Bombus bohemicus","Bombus occidentalis","Bombus suckleyi","Somatochlora septentrionalis","Germaria angustata","Stagnicola kennicotti")

#Search for the taxonKeys of the species listed above, including subpsecies and varities
keys <- lapply(list_sciNames, function(x) name_suggest(x, rank=c("species", "subspecies", "variety"))) %>%
  bind_rows()%>%
  select(key)%>%
  unlist(use.names = F)

#Search for the GBIF occurrences for the species listed above (*Note make sure you review the limit (default is 500, hard maximum is 100,000) based on the number of occurrences likely to be returned*) 
GBIF_occ <- occ_search(taxonKey = keys, return="data", hasCoordinate = TRUE, limit= 60000, fields=c('occurrenceID','gbifID','scientificName', 'locality', 'stateProvince', 'individualCount','decimalLatitude','decimalLongitude','coordinateUncertaintyInMeters','day','month','year','basisOfRecord','institutionCode','identifiedBy','dateIdentified','license','recordedBy','issues','references','geodeticDatum','countryCode','informationWithheld','verbatimLocality','occurrenceRemarks','species'))

#Identify taxonKeys that returned GBIF occurrences  
GBIF_names <- GBIF_occ %>%
  sapply(., nrow) %>%
  unlist(.) %>%
  names(.)

#Merge data into single table for export
GBIF_data <- GBIF_occ %>%
  .[GBIF_names] %>%
  do.call(bind_rows, .)

#Remove Fossil records
GBIF_sub <-subset(GBIF_data, GBIF_data$basisOfRecord != "FOSSIL_SPECIMEN")

#Export as csv to specified folder
write.csv(GBIF_sub,"C:/Desktop/GBIF_Data.csv")