library(RNetCDF)
source('/alphadata01/bstocker/lpx/lpxtools/trunk/landuse/get.land.avail.R')
source('/alphadata01/bstocker/lpx/lpxtools/trunk/landuse/cdf.write.R')
source('/alphadata01/bstocker/lpx/lpxtools/trunk/landuse/regrid_landuse.R')

# ## Read land mask file for output
out.land.avail <- get.land.avail( "halfdeg", verbose=TRUE )
nlon <- length( out.land.avail$lon )
nlat <- length( out.land.avail$lat )

## Read land mask file for output
out.land.avail.1x1deg <- get.land.avail( "1x1deg", verbose=TRUE )

yrs <- read.table( "yrlist.txt", col.names=c("year") )
year  <- yrs$year

print(paste("*** year: ",year))

#filyrstart <- 1500
#filyrend   <- 2004
filyrstart <- 2005
filyrend   <- 2013


transnames <- c(
                "cp", # fraction of grid cell that transitions from cropland to pasture  1
                "pc", #  fraction of grid cell that transitions from pasture to cropland
                "pv", # fraction of grid cell that transitions from pasture to primary land (should be zero) 
                "vp", # fraction of grid cell that transitions from primary to pasture 
                "vc", # fraction of grid cell that transitions from primary to cropland 
                "cv", # fraction of grid cell that transitions from cropland to primary (should be zero) 
                "sc", # fraction of grid cell that transitions from secondary to cropland 
                "cs", # fraction of grid cell that transitions from cropland to secondary 
                "sp", # fraction of grid cell that transitions from secondary to pasture 
                "ps", # fraction of grid cell that transitions from pasture to secondary 
                "vs", # fraction of grid cell that transitions from primary to secondary 11
                "sbh", # biomass harvested from secondary mature forests (in MgC) 12
                "f_sbh", # fraction of grid cell harvested from secondary mature forests 
                "vbh", # biomass harvested from primary forests (in MgC) 14
                "f_vbh", # fraction of grid cell harvested from primary forests  
                "sbh2", # biomass harvested from secondary immature forests (in MgC)
                "f_sbh2", # fraction of grid cell harvested from secondary immature forests  
                "vbh2", # biomass harvested from primary non-forests (in MgC)
                "f_vbh2", # fraction of grid cell harvested from primary non-forests  
                "sbh3", # biomass harvested from secondary non-forests (in MgC)
                "f_sbh3" # fraction of grid cell harvested from secondary non-forests 
                )

mharv <- c(
            FALSE,
            FALSE,
            FALSE,
            FALSE,
            FALSE,
            FALSE,
            FALSE,
            FALSE,
            FALSE,
            FALSE,
            FALSE,
            TRUE, 
            FALSE,
            TRUE, 
            FALSE,
            TRUE, 
            FALSE,
            TRUE, 
            FALSE,
            TRUE, 
            FALSE 
            )

aharv <- c(
            FALSE,
            FALSE,
            FALSE,
            FALSE,
            FALSE,
            FALSE,
            FALSE,
            FALSE,
            FALSE,
            FALSE,
            FALSE,
            FALSE,
            TRUE, 
            FALSE,
            TRUE, 
            FALSE,
            TRUE, 
            FALSE,
            TRUE, 
            FALSE,
            TRUE  
            )

col.names <- c( "year", transnames )
row.names <- as.character( filyrstart:filyrend )

## initialise 2D fields for this year
outfield <- array( NA, dim=c(nlon,nlat,length(transnames)))

## Loop over all land grid cells
for (ilon in 1:nlon){
  for (ilat in 1:nlat){
    if (out.land.avail$avail[ilon,ilat]>0.0){

      ## construct file name for this gridcell
      filnam <- paste("lat",as.character(out.land.avail$lat[ilat]),"lon",as.character(out.land.avail$lon[ilon]),".lu",sep="")
      print(paste("filnam: ",filnam))

      ## open file
      tmp <- read.table( 
                        #paste( "/alphadata01/bstocker/data/landuse_data/luh_gcp2014/original_files/historical/lu/", filnam, sep="" ),
                        paste( "/alphadata01/bstocker/data/landuse_data/luh_gcp2014/original_files/extension/lu/", filnam, sep="" ), 
                        col.names=col.names, 
                        row.names=row.names,
                        header=FALSE
                        #header=TRUE XXX set to true for historical files (not 'extension') !!!
                        )
      
      # print(paste("length of tmp", length(tmp[iyr,2:22])))
      # print(paste("length of outfield", length(outfield[ilon,ilat,])))

      ## find row for this year
      iyr <- which(tmp$year==year)
      
      ## write value into array cell
      for (itrans in 1:length(transnames)){
        outfield[ilon,ilat,itrans] <- tmp[iyr,itrans+1]
      }

    }
  }
}

