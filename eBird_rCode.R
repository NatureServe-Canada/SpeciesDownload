#This code uses r packages auk: https://cornelllabofornithology.github.io/auk/ and tidyverse: https://www.tidyverse.org/

#Install packages
install.packages("auk", "tidyverse")

#Load packages 
library(auk)
library(tidyverse)

#set working directory
setwd("C:/Desktop")

#Define input file downloaded from ebird.org
eBird_input <- "ebd_CA_relMar_2021.txt"

#Define temporary output file
eBird_output <- "eBird_filtered_Aechmophorus_occidentalis.txt"

#Load the eBird data
eBird_data <- eBird_input %>% 
  #reference file
  auk_ebd() %>% 
  #define filters
  auk_species(species = "Aechmophorus occidentalis") %>%
  #run filtering
  auk_filter(file = eBird_output) %>% 
  #read text file into r data frame
  read_ebd()

#Read temporary output file and export as .csv for import into ArcGIS Pro
eBird_Final <- read_ebd(eBird_output)

write.csv(eBird_Final,"eBird_filtered_Aechmophorus_occidentalis.csv")
