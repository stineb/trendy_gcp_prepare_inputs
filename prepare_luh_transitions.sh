#!/bin/bash

mydir=`pwd`
res="halfdeg 1x1deg"

#for iyr in {1500..2004}
for iyr in {2005..2013}
do

    echo "preparing transition files for year ${iyr} ..."
    echo ${iyr}>yrlist.txt

    R CMD BATCH --no-save --no-restore prepare_luh_transitions.R prepare_luh_transitions.out

    for ires in ${res}
    do

        cd /alphadata01/bstocker/data/landuse_data/luh_gcp2014/tmp/   #trans_${ires}_raw_${iyr}

        cp landuse_trans_luh_gcp2014_${ires}_cp_${iyr}.nc landuse_trans_luh_gcp2014_${ires}_${iyr}.nc
        cp landuse_trans_luh_gcp2014_${ires}_sbh_${iyr}.nc harvest_mass_luh_gcp2014_${ires}_${iyr}.nc
        cp landuse_trans_luh_gcp2014_${ires}_f_sbh_${iyr}.nc harvest_area_luh_gcp2014_${ires}_${iyr}.nc

        ncks -A landuse_trans_luh_gcp2014_${ires}_pc_${iyr}.nc landuse_trans_luh_gcp2014_${ires}_${iyr}.nc
        ncks -A landuse_trans_luh_gcp2014_${ires}_pv_${iyr}.nc landuse_trans_luh_gcp2014_${ires}_${iyr}.nc
        ncks -A landuse_trans_luh_gcp2014_${ires}_vp_${iyr}.nc landuse_trans_luh_gcp2014_${ires}_${iyr}.nc
        ncks -A landuse_trans_luh_gcp2014_${ires}_vc_${iyr}.nc landuse_trans_luh_gcp2014_${ires}_${iyr}.nc
        ncks -A landuse_trans_luh_gcp2014_${ires}_cv_${iyr}.nc landuse_trans_luh_gcp2014_${ires}_${iyr}.nc
        ncks -A landuse_trans_luh_gcp2014_${ires}_sc_${iyr}.nc landuse_trans_luh_gcp2014_${ires}_${iyr}.nc
        ncks -A landuse_trans_luh_gcp2014_${ires}_cs_${iyr}.nc landuse_trans_luh_gcp2014_${ires}_${iyr}.nc
        ncks -A landuse_trans_luh_gcp2014_${ires}_sp_${iyr}.nc landuse_trans_luh_gcp2014_${ires}_${iyr}.nc
        ncks -A landuse_trans_luh_gcp2014_${ires}_ps_${iyr}.nc landuse_trans_luh_gcp2014_${ires}_${iyr}.nc
        ncks -A landuse_trans_luh_gcp2014_${ires}_vs_${iyr}.nc landuse_trans_luh_gcp2014_${ires}_${iyr}.nc

        ncks -A landuse_trans_luh_gcp2014_${ires}_vbh_${iyr}.nc harvest_mass_luh_gcp2014_${ires}_${iyr}.nc
        ncks -A landuse_trans_luh_gcp2014_${ires}_sbh2_${iyr}.nc harvest_mass_luh_gcp2014_${ires}_${iyr}.nc
        ncks -A landuse_trans_luh_gcp2014_${ires}_vbh2_${iyr}.nc harvest_mass_luh_gcp2014_${ires}_${iyr}.nc
        ncks -A landuse_trans_luh_gcp2014_${ires}_sbh3_${iyr}.nc harvest_mass_luh_gcp2014_${ires}_${iyr}.nc

        ncks -A landuse_trans_luh_gcp2014_${ires}_f_vbh_${iyr}.nc harvest_area_luh_gcp2014_${ires}_${iyr}.nc
        ncks -A landuse_trans_luh_gcp2014_${ires}_f_sbh2_${iyr}.nc harvest_area_luh_gcp2014_${ires}_${iyr}.nc
        ncks -A landuse_trans_luh_gcp2014_${ires}_f_vbh2_${iyr}.nc harvest_area_luh_gcp2014_${ires}_${iyr}.nc
        ncks -A landuse_trans_luh_gcp2014_${ires}_f_sbh3_${iyr}.nc harvest_area_luh_gcp2014_${ires}_${iyr}.nc

        ncks -O --mk_rec_dmn TIME landuse_trans_luh_gcp2014_${ires}_${iyr}.nc landuse_trans_luh_gcp2014_${ires}_${iyr}.nc
        ncks -O --mk_rec_dmn TIME harvest_mass_luh_gcp2014_${ires}_${iyr}.nc harvest_mass_luh_gcp2014_${ires}_${iyr}.nc
        ncks -O --mk_rec_dmn TIME harvest_area_luh_gcp2014_${ires}_${iyr}.nc harvest_area_luh_gcp2014_${ires}_${iyr}.nc

        mv landuse_trans_luh_gcp2014_${ires}_${iyr}.nc ../tmp2/
        mv harvest_mass_luh_gcp2014_${ires}_${iyr}.nc ../tmp2/
        mv harvest_area_luh_gcp2014_${ires}_${iyr}.nc ../tmp2/

        cd ${mydir}

    done

