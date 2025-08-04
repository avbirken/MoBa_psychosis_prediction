#!/bin/bash
# Job name:
#SBATCH --job-name=diagInfo
#
# Project:
#SBATCH --account=p697_norment
#
# Wall clock limit:
#SBATCH --time=18:00:00
#
# Max memory usage:
#SBATCH --mem-per-cpu=3G
#
# Number of cores:
#SBATCH --cpus-per-task=10

## Set up job environment:
module purge   # clear any inherited modules
module load MATLAB/2023a
set -o errexit # exit on errors

## Do some work:
cd /ess/p697/cluster/users/parekh/2024-11-11_predictionPsychosis_VB/scripts
matlab -nodisplay -nosplash -nodesktop < prepData_diagInfo.m