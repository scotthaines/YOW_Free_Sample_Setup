#!/bin/bash
# file: install_repository.sh
# created: 2016 01 31, Scott Haines
# edit: 12 Scott Haines
# date: 2016 08 14
# This shell script runs in Git's bash. It installs the YOW Free Sample Git 
# repository by cloning it into the directory named repository in the
# current working directory.
# .
# Run the next line to see commands and expand variables before running them.
# set -x
# The following line is a commented alternate line for debug testing.
# git clone c:/projects/yow_free_sample repository
git clone https://github.com/scotthaines/YOW_Free_Sample.git repository

# Save the clone command's return code.
# We do not want the return code of the 'read' below.
SH_RETURN_CODE=$?

# Switch checkout to the v1.6.0 tag and create a branch there.
cd repository
git checkout -B branch_v1.6.0 v1.6.0

# The following is a commented out pause for debug testing.
# read -p "Pause. Press enter to continue."

# If there is no error creating the repository
if [ $SH_RETURN_CODE -eq 0 ]
then
    # Remove the remote origin to avoid unintended pushes to YOW Free Sample
    # on GitHub.
    cd repository
    git remote remove origin
    cd ..
fi
# Run the next line to view and debug this shell script.
# read -p "Press [Enter] key to start again."
exit $SH_RETURN_CODE
