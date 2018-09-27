#!/bin/bash

# Idea: You have a pull request open already, but need to squash everything
# You want to squash merge with the same name and force push so you don't close out your pull request
#
# Take your current branch to be squashed, "SomeBranch", and rename it to "SomeBranch2" locally
#
# Take a copy of latest branch to be squash merged into, say "Development"
#
# Rename "Development" to be "SomeBranch" i.e. you now have "SomeBranch" and "SomeBranch2" since you need to force
#  push on top of "SomeBranch" to keep the PR open
#
# Now you have the latest one to squash against and you squash all of "SomeBranch2" into "SomeBranch". 
# Then you fix all your conflicts and when you're liking what you're seeing you can force push it back into the PR

# Steps: 
# 1. Take your branch in PR ("you/Some-Feature-Fix"), rename it to be "you/Some-Feature-Fix2"
# 2. You can push it up if you want to keep a copy just in case if you like
# 3. Now you're good to checkout the branch you need to squash against, lets say "Development" and create
# 		a local copy of our own called whats in PR, "you/Some-Feature-Fix". You can since the "original" is renamed to be 
# 		"you/Some-Feature-Fix2" and its safe since its been pushed if you liked. 
# 4. You now have latest of both branches, so now just squash merge your branch, "you/Some-Feature-Fix2", 
# 		into the new "Development" i.e. "you/Some-Feature-Fix" and now you can force it up on top of your PR's head 
# 		provided your conflicts are fixed and all of that

# Set your IOSDIRPATH as your directory containing your git / project
# The default is dev but change depending on needs
# Usage Example: ./checkout-squash-merge.sh Desktop/my-example-repo you/Some-Feature-Fix
# Usage Example: ./checkout-squash-merge.sh Desktop/ios.steve steve/MDGX-14208-Member_Card


# Important: 
# FIRST find your Directory path relative to your Home Directory


#	Useful Git Commands	
#		Update Submodules Recursively -- git submodule update --recursive
#
#		Create new branch -- git branch your-dir/your-branch-name 
#		Switch to new branch -- git checkout your-dir/your-branch-name
#
#		Create and Switch to new branch -- git checkout -b your-dir/your-branch-name
#
#		Squash Merge -- git merge --squash your-dir/your-branch-name
#

IOSDIRPATH="/Users/${USER}/${1}"

current_date="$(date '+%m-%d-%Y_%H.%M.%S')"
branch_to_be_squash_merged="${2}"
branch_to_resolve_against="${3:-development}"
safe_harbor_branch="${branch_to_be_squash_merged}{${current_date}}"
default_base_git_command="git -c diff.mnemonicprefix=false -c core.quotepath=false -c credential.helper=sourcetree"
CMDCOUNTER=0
	#_arg_array sequence:			 
	 # checkout branch to be squashed
	 # fetch latest
	 # pull latest
	 # checkout branch to be squashed
	 # push safe harbor'd branch before attempting the rest
	 # rename
	 # checkout Development or 'branch-xyz'
	 # pull latest
	 # "new" squashed -- retain name
	 # squash
	 # recursively update submodules just in case
_arg_array=("cd $IOSDIRPATH"\
			"$default_base_git_command checkout $branch_to_be_squash_merged"\ 									
			"$default_base_git_command fetch "origin""\															
			"$default_base_git_command pull "origin" $branch_to_be_squash_merged"\ 								
			"$default_base_git_command checkout -b $safe_harbor_branch"\										
			"$default_base_git_command push -u "origin" $safe_harbor_branch"\							
			"$default_base_git_command branch -m $branch_to_be_squash_merged ${branch_to_be_squash_merged}2"\	
			"$default_base_git_command checkout $branch_to_resolve_against"\									
			"$default_base_git_command pull "origin" $branch_to_resolve_against"\								
			"$default_base_git_command checkout -b $branch_to_be_squash_merged $branch_to_resolve_against"\		
			"$default_base_git_command merge --squash ${branch_to_be_squash_merged}2"\							
			"$default_base_git_command submodule update --recursive"\ 											
			 )	 		 
			  
	if [[ $# -lt 1 ]] || [[ $# -gt 4 ]] ; then
		echo "Usage -------"
		echo "./checkout-squash-merge.sh Desktop/my-example-repo you/Some-Feature-Fix"
		echo "./checkout-squash-merge.sh Desktop/ios.steve steve/MDGX-14208-Member_Card"
		echo "Arg1: iOS Project Directory"
		echo "Arg2: Branch to be squash merged"
		echo "Arg3: Branch to resolve against (Default: Development)"
		exit 1
	else 
			echo "----------Squash Merge Script----------";

		
		for _cmd in "${_arg_array[@]}"; do
			echo $((CMDCOUNTER++)). "$_cmd";
			$_cmd;
			retVal=$?
			if [ $retVal -ne 0 ] ; then 
				exit -1
			fi
		done	

	# deletion
	# git -c diff.mnemonicprefix=false -c core.quotepath=false -c credential.helper=sourcetree branch -D steve/Fix-Error-Handling-SPG 
	# more later..
	fi

exit 0


