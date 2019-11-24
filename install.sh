
# TODO: find a way to package this into a callable function and update BASH/functions/read_lines.sh
# declare needed arrays
required=()
required_SSH=()
required_HTTPS=()
optional=()
installed=()
# fill in arrays by reading in lines
while IFS= read -r line; do required+=($line); done < config/required.txt
while IFS= read -r line; do required_SSH+=($line); done < config/required_SSH.txt
while IFS= read -r line; do required_HTTPS+=($line); done < config/required_HTTPS.txt
while IFS= read -r line; do optional+=($line); done < config/optional.txt
while IFS= read -r line; do installed+=($line); done < config/installed.txt

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
for ((idx=0; idx<${#required[@]}; idx++)); do
    if ! [[ "${installed[@]}" =~ "${required[$idx]}" ]]; then
        if [ $usingSSH == True ]; then
            printf "\nadding ${required[$idx]} using ssh urls\n"
            url1=${required_SSH[$idx]};
        else
            printf "\nadding required submodules using https urls\n"
            url1=${required_HTTPS[$idx]};
        fi
        # clone repository
        git clone ${url}
        # add submodule to installed list
        echo "${required[$idx]}" >> config/installed.txt;
    else
        echo "${required[$idx]} already installed; skipping";
    fi
done

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

# run update with selected packages
./update.sh "first commit, install" ${packages[@]}

# use the set environment script from BASH
./BASH/envSet.sh djakToolbox
