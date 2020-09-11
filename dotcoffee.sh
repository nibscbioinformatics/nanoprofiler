#!/bin/bash
#SBATCH -p WORK # partition (queue)
#SBATCH -N 1 # number of nodes
#SBATCH -n 1 # number of tasks
#SBATCH -c 32 # number of cpus per task
#SBATCH --mem 240 # memory pool for all cores in Gb
#SBATCH -t 90:30:30 # max time (HH:MM:SS)
#SBATCH -o slurm.%N.%j.out # STDOUT
#SBATCH -e slurm.%N.%j.err # STDERR
#SBATCH --reservation=flescai_4

echo "### START - the job is starting at"
date
starttime=`date +"%s"`
echo
echo "the job is running on the node $SLURM_NODELIST"
echo "job number $SLURM_JOB_ID"
echo "STAT:jobName:$SLURM_JOB_ID"
echo "STAT:exechosts:$SLURM_NODELIST"
echo

filename=$1
module load anaconda/Py2/python2
conda activate Rtbleazar
t_coffee $filename -mode quickaln

echo "####END job finished"
endtime=`date +"%s"`
duration=$((endtime - starttime))
echo "STAT:startTime:$starttime"
echo "STAT:doneTime:$endtime"
echo "STAT:runtime:$duration"
