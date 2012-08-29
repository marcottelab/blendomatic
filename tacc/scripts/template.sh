#!/bin/bash
#$ -V                   # Inherit the submission environment
#$ -cwd                 # Start job in submission directory
#$ -j y                 # Combine stderr and stdout
#$ -o $JOB_NAME.o$JOB_ID
#$ -M borgeson@utexas.edu
#$ -m e                # Email at End of job
#$ -P data
set -x                  # Echo commands, use "set echo" with csh

