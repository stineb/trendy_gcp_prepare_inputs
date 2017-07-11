# !/bin/bash

# # ///////////////////////////////////////////////////////////////////////////////////////
# # Downloads HYDE2013 files used for GCP runs and converts to NetCDF using Ferret and NCO.
# # beni@climate.unibe.ch
# # ---------------------------------------------------------------------------------------
# mydir=`pwd`
# scen="hyde32_baseline"
# era="BC AD"
# myhome="/Users/benjaminstocker"

# ## Loop over the three (best,lower,upper)
# for iscen in $scen
# do
#     echo "*********************************************************************"
#     echo "SCENARIO ${iscen}"
#     echo "---------------------------------------------------------------------"
            
#     ## Create directory to store files
#     dirnam="${myhome}/data/landuse_data/hyde32_gcp2017"
#     if [ ! -e ${dirnam}/raw/asc/zip ]
#       then
#       echo "creating subdirectory structure ${dirnam}/raw/asc"
#       mkdir -p ${dirnam}/raw/asc/zip
#     fi
    
#     ## Define host address
#     host="ftp://ftp.pbl.nl/hyde/tmp/2017/zip/"

#     ## Get list of files on FTP server
#     lftp -f get_filelist_hyde32_gcp2017.lftp > ${mydir}/filelist_hyde32_gcp2017.txt

#     cd ${dirnam}

#     ## Loop over files in list
#     if [ -f yrlist.txt ]
#     then
#         rm yrlist.txt
#     fi

#     for jdx in $era
#     do
#         echo "/////////"
#         echo "$jdx"
#         echo "---------"
#         if [ $jdx == "BC" ]
#         then
#             let mult=-1
#         else
#             let mult=1            
#         fi

#         ## get only files with pattern '_lu' in file name
#         list=`cat ${mydir}/filelist_hyde32_gcp2017.txt | grep _lu | grep $jdx`  ## landuse data
#         # echo $list
        
#         for idx in $list
#         do

#             echo "/////////////////////////////////////////////////////////////////////"
#             echo "downloading ${host}${idx} ..."
#             echo "---------------------------------------------------------------------"
#             wget ${host}${idx}

#             # Unzip the file
#             unzip ${idx}

#             mv ${idx} raw/asc/zip
#             mv *.asc raw/asc

#             ## Get year from file name
#             if [ $jdx == "BC" ]
#             then
#                 let pos=`echo $idx | awk '{print index( $0, "BC" )}'`
#             else
#                 let pos=`echo $idx | awk '{print index( $0, "AD" )}'`
#             fi

#             ## new:
#             let pos=${pos}-3
#             let yrabs=${idx:2:${pos}}
#             let yr=${mult}*${yrabs}
#             echo "yr: $yr"
#             if [ $jdx == "BC" ]
#             then
#                 argyr="${yrabs}BC"
#             else
#                 argyr="${yrabs}AD"
#             fi
#             echo "argyr: $argyr"
#             yr_string=`printf "%06i\n" ${yr}` 
#             echo "${yr_string}"
#             echo ${yr}>>yrlist.txt

#             ## Convert ascii to NetCDF (single annual fields)
#             echo "converting ascii to netcdf for year $yr ..."
# /usr/local/ferret/bin/ferret <<EOF    
# go "${mydir}/asc2cdf_hyde.jnl" ${yr} ${argyr} ${dirnam}
# quit
# EOF
#             rm raw/tmp*.nc

#         done
        
#     done

#     cd $mydir
   
# done

# Regrid using the R function (loop over scenarios inside R script!!!)
R CMD BATCH --no-save --no-restore regrid_landuse_hyde.R regrid_landuse_hyde.out

# scen="baseline"
# res="halfdeg"
# mydir=`pwd`

# ## Combine annual fields along time axis

# for iscen in $scen
# do

#     ## cd to data directory
#     dirnam="${myhome}/data/landuse_data/hyde32_gcp2017"
#     cd $dirnam

