# NOTE: this script collects all unique values in a given array.

# put user input into array
vals=()
for x in ${@}; do vals+=($x); done

# find unique values in array
unique=()
for x in ${vals[@]}; do
    if ! [[ "${unique[@]}" =~ "$x" ]]; then unique+=($x); fi;
done

# output the value
echo ${unique[@]}
