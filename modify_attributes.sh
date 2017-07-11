#!/bin/bash

scen="dummy"
myhome="/Users/benjaminstocker"

for iscen in $scen
do

    ## move to subdirectory
    dirnam="${myhome}/data/landuse_data/hyde32_gcp2017"
    cd ${dirnam}

    list=`ls landuse_hyde32_gcp2017_*.cdf`

    for idx in $list
    do
        ncatted -a units,crop,a,c,'area fraction' $idx
        ncatted -a units,past,a,c,'area fraction' $idx
        
        ncatted -a long_name,crop,a,c,'area fraction of gridcell covered by croplands' $idx
        ncatted -a long_name,past,a,c,'area fraction of gridcell covered by pastures' $idx
        
        ncatted -a history,global,o,c,"Original HYDE land use data provided by K. Klein-Goldewijk on a spatial grid of 5 arcmin. Re-gridded by B. Stocker using scripts available on https://github.com/stineb/trendy_gcp_prepare_inputs." $idx
        ncatted -a title,global,o,c,"HYDE 3.2 for GCP2017" $idx
    
    done
done