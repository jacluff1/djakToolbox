# optional packages
# NOTE: changing optional packages here will require updating the optional packages array in install.sh and adding optional package names to ignored directories in .gitignore.
optional=(
    constants
    doepy
    mathpy
    mlpy
    physpy
    plotme
)
# for x in ${@}; do
#     if [[ "${optional[@]}" =~ "$x" ]]; then echo $x in options; fi
# done
# SSH urls for optional packages
optional_SSH=(
    git@github.com:jacluff1/constants.git
    git@github.com:jacluff1/doepy.git
    git@github.com:jacluff1/mathpy.git
    git@github.com:jacluff1/mlpy.git
    git@github.com:jacluff1/physpy.git
    git@github.com:jacluff1/plotme.git
)
# HTTPS urls for optional packages
optional_HTTPS=(
    https://github.com/jacluff1/constants.git
    https://github.com/jacluff1/doepy.git
    https://github.com/jacluff1/mathpy.git
    https://github.com/jacluff1/mlpy.git
    https://github.com/jacluff1/physpy.git
    https://github.com/jacluff1/plotme.git
)

# pull from master
git pull origin master

# take a look at what is installed
installed=$(./BASH/functions/return_lines_from_files.sh .packages.txt)
Ninstalled=${#installed[@]}
if [ $Ninstalled == 0 ]; then
    printf "\nfound no packages installed\n\n";
else
    printf "\nfound installed packages:\n"
    echo ${installed[@]} && echo "";
fi

# take a look at what packages are requested for install
requested=()
for x in ${@}; do requested+=($x); done
Nrequested=${#requested[@]}
if [ $Nrequested == 0 ]; then
    printf "no optional packages requested for install\n\n";
else
    printf "packages requested for install:\n"
    echo ${requested[@]} && echo "";
fi
if [ $Nrequested \> 0 ]; then

    # tak a look at what actually needs install
    have=()
    invalid=()
    need=()
    for ((idx=0; idx<$Nrequested; idx++)); do
        pkg=${requested[$idx]}
        # check if requested package is already installed
        if [[ "${installed[@]}" =~ "$pkg" ]]; then
            have+=($pkg);
        elif [[ "${optional[@]}" =~ "$pkg" ]]; then
            need+=($pkg);
        else
            invalid+=($pkg);
        fi
    done
    Nhave=${#have[@]}
    Ninvalid=${#invalid[@]}
    Nneed=${#need[@]}
    if [ $Nhave \> 0 ]; then
        echo requested packages that are already installed:
        echo ${have[@]} && echo "";
    fi
    if [ $Ninvalid \> 0 ]; then
        echo invalid requests:
        echo ${invalid[@]} && echo "";
    fi
    if [ $Nneed \> 0 ]; then
        echo requested packages that will be installed:
        echo ${need[@]} && echo "";
    fi

    if [ $Nneed \> 0 ]; then

        # take a look at how the djakToolbox was cloned
        url=$(git remote get-url origin)
        if [ $url == git@github.com:jacluff1/djakToolbox.git ]; then
            usingSSH=True
            printf "\nadding optional submodules using ssh urls\n";
        else
            usingSSH=False
            printf "\nadding optional submodules using https urls\n";
        fi

        # add submodules
        for ((idx=0; idx<$Nneed; idx++)); do
            pkg=${need[$idx]}
            # find the index in options associated with selected package
            idx1=$(./BASH/functions/find_index.sh $pkg ${optional[@]})
            if [ $usingSSH == True ]; then
                url1=${optional_SSH[$idx1]};
            else
                url1=${optional_HTTPS[$idx1]};
            fi
            # add submodule
            git submodule add ${url1}
            # make sure djakToolbox doesn't load to master
            echo "$pkg/" >> .gitignore
            # add module to list of installed optional packages
            echo "$pkg" >> .packages.txt
        done

    fi

fi


# update all submodules recursively, initializing them if not done so already
git submodule update --init --recursive

# get a list of all the required packages as well as up-to-date installed packages
# NOTE: changing the required packages here will require changing required array in install.sh
required=(BASH fileme printme)
installed=$(./BASH/functions/return_lines_from_files.sh .packages.txt)
packages=(${required[@]} ${installed[@]})

# from all the packages, make a list of all requirements.txt files
req_files=()
for x in ${packages[@]}; do
    x1=$x/requirements.txt
    if [ -f $x1 ]; then req_files+=($x1); fi;
done
unique=$(./BASH/functions/find_unique_from_files.sh ${req_files[@]})

# re-write the requirements.txt file
if [ -f requirements.txt ]; then rm requirements.txt; fi
touch requirements.txt
for x in ${unique[@]}; do echo $x >> requirements.txt; done

# deactivate any current environment (will print warning if no environment activated; but it won't hurt anything)
deactivate
source envSet.sh

# install/update requirements in main requirements.txt
pip install -U -r requirements.txt --no-cache-dir

# make sure and ignore the changes in the master concerning any changes to submodules; they are updated on their own. once git reset HEAD is used on the submodules here, .gitignore will kick in and make sure they stay out
git reset HEAD .gitmodules
for x in ${packages[@]}; do
    git reset HEAD $x;
done
