# HYDE land use data processing for TRENDY / GCP

Author: Benjamin Stocker, Jul. 2017, b.stocker@creaf.uab.cat

This repository contains scripts to process HYDE land use data for TRENDY simulations, used for the Global Carbon Project (GCP). HYDE data is provided by K. Klein-Goldewijk on a spatial grid of 5 arcmin (1/12 degrees) for each variable (pasture, cropland) separately and in ascii format. This repository contains scripts to convert this data to NetCDF and re-grid fields to a 0.5 and a 1.0 degrees spatial grid (land mask from LUH). Re-gridding conserves the total area under cropland use and the total area under pasture use.

**Important to note**:
HYDE 3.2 provides variables `grazing = pasture + rangeland`, where pasture and rangeland areas are distinguished by management and use intensity. The files produced here contain the variable `past` which is equal to `grazing` in the HYDE 3.2 dataset (see `asc2cdf_hyde.jnl`). 

## Usage
The following command executes all steps in sequence:
```sh
./prepare_landuse_hyde.sh
```
Steps are:

1. Get file list on FTP server where original HYDE data is available from.
2. Download each file (for each variable and time step)
3. Unzip each file 
4. Convert ascii files to NetCDF
5. Regrid files to 0.5 and 1.0 degrees grids. This combines pasture and cropland data into a single file
6. Combine time steps into single file
7. Modify NetCDF attributes

## Requirements
Scripts are in bash, R, and Ferret, and use NCO commands and the lftp command. R uses the RNetCDF library. 

Important: Modify all paths in scripts for your application and note some commented-out lines that need to be un-commented for preparing historical LUH files (as opposed to "extension").
You are free to use these scripts - open source! Please clone this repository and share your additions/modifications through github.
