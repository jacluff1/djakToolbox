# NOTE: this script collects all lines from any number of files provided. its intended purpose is to read simple lists saved in a file where each value is on a new line

vals=()
for x in ${@}; do
    while read -r line; do
        vals+=($line)
    done < $x
done

echo ${vals[@]}

# for x in ${@}; do
#     while IFS= read -r line; do
#         echo "$line"
#     done <<< $(cat $x);
# done

# # make array to hold values
# vals=()
# A=()
# for x in ${@}; do A+=($x); done
#
# # for each file in user input file names
# for x in ${A[@]}; do
#     while read -r line; do
#         vals+=($line)
#     done < $x;
# done
#
# # output the value
# echo ${vals[@]}
