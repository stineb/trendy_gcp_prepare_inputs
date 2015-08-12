#!/bin/bash

## First, download zipped archive files that contain (cropland1600AD.asc, grazing1600AD.asc, irri1600AD.asc, pasture1600AD.asc, rangeland1600AD.asc)

cd /alphadata01/bstocker/data/landuse_data/hyde3_2/zipfiles/


# ## Inflate zipped archive (=> popc_200AD.asc     popd_200AD.asc     rurc_200AD.asc     uopp_200AD.asc     urbc_200AD.asc)
# list=`ls *_pop.zip`
# for idx in $list
# do
  
#   filnam=$idx
#   echo "file name: $filnam"

#   ## Inflate zipped archive (=> cropland1600AD.asc, grazing1600AD.asc, irri1600AD.asc, pasture1600AD.asc, rangeland1600AD.asc)
#   unzip $idx

#   # delete files I don't need
#   rm popc*.asc popd*.asc rurc*.asc urbc*.asc

# done



## unzip files
list=`ls *_lu.zip`
let k=0
for idx in $list
do
  
  filnam=$idx
  echo "file name: $filnam"

  ## get year and write it into file (to be read by R later)
  let yr=${filnam:0:4}
  echo $yr>yrlist.txt

#   ## Inflate zipped archive (=> cropland1600AD.asc, grazing1600AD.asc, irri1600AD.asc, pasture1600AD.asc, rangeland1600AD.asc)
#   unzip $idx

#   # mkdir raw

#   ## Convert ascii to NetCDF (single annual fields)
#   echo "converting ASCII to NetCDF"
# /usr/local/ferret/bin/ferret <<EOF    
# go "/alphadata01/bstocker/trendy_gcp2014/asc2cdf_hyde.jnl" ${yr}
# quit
# EOF

#   ## delete ASCII files 
#   rm cropland${yr}AD.asc
#   rm grazing${yr}AD.asc
#   rm irri${yr}AD.asc
#   rm pasture${yr}AD.asc
#   rm rangeland${yr}AD.asc

#   ## delete temporary NetCDF file
#   rm tmp_crop_${yr}.nc
#   rm tmp_gras_${yr}.nc
#   rm tmp_built_${yr}.nc

  # Regrid using the R function (loop over scenarios inside R script!!!)
  echo "Regridding for year $yr"
  R CMD BATCH --no-save --no-restore /alphadata01/bstocker/trendy_gcp2014/regrid_landuse_hyde.R /alphadata01/bstocker/trendy_gcp2014/regrid_landuse_hyde.out

  ## delte high-resolution NetcDF file
  rm raw/landuse_${yr}.nc

  regridfil_halfdeg="landuse_hyde2014_halfdeg_${yr}.cdf"
  regridfil_1x1deg="landuse_hyde2014_1x1deg_${yr}.cdf"

  ## Make 'time' a record dimension in NetCDF file
  let k=k+1

  tmpn_halfdeg=tmp_`printf "%02d" $k`_halfdeg.nc
  tmpn_1x1deg=tmp_`printf "%02d" $k`_1x1deg.nc

  ncks -O --mk_rec_dmn TIME ${regridfil_halfdeg} ${tmpn_halfdeg}
  ncks -O --mk_rec_dmn TIME ${regridfil_1x1deg} ${tmpn_1x1deg}

done

## Concatenate all multi-decadal files to single file for historical period
ncrcat -O tmp_??_halfdeg.nc landuse_hyde_gcp2014_halfdeg_1600-2014.cdf
ncrcat -O tmp_??_1x1deg.nc landuse_hyde_gcp2014_1x1deg_1600-2014.cdf

mv landuse_hyde_gcp2014_halfdeg_1600-2014.cdf ..
mv landuse_hyde_gcp2014_1x1deg_1600-2014.cdf ..

# ## delete temporary files 
# rm tmp*.nc
# rm landuse_hyde2014_halfdeg_????.cdf
# rm landuse_hyde2014_1x1deg_????.cdf

cd /alphadata01/bstocker/trendy_gcp2014


# ## modify attributes
# ./prepare_landuse_hyde2013.sh

