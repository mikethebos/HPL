#!/bin/bash

#SBATCH --job-name HPL_ParamSweep
#SBATCH --partition general
#SBATCH --time 00:10:00
#SBATCH --nodes 2
#SBATCH --ntasks-per-node 8
#SBATCH --mem 16GB
#SBATCH --array 1-2

# Load the required packages (gcc 11 and HPL)
module load gcc/11.2.0-655h hpl

export OMP_PROC_BIND=TRUE
export OMP_PLACES=cores
export OMP_NUM_THREADS=4

# Set a place to record the results
RESULTS_FILE=$SLURM_SUBMIT_DIR/HPL_results.csv

PARAMS_FILE=$SLURM_SUBMIT_DIR/HPL_params.csv
TEMPLATE_FILE=$SLURM_SUBMIT_DIR/HPL_template.dat

# Check for errors
if test -f $PARAMS_FILE; then
    echo Using parameter file $PARAMS_FILE
else
    echo Error $PARAMS_FILE not found
    exit 1
fi

if test -f $TEMPLATE_FILE; then
    echo Using template file $TEMPLATE_FILE
else
    echo Error $TEMPLATE_FILE not found
    exit 2
fi
    
# Get the Nth line from our parameter file - where N is the array ID
PARAMS=$(head -n $SLURM_ARRAY_TASK_ID $PARAMS_FILE | tail -n 1)
echo Read param line $SLURM_ARRAY_TASK_ID: $PARAMS

# Get the Xth element of that line (comma separated)
NUM_N=$(echo $PARAMS | awk -F"," '{print $1}') # awk: Aho, Weinberger, and Kernighan
echo Read param NUM_N: $NUM_N

N=$(echo $PARAMS | awk -F"," '{print $2}') # awk: Aho, Weinberger, and Kernighan
echo Read param N: $N

NUM_BLOCKS=$(echo $PARAMS | awk -F"," '{print $3}') # awk: Aho, Weinberger, and Kernighan
echo Read param NUM_BLOCKS: $NUM_BLOCKS

BLOCK_SIZE=$(echo $PARAMS | awk -F"," '{print $4}') # awk: Aho, Weinberger, and Kernighan
echo Read param BLOCK_SIZE: $BLOCK_SIZE

PROC_MAP=$(echo $PARAMS | awk -F"," '{print $5}') # awk: Aho, Weinberger, and Kernighan
echo Read param PROC_MAP: $PROC_MAP

NUM_PxQ=$(echo $PARAMS | awk -F"," '{print $6}') # awk: Aho, Weinberger, and Kernighan
echo Read param NUM_PxQ: $NUM_PxQ

P=$(echo $PARAMS | awk -F"," '{print $7}') # awk: Aho, Weinberger, and Kernighan
echo Read param P: $P

Q=$(echo $PARAMS | awk -F"," '{print $8}') # awk: Aho, Weinberger, and Kernighan
echo Read param Q: $Q

THRESH=$(echo $PARAMS | awk -F"," '{print $9}') # awk: Aho, Weinberger, and Kernighan
echo Read param THRESH: $THRESH

NUM_PFACT=$(echo $PARAMS | awk -F"," '{print $10}') # awk: Aho, Weinberger, and Kernighan
echo Read param NUM_PFACT: $NUM_PFACT

PFACT=$(echo $PARAMS | awk -F"," '{print $11}') # awk: Aho, Weinberger, and Kernighan
echo Read param PFACT: $PFACT

NUM_REC_STOP_CRIT=$(echo $PARAMS | awk -F"," '{print $12}') # awk: Aho, Weinberger, and Kernighan
echo Read param NUM_REC_STOP_CRIT: $NUM_REC_STOP_CRIT

NBMIN=$(echo $PARAMS | awk -F"," '{print $13}') # awk: Aho, Weinberger, and Kernighan
echo Read param NBMIN: $NBMIN

