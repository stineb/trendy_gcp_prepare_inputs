####################################################################
## Function opens original luh landuse data and passes it on to function regrid.landuse()
## -----------------------------------------------------------------
regrid.landuse.luh <- function( year, grid.out, verbose=FALSE ){ 

  ## ## debug	
  ## year <- "1500"
  ## grid.out <- "1x1deg"
  ## verbose <- TRUE

  library(RNetCDF)
  source('/alphadata01/bstocker/lpx/lpxtools/trunk/landuse/get.land.avail.R')
  source('/alphadata01/bstocker/lpx/lpxtools/trunk/landuse/regrid_landuse.R')
  source('/alphadata01/bstocker/lpx/lpxtools/trunk/landuse/cdf.write.R')
  
  if (verbose){
    print("*******************")
    print(paste("output grid, year ", grid.out, as.character(year)))
    print("*******************")
  }
  
  ## Read land mask file for output
  out.land.avail.1x1deg <- get.land.avail( "1x1deg", verbose=TRUE )

  ## Define grid of original landuse data.
  ## lon(i), lat(j): longitude and latitude of gridcell center (i,j) 
  ## Define "by hand" because numbers in NetCDF are not very accurate 
  dx <- 0.5
  dy <- 0.5
  lon <- seq(from=-180+dx/2, to=180-dx/2, by=dx) #var.get.nc(nc,dimname_orig_lon)
  lat <- seq(from=-90+dy/2, to=90-dy/2, by=dy) #var.get.nc(nc,dimname_orig_lat)
  varname_orig <- c( "CROP", "PAST", "SECD" )
  dimname_orig_time <- "TIME"
  ncat <- length( varname_orig )

  # print(paste("ncat",ncat))
  
  ## Initialise array containing land use areas of all categories in original file(s)
  lu <- array(0,c(length(lon),length(lat),ncat)) 

  # print(paste("dim lu",dim(lu)))
  
  ## Read original file
  if (verbose) {print("reading original landuse data...")}
  fil.orig <- paste(
                    "/alphadata01/bstocker/data/landuse_data/luh_gcp2014/tmp/tmp_landuse_halfdeg_",as.character(year),".nc",
                    sep=""
                    )
  # print(paste("opening file",fil.orig))
  nc <- open.nc(fil.orig)  
  time <- var.get.nc(nc,dimname_orig_time,c(1),c(1))
  for (k in seq(ncat)) {
    lu[,,k] <- var.get.nc(nc,varname_orig[k])
  }
  close.nc(nc)
  
  ## Regrid to 1x1deg
  out.regrid.landuse <- regrid.landuse( lu, out.land.avail.1x1deg$avail, fraction=TRUE, aligned=TRUE, lon=lon, lat=lat, verbose=TRUE )
  tmp <- apply( out.regrid.landuse$lu.rel[,,1:3], c(1,2), FUN=sum )
  prim.1x1deg <- out.land.avail.1x1deg$avail - tmp

  print(paste("dim lu.rel",dim(out.regrid.landuse$lu.rel)))

  ## Write NetCDF output
  cdf.write(
            out.regrid.landuse$lu.rel[,,1], "CROP",
            out.regrid.landuse$lon,
            out.regrid.landuse$lat,
            paste("/alphadata01/bstocker/data/landuse_data/luh_gcp2014/tmp/tmp_landuse_1x1deg_",year,".nc",sep=""),
            time=year, make.tdim=TRUE, make.zdim=FALSE, 
            nvars=4,
            var2=out.regrid.landuse$lu.rel[,,2], varnam2="PAST",
            var3=out.regrid.landuse$lu.rel[,,3], varnam3="SECD",
            var4=prim.1x1deg, varnam4="PRIM", verbose=TRUE
            )

  print("done.")

}


## /////////////////////////////////////////////////////////////////
## DO THE REGRID
## -----------------------------------------------------------------
yrs <- read.table( "/alphadata01/bstocker/data/landuse_data/luh_gcp2014/tmp/yrlist.txt", col.names=c("year") )
yr  <- yrs$year

regrid.landuse.luh( yr, "1x1deg", verbose=TRUE )

