#!/bin/bash
# script tested on Ubuntu 18.04.3 LTS using Python 3.6.8

# determine environment name
if [ ${#@} == 0 ]; then
    envName=venv;
else
    envName=$1;
fi

# save current work directy as home, this script should be run from project root directory
home=$(pwd)

# if there is no python virtual environment set up, set it up
if [ ! -d "$home/$envName" ]; then
    printf "\ninstalling python 3 virtual environment "$envName" in $home ...\n"
    # install python 3 virtual environment if not already installed
    sudo apt install python3-venv
    # make an instance of python 3 virtual environment with chosen environment name
    python3 -m venv $envName
    printf "sucessfully installed $envName\n"
fi

# activate virtual environment
source ./"$envName"/bin/activate

# print helpful message for when user wants to deactivate
printf "activated $envName.\ntype 'deactivate' to deactivate the virtual environment $envName.\n"
