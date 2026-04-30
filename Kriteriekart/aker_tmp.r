

# Load libraries ----------------------------------------------------------

library(dplyr)
library(sf)
library(terra)
library(rgrass)
library(mapview)

# connect to GRASS
NinaR::grassConnect(location = "ETRS_32N", mapset = "p_Restaurerbar_Akershus")

# Set up grass environment ------------------------------------------------

execGRASS("g.region", vector = "akershus_vect", flags = "p", res = "5")
execGRASS("g.remove", type = "raster", name = "MASK", flags = "f")


# Import data -------------------------------------------------------------

# AR5 polygons
ar5 <- st_read("/data/R/GeoSpatialData/Topography/Norway_FKB/Original/FKB-AR5 FGDB-format/Basisdata_32_Akershus_25832_FKB-AR5_FGDB.gdb", layer = "fkb_ar5_omrade")

# Pollinator prediction raster
poll <- rast("/data/P-Prosjekter2/155014_restaurerbar_natur_akershus/2026/Data/Kantsoner/polliland_akershus.tif")

# Gråareal
ga <- st_read("/data/R/GeoSpatialData/LandCover/Norway_Grå_Arealer_versjon1/Original/Kart over grå arealer GeoPackage-format/32_25835_graastruktur_gpkg.gpkg", layer = "GraaArealFlate") %>% 
  st_transform(25832)

# jordkvalitet
jk <- st_read("/data/P-Prosjekter2/155014_restaurerbar_natur_akershus/2026/Data/Kantsoner/jordkvalitet.gpkg", layer = "jordkvalitet") %>% 
  mutate(jordkvalitet = as.numeric(jordkvalitet))# 1 = svært god, 2 = god, 3 = mindre god

# invasive species
invasive <- rast("/data/P-Prosjekter2/155014_restaurerbar_natur_akershus/2026/Data/Kantsoner/invasive_neighborhood.tif")

# classify fulldyrka jord and overflatedyrka jord as åker
# everything else as NA
aker <- ar5 %>%
  mutate(kantklasse = if_else(arealtype %in% c("21", "22", "23"), "Aker", NA_character_)) %>%
  filter(!is.na(kantklasse)) %>% 
  st_make_valid
rm(ar5)

write_VECT(vect(aker), "aker_vect")
write_VECT(vect(ga), "graareal_vect")
write_VECT(vect(jk), "jordkvalitet_vect", flags = "overwrite")

# Rasterize vectors -------------------------------------------------------

# Åker
execGRASS("v.to.rast",
          input = "aker_vect",
          output = "aker_rast",
          use = "val",
          value = 1,
          flags = "overwrite")

# Gråareal
execGRASS("v.to.rast",
          input = "graareal_vect",
          output = "graareal_rast",
          use = "val",
          value = 1,
          flags = "overwrite")

# Jordkvalitet
execGRASS("v.to.rast",
          input = "jordkvalitet_vect",
          output = "jordkvalitet_rast",
          use = "attr",
          attribute_column = "jordkvalitet",
          flags = "overwrite")

# Grow distance from åker rast
execGRASS("r.grow.distance",
          input = "aker_rast",
          distance = "dist_to_aker",
          flags = "overwrite")

# create a field margin raster
execGRASS("r.mapcalc",
          expression = "kant_rast = if(dist_to_aker <= 15 && isnull(aker_rast), 1, null())",
          flags = "overwrite")

# Remove gråareal ---------------------------------------------------------

execGRASS("r.mapcalc",
          expression = "kant_clean = if(!isnull(kant_rast) && isnull(graareal_rast), 1, null())",
          flags = "overwrite")

# convert back to vector
execGRASS("r.to.vect",
          input = "kant_clean",
          output = "kant_vect",
          type = "area",
          flags = "overwrite")


# write to tmp gpkg
execGRASS("v.out.ogr",
          input = "kant_vect",
          output = "/data/scratch/tmp_jenny/gpkg/kant_vect.gpkg",
          format = "GPKG",
          flags = "overwrite")

# read into r environment
kant_clean <- st_read("/data/scratch/tmp_jenny/gpkg/kant_vect.gpkg")

# filter out polygons smaller than 1000 sq. m
kant_filtered <- kant_clean %>% 
  mutate(area = as.numeric(st_area(.))) %>% 
  filter(area >= 10000)

mapview(kant_filtered)


# Extract relevant variable values ----------------------------------------

jk_rast <- read_RAST("jordkvalitet_rast")

kant_vect <- vect(kant_filtered)

# extract mean pollinator
res_poll <- extract(poll, kant_vect, fun = mean, na.rm = TRUE)
kant_vect$mean_poll <- res_poll[,2]

# extract mean invasive
res_inv  <- extract(invasive, kant_vect, fun = mean, na.rm = TRUE)
kant_vect$mean_invasive <- res_inv[,2]

# extract jordkvalitet
res_jk  <- extract(jk_rast, kant_vect, fun = mean, na.rm = TRUE)
kant_vect$mean_jordkvalitet <- res_jk[,2]

kant_sf <- st_as_sf(kant_vect)

# Rubrik for finding suitable margins -------------------------------------

# remove polygons lacking values
kant_filtered <- kant_sf %>% 
  filter(!is.na(mean_poll),
         !is.na(mean_invasive),
         !is.na(mean_jordkvalitet))

# summary values
summary(kant_filtered$mean_poll)
summary(kant_filtered$mean_invasive)
summary(kant_filtered$mean_jordkvalitet)

# prioritize bad soil quality
kant_soil <- kant_filtered %>% 
  filter(mean_jordkvalitet == 3)
mapview(kant_soil) # n = 43

# bad(ish) soil quality and high invasive presence
kant_soil_inv <- kant_filtered %>% 
  filter(mean_jordkvalitet >= 2,
         mean_invasive >= 0.5) # n = 85
mapview(kant_soil_inv)

# all three values
kant_all <- kant_filtered %>% 
  filter(mean_jordkvalitet >= 2,
         mean_invasive >= 0.5,
         mean_poll >= 4) # n = 33
mapview(kant_all)
