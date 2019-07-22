# ASTER_DEM_from_L1A
Shell code used to run Ames Stereo Pipelines (ASP) on a batch of ASTER L1A images

# Installation
Requirement = Ames Stereo Pipeline (https://ti.arc.nasa.gov/tech/asr/groups/intelligent-robotics/ngt/stereo/). Please follow carefully the ASP installation procedure described in the ASP user guide before trying to run `batch_processing_ASP_github.bash` script. 
The setting file (`stereo.default.MikeWillisInt`) must be installed in the home directory.

# Working example
The attached folder n27_e086.zip needs to be in the same repository as the `batch_processing_ASP_github.bash` script.
Unzip the n27_e086.zip

## Download ASTL1A images
The images can be ordered from https://earthdata.nasa.gov/
This example works with ASTER images images intersecting the SRTM tile N27E086. Download the ASTER scenes of interest and save the .tif (AST_L1A_* .tif) in the repository raw_L1A.

## Process ASTER images
Make the bash script executable and run the command:

    ./batch_processing_ASP_github.bash

If using this script, please cite (REFERENCE TO DUSSAILLANT ET AL TO BE ADDED)