for (itrans in 1:length(transnames)){
  
  ## Write NetCDF outputs
  print(paste("writing halfdeg",transnames[itrans]))
  cdf.write(
            outfield[,,itrans], transnames[itrans],
            out.land.avail$lon,
            out.land.avail$lat,
            paste("/alphadata01/bstocker/data/landuse_data/luh_gcp2014/tmp/landuse_trans_luh_gcp2014_halfdeg_",transnames[itrans],"_",year,".nc",sep=""),
            time=year,make.tdim=TRUE,
            nvars=1
            )

  ## Regrid to 1x1deg
  if (aharv[itrans]) {
    ## harvest area
    print(paste("regridding harvest area:",transnames[itrans]))
    out.regrid.landuse <- regrid.landuse(
                                         outfield[,,itrans], out.land.avail.1x1deg$avail, fraction=TRUE, harvest=TRUE, aligned=TRUE,
                                         lon=out.land.avail$lon, lat=out.land.avail$lat, verbose=TRUE
                                         )
  } else if (mharv[itrans]) {
    ## harvest mass
    print(paste("regridding harvest mass:",transnames[itrans]))
    out.regrid.landuse <- regrid.landuse(
                                         outfield[,,itrans], out.land.avail.1x1deg$avail, mass=TRUE, aligned=TRUE,
                                         lon=out.land.avail$lon, lat=out.land.avail$lat, verbose=TRUE
                                         )
  } else {
    ## transition area fraction
    print(paste("regridding transition area:",transnames[itrans]))
    out.regrid.landuse <- regrid.landuse(
                                         outfield[,,itrans], out.land.avail.1x1deg$avail, fraction=TRUE, aligned=TRUE,
                                         lon=out.land.avail$lon, lat=out.land.avail$lat, verbose=TRUE
                                         )
  }

  ## Write NetCDF output
  print(paste("writing 1x1deg",transnames[itrans]))
  if (mharv[itrans]){
    cdf.write(
              out.regrid.landuse$lu[,,1], transnames[itrans],
              out.regrid.landuse$lon,
              out.regrid.landuse$lat,
              paste("/alphadata01/bstocker/data/landuse_data/luh_gcp2014/tmp/landuse_trans_luh_gcp2014_1x1deg_",transnames[itrans],"_",year,".nc",sep=""),
              time=year,make.tdim=TRUE,
              nvars=1
              )
  } else {
    cdf.write(
              out.regrid.landuse$lu.rel[,,1], transnames[itrans],
              out.regrid.landuse$lon,
              out.regrid.landuse$lat,
              paste("/alphadata01/bstocker/data/landuse_data/luh_gcp2014/tmp/landuse_trans_luh_gcp2014_1x1deg_",transnames[itrans],"_",year,".nc",sep=""),
              time=year,make.tdim=TRUE,
              nvars=1
              )
  }

}


# README - LAND-USE HISTORY A - VERSION 1

# This README file describes the data in Version 1 of our Land-Use History A product (LUHa.v1). For information on how this data should be cited, and for any additional information/questions/feedback, please contact us at the following: 
# Louise Parsons Chini: lchini@umd.edu, +1-301-405-4050
# George Hurtt: gchurtt@umd.edu, +1-301-405-8541
# Steve Frolking: steve.frolking@unh.edu, +1-603-862-0244
# LUHa.v1 is identical to LUHa.rc2 which underwent an extensive period of review by the scientific community it has now been renamed with a version number.

# The data is provided within four compressed archive files to enable faster downloading:

# LUHa.v1 - our baseline product that covers the historical period from 1500 to 2005, computes landuse and transitions between cropland, pasture, primary land and secondary (recovering) land, including the effects of wood harvest and shifting cultivation.

# LUHa_t1.v1 - the same as LUHa.v1 but for the historical period from 1700-2005

# LUHa_u2.v1 - the same as LUHa.v1 but also including land-use changes and transitions from/to urban land

# LUHa_t1u2.v1 - the same as LUHa.v1 but for the historical period from 1700-2005 and also including land-use changes and transitions from/to urban land

# The data uses the latest HYDE 3 historical data set for crop, pasture, and urban area 1500-2005 (aggregated from the original 5min grids up to half degree grids). We assume that primary land has priority for wood harvest and shifting cultivation except in Eurasia where secondary land has priority. Wood harvest is performed by country and we have created a new historical wood harvest reconstruction based on FAO data (1961-2005), Zon and Sparhwak (1920), and HYDE 3 population data, in a similar fashion to that in Hurtt et al. 2006. Shifting cultivation is assumed to occur only in some locations of the world which are given in the shifting cultivation map "shiftcult_map_halfdeg.txt" which was taken from J.H. Butler's "Economic Geography" book (1980). We have assumed that the ice and/or water fraction of each gridcell is constant throughout time (see gicew.1700.txt). A grid giving the locations that we assumed to be potential forest is provided in the file fnf_map.txt. For additional information about the algorithms, inputs, and options used in creating the landuse transitions data, please refer to Hurtt et al. 2006 in Global Change Biology for further details or contact us using the email addresses or phone numbers listed above.

# After unpacking the tgz-files, you will find two subdirectories "lu" and "updated_states":

