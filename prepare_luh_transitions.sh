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

        # mkdir /alphadata01/bstocker/data/landuse_data/luh_gcp2014/tmp/trans_${ires}_raw_${iyr}

        # mv /alphadata01/bstocker/data/landuse_data/luh_gcp2014/tmp/landuse_trans_hurtt_historical_*_${iyr}_${ires}.nc trans_${ires}_raw_${iyr}

        cd /alphadata01/bstocker/data/landuse_data/luh_gcp2014/tmp/   #trans_${ires}_raw_${iyr}

        #rm landuse_trans_hurtt_historical_${iyr}_${ires}.nc
        #rm harvest_mass_hurtt_historical_${iyr}_${ires}.nc
        #rm harvest_area_hurtt_historical_${iyr}_${ires}.nc

        cp landuse_trans_hurtt_historical_cp_${iyr}_${ires}.nc landuse_trans_hurtt_historical_${iyr}_${ires}.nc
        cp landuse_trans_hurtt_historical_sbh_${iyr}_${ires}.nc harvest_mass_hurtt_historical_${iyr}_${ires}.nc
        cp landuse_trans_hurtt_historical_f_sbh_${iyr}_${ires}.nc harvest_area_hurtt_historical_${iyr}_${ires}.nc

        ncks -A landuse_trans_hurtt_historical_pc_${iyr}_${ires}.nc landuse_trans_hurtt_historical_${iyr}_${ires}.nc
        ncks -A landuse_trans_hurtt_historical_pv_${iyr}_${ires}.nc landuse_trans_hurtt_historical_${iyr}_${ires}.nc
        ncks -A landuse_trans_hurtt_historical_vp_${iyr}_${ires}.nc landuse_trans_hurtt_historical_${iyr}_${ires}.nc
        ncks -A landuse_trans_hurtt_historical_vc_${iyr}_${ires}.nc landuse_trans_hurtt_historical_${iyr}_${ires}.nc
        ncks -A landuse_trans_hurtt_historical_cv_${iyr}_${ires}.nc landuse_trans_hurtt_historical_${iyr}_${ires}.nc
        ncks -A landuse_trans_hurtt_historical_sc_${iyr}_${ires}.nc landuse_trans_hurtt_historical_${iyr}_${ires}.nc
        ncks -A landuse_trans_hurtt_historical_cs_${iyr}_${ires}.nc landuse_trans_hurtt_historical_${iyr}_${ires}.nc
        ncks -A landuse_trans_hurtt_historical_sp_${iyr}_${ires}.nc landuse_trans_hurtt_historical_${iyr}_${ires}.nc
        ncks -A landuse_trans_hurtt_historical_ps_${iyr}_${ires}.nc landuse_trans_hurtt_historical_${iyr}_${ires}.nc
        ncks -A landuse_trans_hurtt_historical_vs_${iyr}_${ires}.nc landuse_trans_hurtt_historical_${iyr}_${ires}.nc

        ncks -A landuse_trans_hurtt_historical_vbh_${iyr}_${ires}.nc harvest_mass_hurtt_historical_${iyr}_${ires}.nc
        ncks -A landuse_trans_hurtt_historical_sbh2_${iyr}_${ires}.nc harvest_mass_hurtt_historical_${iyr}_${ires}.nc
        ncks -A landuse_trans_hurtt_historical_vbh2_${iyr}_${ires}.nc harvest_mass_hurtt_historical_${iyr}_${ires}.nc
        ncks -A landuse_trans_hurtt_historical_sbh3_${iyr}_${ires}.nc harvest_mass_hurtt_historical_${iyr}_${ires}.nc

        ncks -A landuse_trans_hurtt_historical_f_vbh_${iyr}_${ires}.nc harvest_area_hurtt_historical_${iyr}_${ires}.nc
        ncks -A landuse_trans_hurtt_historical_f_sbh2_${iyr}_${ires}.nc harvest_area_hurtt_historical_${iyr}_${ires}.nc
        ncks -A landuse_trans_hurtt_historical_f_vbh2_${iyr}_${ires}.nc harvest_area_hurtt_historical_${iyr}_${ires}.nc
        ncks -A landuse_trans_hurtt_historical_f_sbh3_${iyr}_${ires}.nc harvest_area_hurtt_historical_${iyr}_${ires}.nc

        ncks -O --mk_rec_dmn TIME landuse_trans_hurtt_historical_${iyr}_${ires}.nc landuse_trans_hurtt_historical_${iyr}_${ires}.nc
        ncks -O --mk_rec_dmn TIME harvest_mass_hurtt_historical_${iyr}_${ires}.nc harvest_mass_hurtt_historical_${iyr}_${ires}.nc
        ncks -O --mk_rec_dmn TIME harvest_area_hurtt_historical_${iyr}_${ires}.nc harvest_area_hurtt_historical_${iyr}_${ires}.nc

        mv landuse_trans_hurtt_historical_${iyr}_${ires}.nc ../tmp2/
        mv harvest_mass_hurtt_historical_${iyr}_${ires}.nc ../tmp2/
        mv harvest_area_hurtt_historical_${iyr}_${ires}.nc ../tmp2/

        # rm landuse_trans_hurtt_historical_*.nc

        cd ${mydir}

        # rm -rf tmp  #trans_${ires}_raw_${iyr}

    done

