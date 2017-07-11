# !/bin/bash

##///////////////////////////////////////////////////////////////////////////////////////
## Download HYDE files used for TRENDY/GCP runs and convert files to NetCDF using Ferret.
##---------------------------------------------------------------------------------------
mydir=`pwd`
scen="hyde32_baseline"
era="BC AD"
myhome="/Users/benjaminstocker"

## Loop over the three (best,lower,upper)
for iscen in $scen
do
    echo "*********************************************************************"
    echo "SCENARIO ${iscen}"
    echo "---------------------------------------------------------------------"
            
    ## Create directory to store files
    dirnam="${myhome}/data/landuse_data/hyde32_gcp2017"
    if [ ! -e ${dirnam}/raw/asc/zip ]
      then
      echo "creating subdirectory structure ${dirnam}/raw/asc"
      mkdir -p ${dirnam}/raw/asc/zip
    fi
    
    ## Define host address
    host="ftp://ftp.pbl.nl/hyde/tmp/2017/zip/"

    ## Get list of files on FTP server
    lftp -f get_filelist_hyde32_gcp2017.lftp > ${mydir}/filelist_hyde32_gcp2017.txt

    cd ${dirnam}

    ## Loop over files in list
    if [ -f yrlist.txt ]
    then
        rm yrlist.txt
    fi

    if [ -f fyrlist.txt ]
    then
        rm fyrlist.txt
    fi

    for jdx in $era
    do
        echo "/////////"
        echo "$jdx"
        echo "---------"
        if [ $jdx == "BC" ]
        then
            let mult=-1
        else
            let mult=1            
        fi

        ## get only files with pattern '_lu' in file name
        list=`cat ${mydir}/filelist_hyde32_gcp2017.txt | grep _lu | grep $jdx`  ## landuse data
        # echo $list
        
        for idx in $list
        do

            echo "/////////////////////////////////////////////////////////////////////"
            echo "downloading ${host}${idx} ..."
            echo "---------------------------------------------------------------------"
            wget ${host}${idx}

            # Unzip the file
            unzip ${idx}

            mv ${idx} raw/asc/zip
            mv *.asc raw/asc

            ## Get year from file name
            if [ $jdx == "BC" ]
            then
                let pos=`echo $idx | awk '{print index( $0, "BC" )}'`
            else
                let pos=`echo $idx | awk '{print index( $0, "AD" )}'`
            fi

            ## new:
            let pos=${pos}-3
            let yrabs=${idx:2:${pos}}
            let yr=${mult}*${yrabs}
            echo "yr: $yr"
            if [ $jdx == "BC" ]
            then
                argyr="${yrabs}BC"
            else
                argyr="${yrabs}AD"
            fi
            echo "argyr: $argyr"
            yr_string=`printf "%06i\n" ${yr}` 
            echo "${yr_string}"
            echo ${yr}>>yrlist.txt
            echo ${yr_string}>>fyrlist.txt

            ## Convert ascii to NetCDF (single annual fields)
            echo "converting ascii to netcdf for year $yr ..."
/usr/local/ferret/bin/ferret <<EOF    
go "${mydir}/asc2cdf_hyde.jnl" ${yr} ${argyr} ${dirnam}
quit
EOF
            rm raw/tmp*.nc

        done
        
    done

    cd $mydir
   
done



##///////////////////////////////////////////////////////////////////////////////////////
## Regrid annual 5 arcmin resolution files to 1.0 and 0.5 degrees
##---------------------------------------------------------------------------------------
# Regrid using the R function (loop over scenarios inside R script!!!)
R CMD BATCH --no-save --no-restore regrid_landuse_hyde.R regrid_landuse_hyde.out


##///////////////////////////////////////////////////////////////////////////////////////
## Combine annual files along the time axis (using NCO)
##---------------------------------------------------------------------------------------
scen="baseline"
res="halfdeg 1x1deg"
mydir=`pwd`
myhome="/Users/benjaminstocker"

## Combine annual fields along time axis

for iscen in $scen
do

    ## cd to data directory
    dirnam="${myhome}/data/landuse_data/hyde32_gcp2017"
    cd $dirnam

    for ires in ${res}
    do
    
        # ## Make 'time' a record dimension in all multi-decadal files
        echo "concatenate files along time axis..."
        list=`ls annual/landuse_hyde32_gcp2017_${ires}*.cdf`
        k=0
        for idx in $list
        do
            echo $idx
            let k=k+1
            tmpn=annual/tmp_`printf "%02d" $k`.nc
            echo "cmd: ncks -O --mk_rec_dmn TIME ${idx} ${tmpn}"
            ncks -O --mk_rec_dmn TIME ${idx} ${tmpn}
        done
        
        ## Concatenate all multi-decadal files to single file for historical period
        ncrcat -O annual/tmp*.nc landuse_hyde32_gcp2017_${ires}.cdf
        #rm tmp*.nc

    done

    cd $mydir

done


#///////////////////////////////////////////////////////////////////////////////////////
# Modify NetCDF attributes
#---------------------------------------------------------------------------------------
./modify_attributes.sh


