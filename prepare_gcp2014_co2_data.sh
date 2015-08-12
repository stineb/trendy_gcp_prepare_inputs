#!/bin/bash

awk '{printf "%16.6f    %f \n",$1,$2}' global_co2_ann_1500_2014.out >cCO2_historical_1500-2014_GCP2014.dat 

# cp cCO2_historical_1860-2013_GCP2013.dat /alphadata01/bstocker/lpx/trunk/start/input
# cp cCO2_historical_1860-2013_GCP2013.dat /alphadata01/bstocker/lpx/gcp2012/start/input
# cp cCO2_historical_1860-2013_GCP2013.dat /alphadata01/bstocker/lpx/gcp2013/start/input

