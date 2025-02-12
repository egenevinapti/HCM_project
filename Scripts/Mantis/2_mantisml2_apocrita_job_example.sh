#!/bin/bash 
#$ -cwd # Set the working directory for the job to the current directory 
#$ -pe smp 5 # Request 1 core 
#$ -l h_rt=72:0:0 # Request 1 hour runtime 
#$ -l h_vmem=10G # Request 1GB RAM 
#$ -m bea 

module load anaconda3 

conda activate mantis-ml-2 

cd ./mantis-ml-release-2 

mantisml2 -d "hypertrophic cardiomyopathy" -o mantisml2_hcm_results 
