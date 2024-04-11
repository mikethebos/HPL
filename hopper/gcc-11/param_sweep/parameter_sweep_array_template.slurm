#!/bin/bash

#SBATCH --job-name HPL_ParamSweep
#SBATCH --partition general
#SBATCH --time 00:10:00
#SBATCH --nodes <PARAM_NNODES>
#SBATCH --ntasks-per-node <PARAM_NTASKSPERNODE>
#SBATCH --cpus-per-task <PARAM_CPUSPERTASK>
#SBATCH --mem 16GB
#SBATCH --array <SWEEP>

# Load the required packages (gcc 11 and HPL)
module load gcc/11.2.0-655h hpl

export OMP_PROC_BIND=TRUE
export OMP_PLACES=cores

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
PARAMS=$(head -n $SLURM_ARRAY_TASK_ID $PARAMS_FILE | tail -n 1 | tr ',' ' ')
echo Read param line $SLURM_ARRAY_TASK_ID: $PARAMS

read -r NUM_N N NUM_BLOCKS BLOCK_SIZE PROC_MAP NUM_PxQ P Q THRESH NUM_PFACT \
    PFACT NUM_REC_STOP_CRIT NBMIN NUM_REC_PANELS NDIV NUM_RPFACT RPFACT \
    NUM_BCAST BCAST NUM_DEPTH DEPTH SWAP SWAP_THRESH L1_T U_T EQUIL MEM_ALIGN <<<$(echo $PARAMS)

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

# Fill out template file
echo "HPLinpack benchmark input file
Innovative Computing Laboratory, University of Tennessee
HPL.out             # output file name (if any)
1                   # device out (6=stdout,7=stderr,file)
$NUM_N              # of problems sizes (N)
$N	                # Ns Appropriate for 16GB RAM
$NUM_BLOCKS         # of NBs
$BLOCK_SIZE	        # NBs
$PROC_MAP           # PMAP process mapping (0=Row-,1=Column-major)
$NUM_PxQ            # of process grids (P x Q)
$P                  # Ps
$Q                  # Qs
$THRESH             # threshold
$NUM_PFACT          # of panel fact
$PFACT              # PFACTs (0=left, 1=Crout, 2=Right)
$NUM_REC_STOP_CRIT  # of recursive stopping criterium
$NBMIN              # NBMINs (>= 1)
$NUM_REC_PANELS     # of panels in recursion
$NDIV               # NDIVs
$NUM_RPFACT         # of recursive panel fact.
$RPFACT             # RFACTs (0=left, 1=Crout, 2=Right)
$NUM_BCAST          # of broadcast
$BCAST              # BCASTs (0=1rg,1=1rM,2=2rg,3=2rM,4=Lng,5=LnM)
$NUM_DEPTH          # of lookahead depth
$DEPTH              # DEPTHs (>=0)
$SWAP               # SWAP (0=bin-exch,1=long,2=mix)
$SWAP_THRESH        # swapping threshold
$L1_T               # L1 in (0=transposed,1=no-transposed) form
$U_T                # U in (0=transposed,1=no-transposed) form
$EQUIL              # Equilibration (0=no,1=yes)
$MEM_ALIGN          # memory alignment in double (> 0)" > HPL.dat

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

echo Running xhpl in $TMP_WORKING_DIR...
srun --nodes $SLURM_NNODES --ntasks-per-node $SLURM_NTASKS_PER_NODE --cpus-per-task $OMP_NUM_THREADS --mpi=pmi2 xhpl
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
echo $NUM_N, $N, $NUM_BLOCKS, $BLOCK_SIZE, $PROC_MAP, $NUM_PxQ, $P, $Q, $THRESH, $NUM_PFACT, $PFACT, $NUM_REC_STOP_CRIT, $NBMIN, $NUM_REC_PANELS, $NDIV, $NUM_RPFACT, $RPFACT, $NUM_BCAST, $BCAST, $NUM_DEPTH, $DEPTH, $SWAP, $SWAP_THRESH, $L1_T, $U_T, $EQUIL, $MEM_ALIGN, $SLURM_NNODES, $SLURM_NTASKS_PER_NODE, $OMP_NUM_THREADS, $GFLOPS >> $RESULTS_FILE

# Clean up the temporary working directory
rm -r $TMP_DIR
echo Deleted $TMP_DIR
