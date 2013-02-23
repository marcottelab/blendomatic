#!/bin/bash
#$ -o $SLURM_JOB_NAME.o$SLURM_JOB_ID
#$ --mail-user=borgeson@utexas.edu
#$ --mail-type=END                # Email at End of job
#$ -p normal     # on stampede always normal queue
set -x                  # Echo commands, use "set echo" with csh

