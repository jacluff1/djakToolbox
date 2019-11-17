# package options
required=(BASH fileme printme)
optional=(constants doepy mathpy mlpy physpy plotme)
full=(${optional[@]} barebones)

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

echo ${packages[@]}

# create empty file to hold package names
if [ ! -f packages.txt ]; then touch packages.txt; fi

# run update with selected packages
# ./update.sh ${packages[@]}

# use the set environment script from BASH
# ./BASH/setEnv.sh djakToolbox
