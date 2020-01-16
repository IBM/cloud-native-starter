#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

while true; do
    read -p "Do you wish to cleanup this project = delete everything?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

echo Cleanup
source ${root_folder}/os4-scripts/login.sh
oc delete project cloud-native-starter
oc delete project kafka
oc delete project postgres


