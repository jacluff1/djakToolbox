# NOTE: this script is to give 755 permissions to all scripts. If there is a .git/cofig file in the directory where this script is run, will give permissions through git; othwerwise, will use chmod

# get all shell scripts from parent directory on down
scripts=$(find -iname "*.sh")
printf "\nfound scripts:\n${scripts[@]}\n\n"

# for all the shell scripts found
for xx in ${scripts[@]}; do
    # skip current file
    if [[ "give_permissions" == *"$xx"* ]]; then continue; fi
    # skip files in env folder
    if [[ "djakToolbox" == *"$xx"* ]]; then continue; fi
    # add permissions via chmod
    chmod 755 $xx
    printf "\nadded 755 permissions to $xx via chmod\n";
    # if script is in git repo
    if [ -f .git/config ]; then
        # add permissions via git
        git update-index --add --chmod=+x $xx
        printf "added permissions to $xx via git\n";
    fi
done
