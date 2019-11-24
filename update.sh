
# TODO: find a way to package this into a callable function and update BASH/functions/read_lines.sh
# declare optional packages and urls
installed=()
optional=()
optional_HTTPS=()
optional_SSH=()
required=()
# fill in the arrays
while IFS= read -r line; do installed+=($line); done < config/installed.txt
while IFS= read -r line; do optional+=($line); done < config/optional.txt
while IFS= read -r line; do optional_HTTPS+=($line); done < config/optional_HTTPS.txt
while IFS= read -r line; do optional_SSH+=($line); done < config/optional_SSH.txt
while IFS= read -r line; do required+=($line); done < config/required.txt

# update repository and sub-repositories
djakHome=$(pwd)
./BASH/git_update.sh
for pkg in ${installed[@]}; do
    cd $pkg
    $djakHome/BASH/git_update.sh
    cd $djakHome;
done

Ninstalled=${#installed[@]}
if [ $Ninstalled == 0 ]; then
    printf "\nfound no packages installed\n\n";
else
    printf "\nfound installed packages:\n"
    echo ${installed[@]} && echo "";
fi

# take a look at what packages are requested for install
requested=()
for x in ${@:2}; do requested+=($x); done
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
    # make sure required packages are installed
    for x in ${required[@]}; do
        if ! [[ "${required[@]}" =~ "$x" ]]; then need+=($x); fi
    done
    # make sure requested packages are installed
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
            # clone repo
            git clone ${url1}
            # add newly installed package to installed list
            echo "$pkg" >> config/installed.txt
        done

    fi

fi

# get a list of all up-to-date installed packages
installed=()
while IFS= read -r line; do insalled+=($line); done < config/installed.txt

# from all the packages, make a list of all requirements.txt files
req_files=()
for x in ${installed[@]}; do
    x1=$x/requirements.txt
    if [ -f $x1 ]; then req_files+=($x1); fi;
done
unique=$(./BASH/functions/find_unique.sh ${req_files[@]})

# re-write the requirements.txt file
printf "\nUPDATING requirements.txt\n"
if [ -f requirements.txt ]; then rm requirements.txt; fi
touch requirements.txt
for x in ${unique[@]}; do echo $x >> requirements.txt; done

# run the set environment script
source envSet.sh

#install/update requirements in main requirements.txt
printf "\nUPDATING PYTHON PACKAGES\n"
pip install -U -r requirements.txt --no-cache-dir