NUM_REC_PANELS=$(echo $PARAMS | awk -F"," '{print $14}') # awk: Aho, Weinberger, and Kernighan
echo Read param NUM_REC_PANELS: $NUM_REC_PANELS

NDIV=$(echo $PARAMS | awk -F"," '{print $15}') # awk: Aho, Weinberger, and Kernighan
echo Read param NDIV: $NDIV

NUM_RPFACT=$(echo $PARAMS | awk -F"," '{print $16}') # awk: Aho, Weinberger, and Kernighan
echo Read param NUM_RPFACT: $NUM_RPFACT

RPFACT=$(echo $PARAMS | awk -F"," '{print $17}') # awk: Aho, Weinberger, and Kernighan
echo Read param RPFACT: $RPFACT

NUM_BCAST=$(echo $PARAMS | awk -F"," '{print $18}') # awk: Aho, Weinberger, and Kernighan
echo Read param NUM_BCAST: $NUM_BCAST

BCAST=$(echo $PARAMS | awk -F"," '{print $19}') # awk: Aho, Weinberger, and Kernighan
echo Read param BCAST: $BCAST

NUM_DEPTH=$(echo $PARAMS | awk -F"," '{print $20}') # awk: Aho, Weinberger, and Kernighan
echo Read param NUM_DEPTH: $NUM_DEPTH

DEPTH=$(echo $PARAMS | awk -F"," '{print $21}') # awk: Aho, Weinberger, and Kernighan
echo Read param DEPTH: $DEPTH

SWAP=$(echo $PARAMS | awk -F"," '{print $22}') # awk: Aho, Weinberger, and Kernighan
echo Read param SWAP: $SWAP

SWAP_THRESH=$(echo $PARAMS | awk -F"," '{print $23}') # awk: Aho, Weinberger, and Kernighan
echo Read param SWAP_THRESH: $SWAP_THRESH

L1_T=$(echo $PARAMS | awk -F"," '{print $24}') # awk: Aho, Weinberger, and Kernighan
echo Read param L1_T: $L1_T

U_T=$(echo $PARAMS | awk -F"," '{print $25}') # awk: Aho, Weinberger, and Kernighan
echo Read param U_T: $U_T

EQUIL=$(echo $PARAMS | awk -F"," '{print $26}') # awk: Aho, Weinberger, and Kernighan
echo Read param EQUIL: $EQUIL

MEM_ALIGN=$(echo $PARAMS | awk -F"," '{print $27}') # awk: Aho, Weinberger, and Kernighan
echo Read param MEM_ALIGN: $MEM_ALIGN

# Create a new working directory for each instance of xhpl since it needs it expects it's own HPL.dat
SCRATCH_DIR=/carc/scratch/users/$USER

# Make a temporary directory for our work - we will delete this at the end
TMP_DIR=$(mktemp --directory -p $SCRATCH_DIR)
echo Temp directory: $TMP_DIR

# Make a subdirectory with the SLURM array task id to make debugging easier
TMP_WORKING_DIR=$TMP_DIR/$SLURM_ARRAY_TASK_ID
mkdir -p $TMP_WORKING_DIR
echo Created temporary working directory: $TMP_WORKING_DIR

# Make the new working directory the current directory so xhpl runs in there
cd $TMP_WORKING_DIR
echo Now running in $PWD