done

cd /alphadata01/bstocker/data/landuse_data/luh_gcp2014/tmp2/

# ncrcat -O landuse_trans_luh_gcp2014_halfdeg_????_halfdeg.nc landuse_trans_luh_gcp2014_halfdeg_1500-2004.cdf
# ncrcat -O landuse_trans_luh_gcp2014_1x1deg_????_1x1deg.nc landuse_trans_luh_gcp2014_1x1deg_1500-2004.cdf

# ncrcat -O harvest_mass_luh_gcp2014_halfdeg_????_halfdeg.nc harvest_mass_luh_gcp2014_halfdeg_1500-2004.cdf
# ncrcat -O harvest_mass_luh_gcp2014_1x1deg_????_1x1deg.nc harvest_mass_luh_gcp2014_1x1deg_1500-2004.cdf

# ncrcat -O harvest_area_luh_gcp2014_halfdeg_????_halfdeg.nc harvest_area_luh_gcp2014_halfdeg_1500-2004.cdf
# ncrcat -O harvest_area_luh_gcp2014_1x1deg_????_1x1deg.nc harvest_area_luh_gcp2014_1x1deg_1500-2004.cdf

# mv landuse_trans_luh_gcp2014_????_1500-2004.cdf harvest_mass_luh_gcp2014_????_1500-2004.cdf harvest_area_luh_gcp2014_????_1500-2004.cdf ..

ncrcat -O landuse_trans_luh_gcp2014_halfdeg_????_halfdeg.nc landuse_trans_luh_gcp2014_halfdeg_1500-2013.cdf
ncrcat -O landuse_trans_luh_gcp2014_1x1deg_????_1x1deg.nc landuse_trans_luh_gcp2014_1x1deg_1500-2013.cdf

ncrcat -O harvest_mass_luh_gcp2014_halfdeg_????_halfdeg.nc harvest_mass_luh_gcp2014_halfdeg_1500-2013.cdf
ncrcat -O harvest_mass_luh_gcp2014_1x1deg_????_1x1deg.nc harvest_mass_luh_gcp2014_1x1deg_1500-2013.cdf

ncrcat -O harvest_area_luh_gcp2014_halfdeg_????_halfdeg.nc harvest_area_luh_gcp2014_halfdeg_1500-2013.cdf
ncrcat -O harvest_area_luh_gcp2014_1x1deg_????_1x1deg.nc harvest_area_luh_gcp2014_1x1deg_1500-2013.cdf

mv landuse_trans_luh_gcp2014_*_1500-2013.cdf harvest_mass_luh_gcp2014_*_1500-2013.cdf harvest_area_luh_gcp2014_*_1500-2013.cdf ..

cd ${mydir}