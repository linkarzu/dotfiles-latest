#!/bin/bash

# Test script to test running an executable file

boldGreen="\033[1;32m"
boldYellow="\033[1;33m"
boldRed="\033[1;31m"
boldPurple="\033[1;35m"
boldBlue="\033[1;34m"
noColor="\033[0m"

INSTALL_RELEASE_NAME=test-release
INSTALL_APP_NAMESPACE=kube-system

echo
echo "Beginning of script"
echo
echo "ls command below"
ls
echo
echo "Showing after ls"

echo
echo -e "${boldRed}First prompt${noColor}"
read -p "Do you want to deploy $INSTALL_RELEASE_NAME in the '$INSTALL_APP_NAMESPACE' namespace? Enter 'yes' to continue: " userInput
if [[ $userInput != "yes" ]]; then
	echo "Re-run the script and enter 'yes' to continue."
	exit 1
fi

echo
echo -e "${boldYellow}Second prompt${noColor}"
read -p "Do you want to deploy $INSTALL_RELEASE_NAME in the '$INSTALL_APP_NAMESPACE' namespace? Enter 'yes' to continue: " userInput
if [[ $userInput != "yes" ]]; then
	echo "Re-run the script and enter 'yes' to continue."
	exit 1
fi

echo
echo -e "${boldGreen}Third prompt${noColor}"
read -p "Do you want to deploy $INSTALL_RELEASE_NAME in the '$INSTALL_APP_NAMESPACE' namespace? Enter 'yes' to continue: " userInput
if [[ $userInput != "yes" ]]; then
	echo "Re-run the script and enter 'yes' to continue."
	exit 1
fi
