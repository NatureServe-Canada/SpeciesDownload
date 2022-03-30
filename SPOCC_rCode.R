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
SPOCC_occ <-occ(query= list_sciNames, from = c('idigbio','vertnet', 'inat'), limit = 60000, has_coords = TRUE, throw_warnings = TRUE)

#Reformat the scientific names, so the data can be split by platform (e.g. BISON, iNaturalist) not species name
sciname<-str_replace_all(list_sciNames," ","_")

idig <- SPOCC_occ$idigbio$data[sapply(SPOCC_occ$idigbio$data, nrow) > 0] %>%
  .[sciname] %>%
  do.call(bind_rows, .)

vertnet <- SPOCC_occ$vertnet$data[sapply(SPOCC_occ$vertnet$data, nrow) > 0] %>%
  .[sciname] %>%
  do.call(bind_rows, .)

inat <- SPOCC_occ$inat$data[sapply(SPOCC_occ$inat$data, nrow) > 0] %>%
  .[sciname] %>%
  do.call(bind_rows, .)

#Remove fossils from VertNet occurrences
if (dim(vertnet)[1] != 0) {
  vertnet_cleaned <- vertnet[(vertnet$basisofrecord != "FossilSpecimen"),]
}else{
    print("No records returned in VertNet")
  }

#Select only Research Grade iNaturalist occurrences 
if (dim(inat)[1] != 0) {
  inat_cleaned <- inat[(inat$quality_grade == "research"),]
}else{
  print("No records returned in iNaturalist")
  }

vertvariables<-c("name","longitude","latitude","prov","month","verbatimcoordinatesystem","day","occurrenceid","identificationqualifier","coordinateuncertaintyinmeters","year","basisofrecord","geodeticdatum","georeferenceprotocol","stateprovince","verbatimlocality","references","license","georeferenceverificationstatus","eventdate","individualcount","catalognumber","locality","locationremarks","occurrenceremarks","coordinateprecision")
if (exists("vertnet_cleaned")) {
  vertnet_final<-vertnet_cleaned[vertvariables]
}else{"No records returned in VertNet"}

idigbiovariables<-c("catalognumber", "datasetid","basisofrecord","etag", "canonicalname", "collector", "collectionname", "coordinateuncertainty", "datecollected", "eventdate", "longitude", "latitude", "individualcount", "institutionname", "locality","occurrenceid","uuid","prov","name")
if (exists("idig")) {
  idig_final<-idig[idigbiovariables]
}else{"No records returned in VertNet"}

inatvariables<-c("uuid","out_of_range","id","observed_on","description","latitude","longitude","place_guess","positional_accuracy","geoprivacy","quality_grade","uri","identifications_count","captive","public_positional_accuracy","taxon_geoprivacy","name","prov", "license_code", "obscured")
if (exists("inat_cleaned")) {inat_final<-inat_cleaned[inatvariables]
}else{"No records returned in iNaturalist"}

#Export data as csv to specified folder
write.csv(vertnet_final,file="C:/Desktop/VertNet_Data.csv")
write.csv(idig_final,file="C:/Desktop/iDigBio_Data.csv")
write.csv(inat_final,file="C:/Desktop/iNat_Data.csv")