done

cd /alphadata01/bstocker/data/landuse_data/luh_gcp2014/tmp2/

# ncrcat -O landuse_trans_hurtt_historical_????_halfdeg.nc landuse_trans_luh_gcp2014_halfdeg_1500-2004.cdf
# ncrcat -O landuse_trans_hurtt_historical_????_1x1deg.nc landuse_trans_luh_gcp2014_1x1deg_1500-2004.cdf

# ncrcat -O harvest_mass_hurtt_historical_????_halfdeg.nc harvest_mass_luh_gcp2014_halfdeg_1500-2004.cdf
# ncrcat -O harvest_mass_hurtt_historical_????_1x1deg.nc harvest_mass_luh_gcp2014_1x1deg_1500-2004.cdf

# ncrcat -O harvest_area_hurtt_historical_????_halfdeg.nc harvest_area_luh_gcp2014_halfdeg_1500-2004.cdf
# ncrcat -O harvest_area_hurtt_historical_????_1x1deg.nc harvest_area_luh_gcp2014_1x1deg_1500-2004.cdf

# mv landuse_trans_luh_gcp2014_????_1500-2004.cdf harvest_mass_luh_gcp2014_????_1500-2004.cdf harvest_area_luh_gcp2014_????_1500-2004.cdf ..

ncrcat -O landuse_trans_hurtt_historical_????_halfdeg.nc landuse_trans_luh_gcp2014_halfdeg_1500-2013.cdf
ncrcat -O landuse_trans_hurtt_historical_????_1x1deg.nc landuse_trans_luh_gcp2014_1x1deg_1500-2013.cdf

ncrcat -O harvest_mass_hurtt_historical_????_halfdeg.nc harvest_mass_luh_gcp2014_halfdeg_1500-2013.cdf
ncrcat -O harvest_mass_hurtt_historical_????_1x1deg.nc harvest_mass_luh_gcp2014_1x1deg_1500-2013.cdf

ncrcat -O harvest_area_hurtt_historical_????_halfdeg.nc harvest_area_luh_gcp2014_halfdeg_1500-2013.cdf
ncrcat -O harvest_area_hurtt_historical_????_1x1deg.nc harvest_area_luh_gcp2014_1x1deg_1500-2013.cdf

mv landuse_trans_luh_gcp2014_*_1500-2013.cdf harvest_mass_luh_gcp2014_*_1500-2013.cdf harvest_area_luh_gcp2014_*_1500-2013.cdf ..

cd ${mydir}