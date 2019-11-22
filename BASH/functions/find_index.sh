# NOTE: this functions is to return the index of a value that matches a value in an array

# return -1 if no match found
index=-1

A=()
for x in ${@:2}; do A+=($x); done

for idx in ${!A[@]}; do
    if [ "${A[$idx]}" == "$1" ]; then index=$idx; fi
done
echo $index
