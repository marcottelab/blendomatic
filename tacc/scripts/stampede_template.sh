#!/bin/bash
#SBATCH --mail-user=borgeson@utexas.edu
#SBATCH --mail-type=END                # Email at End of job
#SBATCH -p normal     # on stampede always normal queue
set -x                  # Echo commands, use "set echo" with csh
