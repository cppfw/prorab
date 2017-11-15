#!/bin/bash

#we want exit immediately if any command fails and we want error in piped commands to be preserved
set -eo pipefail

while [[ $# > 0 ]] ; do
	case $1 in
		--help)
			echo "Print 'running test' message to the console."
			echo ""
			echo "Usage:"
			echo -e "\t$(basename $0) \"test name\""
			echo ""
			echo "Examples:"
			echo -e "\t$(basename $0) \"test1\""
			exit 0
			;;
		*)
			testName="$testName $1"
			shift
			;;
	esac
done

[ -z "$testName" ] && echo "Error: no test name supplied" && exit 1;

echo -e "\\033[0;31mRunning test\\033[0m$testName..."
