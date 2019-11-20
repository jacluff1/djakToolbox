# quick function to read lines from text
read_lines () {
    local array=()
    while IFS= read -r line; do
        array+=($line)
    done < $1
    echo ${array[@]}
}

# load package data from config/
required=$(read_lines config/required.txt)
required_SSH=$(read_lines config/required_SSH.txt)
required_HTTPS=$(read_lines config/required_HTTPS.txt)
optional=$(read_lines config/optional.txt)
installed=$(read_lines config/installed.txt)

# number of required packages
Nrequired=${#required[@]}

# all available options for user argument input
full=(${optional[@]} barebones)

# determine whether using SSH or HTTPS cloning method
url=$(git remote get-url origin)
if [ $url == git@github.com:jacluff1/djakToolbox.git ]; then
    usingSSH=True;
else
    usingSSH=False;
fi

# add required submodules
for ((idx=0; idx<$Nrequired; idx++)); do
    if ! [[ "${installed[@]}" =~ "${required[$idx]}" ]]; then
        if [ $usingSSH == True ]; then
            printf "\nadding ${required[$idx]} using ssh urls\n"
            url1=${required_SSH[$idx]};
        else
            printf "\nadding required submodules using https urls\n"
            url1=${required_HTTPS[$idx]};
        fi
        # add submodule
        git submodule add $url1
        # add submodule to installed list
        echo "${required[$idx]}" >> config/installed.txt;
    else
        echo "${required[$idx]} already installed; skipping"
done

# recursively initialize submodules
git submodule update --init --recursive

# ensure that all newly added packages are ignored; after this step, .gitignore will kick in.
git reset HEAD .gitmodules
for x in ${required[@]}; do git reset HEAD $x; done

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
