#!/bin/bash
#SBATCH -p WORK # partition (queue)
#SBATCH -N 1 # number of nodes
#SBATCH -n 1 # number of tasks
#SBATCH -c 10 # number of cpus per task
#SBATCH --mem 60 # memory pool for all cores in Gb
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
cd /usr/share/sequencing/projects/317/alignments/
shortname=`echo $filename | sed 's/.aa.fasta//g'`
echo $shortname
/home/AD/tbleazar/CD-HIT/cdhit/cd-hit -i $filename -o ${shortname}.aa.clusters -c 0.9 -T 9 -M 50000


echo "####END job finished"
endtime=`date +"%s"`
duration=$((endtime - starttime))
echo "STAT:startTime:$starttime"
echo "STAT:doneTime:$endtime"
echo "STAT:runtime:$duration"