#     for ires in ${res}
#     do
    
#         # ## Make 'time' a record dimension in all multi-decadal files
#         echo "concatenate files along time axis..."
#         list=`ls -tr landuse_hyde32_gcp2017_${ires}*.cdf`
#         k=0
#         for idx in $list
#         do
#             echo $idx
#             let k=k+1
#             tmpn=tmp_`printf "%02d" $k`.nc
#             echo "cmd: ncks -O --mk_rec_dmn TIME ${idx} ${tmpn}"
#             ncks -O --mk_rec_dmn TIME ${idx} ${tmpn}
#         done
        
#         ## Concatenate all multi-decadal files to single file for historical period
#         ncrcat -O tmp*.nc landuse_hyde32_gcp2017_${ires}.cdf
#         #rm tmp*.nc

#     done

#     cd $mydir

# done

# #modify attributes
# #./prepare_landuse_hyde32.sh



# /////////////////////////// old ///////////////////////////
# #!/bin/bash

# ## First, download zipped archive files that contain (cropland1600AD.asc, grazing1600AD.asc, irri1600AD.asc, pasture1600AD.asc, rangeland1600AD.asc)

# cd ${myhome}/data/landuse_data/hyde3_2/zipfiles/


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



# list=`ls *_lu.zip`
# k=0
# for idx in $list
# do
  
#   filnam=$idx
#   echo "file name: $filnam"

#   ## get year and write it into file (to be read by R later)
#   let yr=${filnam:0:4}
#   echo $yr>yrlist.txt

#   ## Inflate zipped archive (=> cropland1600AD.asc, grazing1600AD.asc, irri1600AD.asc, pasture1600AD.asc, rangeland1600AD.asc)
#   unzip $idx

#   # mkdir raw

#   ## Convert ascii to NetCDF (single annual fields)
#   echo "converting ASCII to NetCDF"
# /usr/local/ferret/bin/ferret <<EOF    
# go "${myhome}/trendy_gcp2014/asc2cdf_hyde.jnl" ${yr}
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

#   # Regrid using the R function (loop over scenarios inside R script!!!)
#   echo "Regridding for year $yr"
#   R CMD BATCH --no-save --no-restore ${myhome}/trendy_gcp2014/regrid_landuse_hyde.R ${myhome}/trendy_gcp2014/regrid_landuse_hyde.out

#   ## delte high-resolution NetcDF file
#   rm raw/landuse_${yr}.nc

#   regridfil_halfdeg="landuse_hyde2014_halfdeg_${yr}.cdf"
#   regridfil_1x1deg="landuse_hyde2014_1x1deg_${yr}.cdf"

#   ## Make 'time' a record dimension in NetCDF file
#   let k=k+1

#   tmpn_halfdeg=tmp_`printf "%02d" $k`_halfdeg.nc
#   tmpn_1x1deg=tmp_`printf "%02d" $k`_1x1deg.nc

#   ncks -O --mk_rec_dmn TIME ${regridfil_halfdeg} ${tmpn_halfdeg}
#   ncks -O --mk_rec_dmn TIME ${regridfil_1x1deg} ${tmpn_1x1deg}

# done

# ## Concatenate all multi-decadal files to single file for historical period
# ncrcat -O tmp_??_halfdeg.nc landuse_hyde_gcp2014_halfdeg_1600-2014.cdf
# ncrcat -O tmp_??_1x1deg.nc landuse_hyde_gcp2014_1x1deg_1600-2014.cdf

# mv landuse_hyde_gcp2014_halfdeg_1600-2014.cdf ..
# mv landuse_hyde_gcp2014_1x1deg_1600-2014.cdf ..

# # ## delete temporary files 
# # rm tmp*.nc
# # rm landuse_hyde2014_halfdeg_????.cdf
# # rm landuse_hyde2014_1x1deg_????.cdf

# cd ${myhome}/trendy_gcp2014


# # ## modify attributes
# # ./prepare_landuse_hyde2013.sh

