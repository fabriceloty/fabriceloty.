#biblioth�ques � charger
library(tmap)
library(tidyverse)
library(grid)
library(GISTools)
library(sf)
library(rgdal)
library("readxl")

#SCRIPT: cartes th�matiques
par(mar = c(0,0,5,0))
setwd("E:\\THESE\\THESE\\2024\\7 JUILLET 2024\\2 R GIS TUTORIAL\\CMR")
#create spatial object
cmr <- readOGR("cmr_admbnda_adm3_inc_20180104.shp")
#Carte avec bordures r�gions
regions <- readOGR("cmr_admbnda_adm1_inc_20180104.shp")
#modifier le nom de r�gion
regions$ADM1_FR[4] <- "Extr�me-Nord" 

#Convertir en sf
cmr_sf <- st_as_sf(cmr)
#Importer la base compl�t�e � partir d'Excel
cmr_data = read_excel("dataset.xlsx")
#merging sf with excel dataset
cmr_datasf = left_join(cmr_sf, cmr_data)

