# required pacakages
# NOTE: changing values here requires changing values in update.sh
# TODO: have required packages, required_SSH, and required _HTTPS in txt files found in a config folder
required=(
    BASH
    fileme
    printme
)
# SSH urls for required packages
required_SSH=(
    git@github.com:jacluff1/BASH.git
    git@github.com:jacluff1/fileme.git
    git@github.com:jacluff1/printme.git
)
# HTTPS urls for required packages
reequired_HTTPS=(
    https://github.com/jacluff1/BASH.git
    https://github.com/jacluff1/fileme.git
    https://github.com/jacluff1/printme.git
)
# number of required packages
Nrequired=${#required[@]}

# optional packages
# NOTE: changing options here requires changing correlary options, options_SSH and options_HTTPS in update.sh as well as the ignored package directories in .gitignore.
optional=(constants doepy mathpy mlpy physpy plotme)

# all available options for user argument input
full=(${optional[@]} barebones)

# get the remote origin url
url=$(git remote get-url origin)
if [ $url == git@github.com:jacluff1/djakToolbox.git ]; then
    usingSSH=True
    printf "\nadding required submodules using ssh urls\n"
    # add required sub modules using SSH
    for ((idx=0; idx<$Nrequired; idx++)); do
        printf "adding ${required[$idx]}\n"
        git submodule add ${required_SSH[$idx]}
    done;
else
    usingSSH=False
    printf "\nadding required submodules using https urls\n"
    # add required sub modules using HTTPS
    for ((idx=0; idx<$Nrequired; idx++)); do
        printf "adding ${required[$idx]}\n"
        git submodule add ${reequired_HTTPS[$idx]}
    done;
fi

# recursively initialize submodules
git submodule update --init --recursive

# if there is no input
if [ ${#@} == 0 ]; then
    # use the required packages and all the optional packages
    packages=(${required[@]} ${optional[@]});
else
    # check that the input is valid
    # make empty array to hold invalid entries
    invalid=()
    # loop through all optional inputs
    for x in ${@}; do
        # if the input isn't allowed add it to the invalid array
        if ! [[ "${full[@]}" =~ "$x" ]]; then
            invalid+=($x);
        fi
    done
    # if there are any invalid entries, terminate installation with helpful message.
    nInvalid=${#invalid[@]}
    if [ $nInvalid \> 0 ]; then
        echo THERE WERE $nInvalid INVALDID PACKAGE OPTIONS ENTERED!
        echo INVALID CHOICES ENTERED: ${invalid[@]}
        echo VALID OPTIONS: ${full[@]}
        exit 1
    # if barebones was supplied as an optional argument
    elif [[ "${@^^}" =~ "BAREBONES" ]]; then
        # only use required packages
        packages=${required[@]};
    else
        # use required packages and all supplied optional packages
        packages=(${required[@]} ${@});
    fi;
fi

# create empty file to hold package names
if [ ! -f .packages.txt ]; then touch .packages.txt; fi

# run update with selected packages
./update.sh ${packages[@]}
#
# use the set environment script from BASH
./BASH/setEnv.sh djakToolbox
