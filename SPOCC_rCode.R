#This code uses r packages spocc: https://cran.r-project.org/web/packages/spocc/index.html and tidyverse: https://www.tidyverse.org/

#Install packages
install.packages("spocc")
install.packages("tidyverse")

#Load packages 
library(spocc)
library(tidyverse)

#List species you would like to search
list_sciNames <- c("Bombus bohemicus","Bombus occidentalis","Bombus suckleyi","Somatochlora septentrionalis","Germaria angustata","Stagnicola kennicotti")

#Search BISON, iDigBio, VertNet, Ecoengine and iNaturalist for occurrences of the species listed above (*Note make sure you review the limit (default is 500) based on the number of occurrences likely to be returned*) 
SPOCC_occ <-occ(query= list_sciNames, from = c('bison', 'idigbio','vertnet', 'ecoengine','inat'), limit = 20000, has_coords = TRUE, throw_warnings = TRUE)

#Reformat the scientific names, so the data can be split by platform (e.g. BISON, iNaturalist) not species name
sciname<-str_replace_all(list_sciNames," ","_")

#Extract and combine the occurrence data by platform (e.g. one table for BISON, one table for iNaturalist, etc.)
bison <- SPOCC_occ$bison$data %>%
  .[sciname] %>%
  do.call(bind_rows, .)

idig <- SPOCC_occ$idigbio$data %>%
  .[sciname] %>%
  do.call(bind_rows, .)

ecoengine <- SPOCC_occ$ecoengine$data %>%
  .[sciname] %>%
  do.call(bind_rows, .)

vertnet <- SPOCC_occ$vertnet$data %>%
  .[sciname] %>%
  do.call(bind_rows, .)

inat <- SPOCC_occ$inat$data %>%
  .[sciname] %>%
  do.call(bind_rows, .)

#Remove BISON occurrences without coordinates and fossils (*Note: occurrences without coordinates are already removed from all other platforms)
bison_cleaned<-subset(bison, bison$longitude != "NA", bison$basisOfRecord != "fossil")

#Remove fossils from VertNet occurrences
vertnet_cleaned<-subset(vertnet,vertnet$basisofrecord != "FossilSpecimen")

#Select only Research Grade iNaturalist occurrences 
inat_cleaned<-subset(inat, inat$quality_grade == "research")

#Select only variables needed for EBAR project from each platform 
bisonvariables<-c("catalogNumber", "providedScientificName", "name", "ambiguous", "generalComments", "verbatimLocality", "occurrenceID", "longitude", "basisOfRecord", "collectionID", "institutionID", "license", "latitude", "provider", "centroid", "date", "year", "recordedBy", "prov", "geo")
bison_final<-bison_cleaned[bisonvariables]

vertvariables<-c("name","longitude","latitude","prov","month","verbatimcoordinatesystem","day","occurrenceid","identificationqualifier","coordinateuncertaintyinmeters","year","basisofrecord","geodeticdatum","georeferenceprotocol","stateprovince","verbatimlocality","references","license","georeferenceverificationstatus","eventdate","individualcount","catalognumber","locality","locationremarks","occurrenceremarks","coordinateprecision")
vertnet_final<-vertnet_cleaned[vertvariables]

ecovariables<-c("url","key","longitude", "latitude", "observation_type", "name", "source", "locality", "coordinate_uncertainty_in_meters", "recorded_by", "prov", "begin_date")
eco_final<-ecoengine[ecovariables]

idigbiovariables<-c("catalognumber", "datasetid","basisofrecord","etag", "canonicalname", "collector", "collectionname", "coordinateuncertainty", "datecollected", "eventdate", "longitude", "latitude", "individualcount", "institutionname", "locality","occurrenceid","uuid","prov","name")
idig_final<-idig[idigbiovariables]

inatvariables<-c("uuid","out_of_range","id","observed_on","description","latitude","longitude","place_guess","positional_accuracy","geoprivacy","quality_grade","uri","identifications_count","captive","public_positional_accuracy","taxon_geoprivacy","name","prov")
inat_final<-inat_cleaned[inatvariables]

#Export data as csv to specified folder
write.csv(bison_final,file="C:/Desktop/BISON_Data.csv")
write.csv(vertnet_final,file="C:/Desktop/VertNet_Data.csv")
write.csv(eco_final,file="C:/Desktop/EcoEngine_Data.csv")
write.csv(idig_final,file="C:/Desktop/iDigBio_Data.csv")
write.csv(inat_final,file="C:/Desktop/iNat_Data.csv")