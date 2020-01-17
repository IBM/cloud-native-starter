#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

source ${root_folder}/iks-scripts/delete-kafka.sh
source ${root_folder}/iks-scripts/delete-postgres.sh
source ${root_folder}/iks-scripts/delete-all-serices.sh



