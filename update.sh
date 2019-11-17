# pull from master
git pull origin master

# create empty array to hold installed packages
installed=()
# open packages.txt and collect all packages

# add submodules for each input argument not already in packages

# update all submodules recursively, initializing them if not done so already
git submodule update --init --recursive

# go into each submodule, if there is a requirements.txt make sure all its requirements are main requirements.txt

# install/update requirements in main requirements.txt
pip install -U -r requirements.txt
