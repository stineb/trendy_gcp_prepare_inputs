#!/bin/bash

## get temperature data (only netcdf) from this location:
## https://www.dropbox.com/sh/3evepccb9465oz0/BpRtL50y_t/data.1307101324
## (see mail from Stephen Sitch, 08/02/2013 01:18 PM)

# mkdir /alphadata01/bstocker/data/cru/cru_ts_3.23
cd /alphadata01/bstocker/data/cru/cru_ts_3.23

gunzip cru_ts3.23.1901.2014.pre.dat.nc.gz
gunzip cru_ts3.23.1901.2014.tmp.dat.nc.gz
gunzip cru_ts3.23.1901.2014.wet.dat.nc.gz
gunzip cru_ts3.23.1901.2014.cld.dat.nc.gz

cd /alphadata01/bstocker/trendy_gcp2014