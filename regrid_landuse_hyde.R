####################################################################
## Function opens original HYDE landuse data and passes it on to 
## function regrid.landuse(), for one single year (time step).
## -----------------------------------------------------------------
regrid_landuse_hyde <- function( year, grid.out, datadir, verbose=FALSE ){ 

  # ## debug	
  # year <- "1600"
  # grid.out <- "halfdeg"
  # verbose <- TRUE

  library(RNetCDF)
  
  myhome <- "/Users/benjaminstocker"

  source('./regrid_library/get.land.avail.R')
  source('./regrid_library/regrid_landuse.R')
  source('./regrid_library/cdf.write.R')
  
  if (verbose){
    print("*******************")
    print(paste("output grid, year ", grid.out, year))
    print("*******************")
  }
  
  ## Define grid of original landuse data.
  ## lon(i), lat(j): longitude and latitude of gridcell center (i,j) 
  ## Define "by hand" because numbers in NetCDF are not very accurate 
  dx <- 1/12
  dy <- 1/12
  lon <- seq(from=-180+dx/2, to=180-dx-dx/2, by=dx) #var.get.nc(nc,dimname_orig_lon)
  lat <- seq(from=-90+dy/2, to=90-dy-dy/2, by=dy) #var.get.nc(nc,dimname_orig_lat)
  # varname_orig <- c( "CROP", "PAST", "BUILT" ) # This is used if builtup land use class is available
  varname_orig <- c( "CROP", "PAST" )
  dimname_orig_time <- "TIME1"
  ncat <- length( varname_orig )
  
  ## Initialise array containing land use areas of all categories in original file(s), no time dimension
  lu <- array(0,c(length(lon),length(lat),ncat)) 
  
  ## Read original file
  fil.orig <- paste( datadir, "/raw/landuse_", year, ".nc", sep="" )
  if (verbose) { print( paste( "reading original landuse data:", fil.orig ) ) }
  nc <- open.nc(fil.orig)  
  time <- var.get.nc( nc, dimname_orig_time, c(1), c(1) )
  for (k in seq(ncat)) {
    lu[,,k] <- var.get.nc(nc,varname_orig[k])
  }
  close.nc(nc)
  
  ## Read land mask file for output
  out.land.avail <- get.land.avail( grid.out, paste( myhome, "/data/landmasks/", sep="" ), verbose=verbose )

  ## Call regridding function
  out.regrid.landuse <- regrid.landuse( lu, out.land.avail$avail, aligned=TRUE, lon=lon, lat=lat, dx=dx, dy=dy, verbose=verbose )
  
  ## Write NetCDF output
  cdf.write(
            out.regrid.landuse$lu.rel[,,1], "crop",
            out.regrid.landuse$lon,
            out.regrid.landuse$lat,
            paste( datadir, "landuse_hyde2014_", grid.out, "_", year, ".cdf", sep="" ),
            time=time,make.tdim=TRUE,
            nvars=2,
            var2=out.regrid.landuse$lu.rel[,,2], varnam2="past"
            )
  print("done.")

}


## /////////////////////////////////////////////////////////////////
## DO THE REGRID
## -----------------------------------------------------------------
myhome <- "/Users/benjaminstocker"
datadir <- paste( myhome, "/data/landuse_data/hyde32_gcp2017", sep="" )
yrs <- read.table( paste( datadir, "/yrlist.txt", sep="" ), col.names=c("year") )$year

for (yr in yrs){
  regrid_landuse_hyde( as.character(yr), "halfdeg", datadir,  verbose=TRUE )
  regrid_landuse_hyde( as.character(yr), "1x1deg",  datadir, verbose=TRUE )
}