# Substitute the parameter value read from the PARAMS file above into the HLP.dat for this instance
# Copy the template file into the temp working directory
cp $TEMPLATE_FILE $TMP_WORKING_DIR/HPL.dat
# Substitute the new parameters
sed -i "s/<NUM_N>/$NUM_N/g" HPL.dat # sed: string edit
sed -i "s/<N>/$N/g" HPL.dat # sed: string edit
sed -i "s/<NUM_BLOCKS>/$NUM_BLOCKS/g" HPL.dat # sed: string edit
sed -i "s/<BLOCK_SIZE>/$BLOCK_SIZE/g" HPL.dat # sed: string edit
sed -i "s/<PROC_MAP>/$PROC_MAP/g" HPL.dat # sed: string edit
sed -i "s/<NUM_PxQ>/$NUM_PxQ/g" HPL.dat # sed: string edit
sed -i "s/<P>/$P/g" HPL.dat # sed: string edit
sed -i "s/<Q>/$Q/g" HPL.dat # sed: string edit
sed -i "s/<THRESH>/$THRESH/g" HPL.dat # sed: string edit
sed -i "s/<NUM_PFACT>/$NUM_PFACT/g" HPL.dat # sed: string edit
sed -i "s/<PFACT>/$PFACT/g" HPL.dat # sed: string edit
sed -i "s/<NUM_REC_STOP_CRIT>/$NUM_REC_STOP_CRIT/g" HPL.dat # sed: string edit
sed -i "s/<NBMIN>/$NBMIN/g" HPL.dat # sed: string edit
sed -i "s/<NUM_REC_PANELS>/$NUM_REC_PANELS/g" HPL.dat # sed: string edit
sed -i "s/<NDIV>/$NDIV/g" HPL.dat # sed: string edit
sed -i "s/<NUM_RPFACT>/$NUM_RPFACT/g" HPL.dat # sed: string edit
sed -i "s/<RPFACT>/$RPFACT/g" HPL.dat # sed: string edit
sed -i "s/<NUM_BCAST>/$NUM_BCAST/g" HPL.dat # sed: string edit
sed -i "s/<BCAST>/$BCAST/g" HPL.dat # sed: string edit
sed -i "s/<NUM_DEPTH>/$NUM_DEPTH/g" HPL.dat # sed: string edit
sed -i "s/<DEPTH>/$DEPTH/g" HPL.dat # sed: string edit
sed -i "s/<SWAP>/$SWAP/g" HPL.dat # sed: string edit
sed -i "s/<SWAP_THRESH>/$SWAP_THRESH/g" HPL.dat # sed: string edit
sed -i "s/<L1_T>/$L1_T/g" HPL.dat # sed: string edit
sed -i "s/<U_T>/$U_T/g" HPL.dat # sed: string edit
sed -i "s/<EQUIL>/$EQUIL/g" HPL.dat # sed: string edit
sed -i "s/<MEM_ALIGN>/$MEM_ALIGN/g" HPL.dat # sed: string edit

echo Running xhpl in $TMP_WORKING_DIR...
srun --mpi=pmi2 xhpl
echo xhpl finished

# The HPL.dat file tells xhpl to write to HPL.out.
# Extract the throughput with grep and awk

# 1. Find the line containing Gflops and print it and the following line
RESULT_HEADER_AND_DATA_LINES=$(grep --after 2 Gflops HPL.out)
echo Results: $RESULT_HEADER_AND_DATA_LINES

# 2. Get just the data line
RESULT_DATA_LINE=$(echo $RESULT_HEADER_AND_DATA_LINES | tail -n 1)
echo Results data: $RESULT_DATA_LINE

# 3. Get the last field in the data line, that's the Gigaflops.
GFLOPS=$(echo $RESULT_DATA_LINE | awk -F" " '{print $NF}')
echo Results Gflops: $GFLOPS 

echo Writing input parameters and gflops to $RESULTS_FILE
echo $NUM_N, $N, $NUM_BLOCKS, $BLOCK_SIZE, $PROC_MAP, $NUM_PxQ, $P, $Q, $THRESH, $NUM_PFACT, $PFACT, $NUM_REC_STOP_CRIT, $NBMIN, $NUM_REC_PANELS, $NDIV, $NUM_RPFACT, $RPFACT, $NUM_BCAST, $BCAST, $NUM_DEPTH, $DEPTH, $SWAP, $SWAP_THRESH, $L1_T, $U_T, $EQUIL, $MEM_ALIGN, $GFLOPS >> $RESULTS_FILE

# Clean up the temporary working directory
rm -r $TMP_DIR
echo Deleted $TMP_DIR