# ** lu: contains annual landuse transitions for each gridcell. The "transitions" are reported as fractions of the gridcell. The harvested biomass is reported in kg of carbon. The reported transitions are:

# cp (transition from crop to pasture)

# pc (transition from pasture to crop)

# pv (transition from pasture to primary land)

# vp (transition from primary land to pasture)

# vc (transition from primary land to crop)

# cv (transition from crop to primary land)

# sc (transition from secondary land to crop)

# cs (transition from crop to secondary land)

# sp (transition from secondary land to pasture)

# ps (transition from pasture land to secondary land)

# vs (transition from primary land to secondary land)

# cu (transition from crop to urban land - for LUHa_u2.v1 and LUHa_t1u2.v1 only)

# pu (transition from pasture to urban land - for LUHa_u2.v1 and LUHa_t1u2.v1 only)

# vu (transition from primary land to urban land - for LUHa_u2.v1 and LUHa_t1u2.v1 only)

# su (transition from secondary land to urban land - for LUHa_u2.v1 and LUHa_t1u2.v1 only)

# uc (transition from urban land to crop - for LUHa_u2.v1 and LUHa_t1u2.v1 only)

# up (transition from urban land to pasture - for LUHa_u2.v1 and LUHa_t1u2.v1 only)

# us (transition from urban land to secondary land - for LUHa_u2.v1 and LUHa_t1u2.v1 only)

# sbh (biomass harvested from mature secondary forested land)

# f_sbh (landuse transition associated with biomass harvested from mature secondary forested land)

# vbh (biomass harvested from primary forested land)

# f_vbh (landuse transition associated with biomass harvested from primary forested land)

# sbh2 (biomass harvested from young secondary forested land)

# f_sbh2 (landuse transition associated with biomass harvested from young secondary forested land)

# vbh2 (biomass harvested from primary non-forested land)

# f_vbh2 (landuse transition associated with biomass harvested from primary non-forested land)

# sbh3 (biomass harvested from secondary non-forested land)

# f_sbh3 (landuse transition associated with biomass harvested from secondary non-forested land)

# ** updated_states: contains maps/grids of various landuse states each year. The landuse states provided are:

# gcrop : fraction of each gridcell in cropland

# gflcp : fraction of each gridcell that transitioned from cropland to pasture

# gflcs : fraction of each gridcell that transitioned from cropland to secondary land

# gflcu : fraction of each gridcell that transitioned from cropland to urban land - for LUHa_u2.v1 and LUHa_t1u2.v1 only

# gflpc : fraction of each gridcell that transitioned from pasture to cropland

# gflps : fraction of each gridcell that transitioned from pasture to secondary land

# gflpu : fraction of each gridcell that transitioned from pasture to urban land - for LUHa_u2.v1 and LUHa_t1u2.v1 only

# gflsc : fraction of each gridcell that transitioned from secondary land to cropland

# gflsp : fraction of each gridcell that transitioned from secondary land to pasture

# gflsu : fraction of each gridcell that transitioned from secondary land to urban land - for LUHa_u2.v1 and LUHa_t1u2.v1 only

# gfluc : fraction of each gridcell that transitioned from urban land to cropland - for LUHa_u2.v1 and LUHa_t1u2.v1 only

# gflup : fraction of each gridcell that transitioned from urban land to pasture - for LUHa_u2.v1 and LUHa_t1u2.v1 only

# gflus : fraction of each gridcell that transitioned from urban land to secondary land - for LUHa_u2.v1 and LUHa_t1u2.v1 only

# gflvc : fraction of each gridcell that transitioned from primary land to cropland

# gflvp : fraction of each gridcell that transitioned from primary land to pasture

# gflvu : fraction of each gridcell that transitioned from primary land to urban land - for LUHa_u2.v1 and LUHa_t1u2.v1 only

# gfsh1 : fraction of each gridcell that had wood harvested from mature secondary forested land

# gfsh2 : fraction of each gridcell that had wood harvested from young secondary forested land

# gfsh3 : fraction of each gridcell that had wood harvested from secondary non-forested land

# gfvh1 : fraction of each gridcell that had wood harvested from primary forested land

# gfvh2 : fraction of each gridcell that had wood harvested from primary non-forested land

# gothr : fraction of each gridcell in primary land

# gpast : fraction of each gridcell in pasture

# gsbh1 : mature secondary forest biomass harvested from each gridcell (in kgC)

# gsbh2 : young secondary forest biomass harvested from each gridcell (in kgC)

# gsbh3 : secondary non-forest biomass harvested from each gridcell (in kgC)

# gsecd : fraction of each gridcell in secondary land

# gssma : mean age of secondary land in each gridcell

# gssmb : mean biomass density of secondary land in each gridcell (in kgC/m^2)

# gsumm : the sum of fractions of each gridcell occupied by cropland, pasture, primary, secondary, urban land, and ice/water (should add to 1 everywhere)

# gurbn : fraction of each gridcell in urban land

# gvbh1 : primary forest biomass harvested from each gridcell (in kgC)

# gvbh2 : primary non-forest biomass harvested from each gridcell (in kgC)
