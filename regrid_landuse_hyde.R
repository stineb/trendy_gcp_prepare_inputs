####################################################################
## Function opens original HYDE landuse data and passes it on to function regrid.landuse()
## -----------------------------------------------------------------
regrid.landuse.hyde <- function( year, grid.out, verbose=FALSE ){ 

  # ## debug	
  # year <- "1600"
  # grid.out <- "halfdeg"
  # verbose <- TRUE

  library(RNetCDF)
  source('/alphadata01/bstocker/lpx/lpxtools/trunk/landuse/get.land.avail.R')
  source('/alphadata01/bstocker/lpx/lpxtools/trunk/landuse/regrid_landuse.R')
  source('/alphadata01/bstocker/lpx/lpxtools/trunk/landuse/cdf.write.R')
  
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
  varname_orig <- c( "CROP", "PAST", "BUILT" )
  dimname_orig_time <- "TIME"
  ncat <- length( varname_orig )
  
  ## Initialise array containing land use areas of all categories in original file(s)
  lu <- array(0,c(length(lon),length(lat),ncat)) 
  
  ## Read original file
  if (verbose) {print("reading original landuse data...")}
  fil.orig <- paste(
                    "/alphadata01/bstocker/data/landuse_data/hyde3_2/zipfiles/raw/landuse_",year,".nc",
                    sep=""
                    )
  nc <- open.nc(fil.orig)  
  time <- var.get.nc(nc,dimname_orig_time,c(1),c(1))
  for (k in seq(ncat)) {
    lu[,,k] <- var.get.nc(nc,varname_orig[k])
  }
  close.nc(nc)
  
  ## Read land mask file for output
  out.land.avail <- get.land.avail( grid.out, verbose=verbose )

  ## Call regridding function
  out.regrid.landuse <- regrid.landuse( lu, out.land.avail$avail, aligned=TRUE, lon=lon, lat=lat, dx=dx, dy=dy, verbose=verbose )
  
  ## Write NetCDF output
  cdf.write(
            out.regrid.landuse$lu.rel[,,1], "crop",
            out.regrid.landuse$lon,
            out.regrid.landuse$lat,
            paste("/alphadata01/bstocker/data/landuse_data/hyde3_2/zipfiles/landuse_hyde2014_",grid.out,"_",year,".cdf",sep=""),
            time=time,make.tdim=TRUE,
            nvars=3,
            var2=out.regrid.landuse$lu.rel[,,2], varnam2="past",
            var3=out.regrid.landuse$lu.rel[,,3], varnam3="built"
            )
  print("done.")

}


## /////////////////////////////////////////////////////////////////
## DO THE REGRID
## -----------------------------------------------------------------
yrs <- read.table( "/alphadata01/bstocker/data/landuse_data/hyde3_2/zipfiles/yrlist.txt", col.names=c("year") )
yr  <- yrs$year

regrid.landuse.hyde( as.character(yr), "halfdeg", verbose=TRUE )
regrid.landuse.hyde( as.character(yr), "1x1deg", verbose=TRUE )
