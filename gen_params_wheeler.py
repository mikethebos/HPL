#!/usr/bin/env python3

import os
import sys
from itertools import product

NUM_N = (1,) # of problems sizes (N)
N = (29232, 43848, 58464, 73080) # Ns # Appropriate for 16GB RAM
NUM_BLOCKS = (1,) # of NBs
BLOCK_SIZE = (32, 64, 96, 128, 232, 512) # NBs
PROC_MAP = (0,) # PMAP process mapping (0=Row-,1=Column-major)
NUM_PxQ = (1,) # of process grids (P x Q)
P = (2, 4, 6, 8, 12, 16) # Ps
Q = (6, 12, 24, 30, 48, 72) # Qs
THRESH = (16.0,) # threshold
NUM_PFACT = (1,) # of panel fact
PFACT = (2,) # PFACTs (0=left, 1=Crout, 2=Right)
NUM_REC_STOP_CRIT = (1,) # of recursive stopping criterium
NBMIN = (4,) # NBMINs (= 1)
NUM_REC_PANELS = (1,) # of panels in recursion
NDIV = (2,) # NDIVs
NUM_RPFACT = (1,) # of recursive panel fact.
RPFACT = (2,) # RFACTs (0=left, 1=Crout, 2=Right)
NUM_BCAST = (1,) # of broadcast
BCAST = (2,) # BCASTs (0=1rg,1=1rM,2=2rg,3=2rM,4=Lng,5=LnM)
NUM_DEPTH = (1,) # of lookahead depth
DEPTH = (1,) # DEPTHs (=0)
SWAP = (1,) # SWAP (0=bin-exch,1=long,2=mix)
SWAP_THRESH = (64,) # swapping threshold
L1_T = (0,) # L1 in (0=transposed,1=no-transposed) form
U_T = (0,) # U in (0=transposed,1=no-transposed) form
EQUIL = (1,) # Equilibration (0=no,1=yes)
MEM_ALIGN = (8,) # memory alignment in double ( 0)
SLURM_NNODES = (48,)
SLURM_NTASKS_PER_NODE = (1, 8)
OMP_THREADS = (1, 4, 8)

all_combinations = list(product(NUM_N, N, NUM_BLOCKS, BLOCK_SIZE, PROC_MAP, NUM_PxQ, P, Q,
                        THRESH, NUM_PFACT, PFACT, NUM_REC_STOP_CRIT, NBMIN,
                        NUM_REC_PANELS, NDIV, NUM_RPFACT, RPFACT, NUM_BCAST, BCAST,
                        NUM_DEPTH, DEPTH, SWAP, SWAP_THRESH, L1_T, U_T, EQUIL,
                        MEM_ALIGN))

def csv():
    for args in all_combinations:
        print(','.join(str(x) for x in args))
        
def slurm(input_path):
    with open(input_path, 'r') as f:
        input = f.read()
        
    dir = os.path.dirname(os.path.normpath(input_path))
    if dir == "":
        dir = "."
    elif dir == "/":
        dir = "/."
    
    for args in product(SLURM_NNODES, SLURM_NTASKS_PER_NODE, OMP_THREADS):
        # wheeler
        if args[1] * args[2] > 8:
            continue
        
        SWEEP = ""
        for ind, params in enumerate(all_combinations):
            p = params[6]
            q = params[7]
            if p * q == args[0] * args[1]:
                SWEEP += str(ind + 1) + ","
                
        if len(SWEEP) > 0 and SWEEP[-1] == ",":
            SWEEP = SWEEP[:-1]
            
        if len(SWEEP) == 0:
            continue
        
        new_input = input.replace("<PARAM_NNODES>", str(args[0])) \
                              .replace("<PARAM_NTASKSPERNODE>", str(args[1])) \
                              .replace("<PARAM_CPUSPERTASK>", str(args[2])) \
                              .replace("<SWEEP>", SWEEP)

        save_path = dir + "/parameter_sweep_array_nnodes" + str(args[0]) \
                                                   + "_ntaskspernode" + str(args[1]) \
                                                   + "_cpuspertask" + str(args[2]) \
                                                   + ".slurm"
        
        with open(save_path, 'w') as f:
            f.write(new_input)
        
if __name__ == "__main__":
    if sys.argv[1] == "csv":
        csv()
    elif sys.argv[1] == "slurm":
        slurm(sys.argv[2])
    else:
        print("csv will print HPL_params.csv to stdout")
        print("slurm <path to parameter_sweep_array_template.slurm> will create slurm scripts for " + 
              "nodes, ntasks per node, omp threads sweep in same dir")

# LOG OF SWEEPS:

# Wheeler:

# Sweep 1: Ran:
# (32 nodes, 1 tasks per node, 4 cpus per task)
# (32 nodes, 8 tasks per node, 1 cpus per task)
# (16 nodes, 1 tasks per node, 4 cpus per task)
# (16 nodes, 8 tasks per node, 1 cpus per task)
# (8 nodes, 1 tasks per node, 4 cpus per task)
# (8 nodes, 8 tasks per node, 1 cpus per task)
# (4 nodes, 1 tasks per node, 4 cpus per task)
# (4 nodes, 8 tasks per node, 1 cpus per task)
# (1 nodes, 1 tasks per node, 4 cpus per task)
# (1 nodes, 8 tasks per node, 1 cpus per task)
# ----
# NUM_N = (1,) # of problems sizes (N)
# N = (3000, 6000, 11000, 14616) # Ns # Appropriate for 16GB RAM
# NUM_BLOCKS = (1,) # of NBs
# BLOCK_SIZE = (128, 232, 512, 768) # NBs
# PROC_MAP = (0,) # PMAP process mapping (0=Row-,1=Column-major)
# NUM_PxQ = (1,) # of process grids (P x Q)
# P = (1, 4, 8) # Ps
# Q = (1, 4, 8, 16, 32, 48) # Qs
# THRESH = (16.0,) # threshold
# NUM_PFACT = (1,) # of panel fact
# PFACT = (2,) # PFACTs (0=left, 1=Crout, 2=Right)
# NUM_REC_STOP_CRIT = (1,) # of recursive stopping criterium
# NBMIN = (4,) # NBMINs (= 1)
# NUM_REC_PANELS = (1,) # of panels in recursion
# NDIV = (2,) # NDIVs
# NUM_RPFACT = (1,) # of recursive panel fact.
# RPFACT = (2,) # RFACTs (0=left, 1=Crout, 2=Right)
# NUM_BCAST = (1,) # of broadcast
# BCAST = (2,) # BCASTs (0=1rg,1=1rM,2=2rg,3=2rM,4=Lng,5=LnM)
# NUM_DEPTH = (1,) # of lookahead depth
# DEPTH = (1,) # DEPTHs (=0)
# SWAP = (1,) # SWAP (0=bin-exch,1=long,2=mix)
# SWAP_THRESH = (64,) # swapping threshold
# L1_T = (0,) # L1 in (0=transposed,1=no-transposed) form
# U_T = (0,) # U in (0=transposed,1=no-transposed) form
# EQUIL = (1,) # Equilibration (0=no,1=yes)
# MEM_ALIGN = (8,) # memory alignment in double ( 0)
# SLURM_NNODES = (1, 4, 8, 16, 32, 48)
# SLURM_NTASKS_PER_NODE = (1, 4, 8)
# OMP_THREADS = (1, 2, 4, 8)

# Sweep 2: Ran:
# (32 nodes, 1 tasks per node, 4 cpus per task)
# (32 nodes, 8 tasks per node, 1 cpus per task)
# (16 nodes, 1 tasks per node, 4 cpus per task)
# (16 nodes, 8 tasks per node, 1 cpus per task)
# (8 nodes, 1 tasks per node, 4 cpus per task)
# (8 nodes, 8 tasks per node, 1 cpus per task)
# (4 nodes, 1 tasks per node, 4 cpus per task)
# (4 nodes, 8 tasks per node, 1 cpus per task)
# (1 nodes, 1 tasks per node, 4 cpus per task)
# (1 nodes, 8 tasks per node, 1 cpus per task)
# ----
# NUM_N = (1,) # of problems sizes (N)
# N = (3000, 6000, 11000, 14616) # Ns # Appropriate for 16GB RAM
# NUM_BLOCKS = (1,) # of NBs
# BLOCK_SIZE = (32, 48, 64, 96) # NBs
# PROC_MAP = (0,) # PMAP process mapping (0=Row-,1=Column-major)
# NUM_PxQ = (1,) # of process grids (P x Q)
# P = (1, 4, 8) # Ps
# Q = (1, 4, 8, 16, 32, 48) # Qs
# THRESH = (16.0,) # threshold
# NUM_PFACT = (1,) # of panel fact
# PFACT = (2,) # PFACTs (0=left, 1=Crout, 2=Right)
# NUM_REC_STOP_CRIT = (1,) # of recursive stopping criterium
# NBMIN = (4,) # NBMINs (= 1)
# NUM_REC_PANELS = (1,) # of panels in recursion
# NDIV = (2,) # NDIVs
# NUM_RPFACT = (1,) # of recursive panel fact.
# RPFACT = (2,) # RFACTs (0=left, 1=Crout, 2=Right)
# NUM_BCAST = (1,) # of broadcast
# BCAST = (2,) # BCASTs (0=1rg,1=1rM,2=2rg,3=2rM,4=Lng,5=LnM)
# NUM_DEPTH = (1,) # of lookahead depth
# DEPTH = (1,) # DEPTHs (=0)
# SWAP = (1,) # SWAP (0=bin-exch,1=long,2=mix)
# SWAP_THRESH = (64,) # swapping threshold
# L1_T = (0,) # L1 in (0=transposed,1=no-transposed) form
# U_T = (0,) # U in (0=transposed,1=no-transposed) form
# EQUIL = (1,) # Equilibration (0=no,1=yes)
# MEM_ALIGN = (8,) # memory alignment in double ( 0)
# SLURM_NNODES = (1, 4, 8, 16, 32, 48)
# SLURM_NTASKS_PER_NODE = (1, 4, 8)
# OMP_THREADS = (1, 2, 4, 8)

# Sweep 3: Ran:
# (48 nodes, 1 tasks per node, 8 cpus per task)
# (48 nodes, 1 tasks per node, 4 cpus per task)
# (48 nodes, 8 tasks per node, 1 cpus per task)
# (32 nodes, 1 tasks per node, 4 cpus per task)
# (32 nodes, 8 tasks per node, 1 cpus per task)
# (16 nodes, 1 tasks per node, 4 cpus per task)
# (16 nodes, 8 tasks per node, 1 cpus per task)
# (8 nodes, 1 tasks per node, 4 cpus per task)
# (8 nodes, 8 tasks per node, 1 cpus per task)
# (4 nodes, 1 tasks per node, 4 cpus per task)
# (4 nodes, 8 tasks per node, 1 cpus per task)
# (1 nodes, 1 tasks per node, 4 cpus per task)
# (1 nodes, 8 tasks per node, 1 cpus per task)
# ----
# NUM_N = (1,) # of problems sizes (N)
# N = (29232, 43848, 58464, 73080, 467712, 935424) # Ns # Appropriate for 16GB RAM
# NUM_BLOCKS = (1,) # of NBs
# BLOCK_SIZE = (32, 48, 64, 96, 128, 232, 512, 768) # NBs
# PROC_MAP = (0,) # PMAP process mapping (0=Row-,1=Column-major)
# NUM_PxQ = (1,) # of process grids (P x Q)
# P = (1, 4, 8) # Ps
# Q = (1, 4, 8, 16, 32, 48) # Qs
# THRESH = (16.0,) # threshold
# NUM_PFACT = (1,) # of panel fact
# PFACT = (2,) # PFACTs (0=left, 1=Crout, 2=Right)
# NUM_REC_STOP_CRIT = (1,) # of recursive stopping criterium
# NBMIN = (4,) # NBMINs (= 1)
# NUM_REC_PANELS = (1,) # of panels in recursion
# NDIV = (2,) # NDIVs
# NUM_RPFACT = (1,) # of recursive panel fact.
# RPFACT = (2,) # RFACTs (0=left, 1=Crout, 2=Right)
# NUM_BCAST = (1,) # of broadcast
# BCAST = (2,) # BCASTs (0=1rg,1=1rM,2=2rg,3=2rM,4=Lng,5=LnM)
# NUM_DEPTH = (1,) # of lookahead depth
# DEPTH = (1,) # DEPTHs (=0)
# SWAP = (1,) # SWAP (0=bin-exch,1=long,2=mix)
# SWAP_THRESH = (64,) # swapping threshold
# L1_T = (0,) # L1 in (0=transposed,1=no-transposed) form
# U_T = (0,) # U in (0=transposed,1=no-transposed) form
# EQUIL = (1,) # Equilibration (0=no,1=yes)
# MEM_ALIGN = (8,) # memory alignment in double ( 0)
# SLURM_NNODES = (1, 4, 8, 16, 32, 48)
# SLURM_NTASKS_PER_NODE = (1, 4, 8)
# OMP_THREADS = (1, 2, 4, 8)

# Sweep 4: Ran:
# (48 nodes, 1 tasks per node, 8 cpus per task)
# (48 nodes, 1 tasks per node, 4 cpus per task)
# (48 nodes, 8 tasks per node, 1 cpus per task)
# ----
# NUM_N = (1,) # of problems sizes (N)
# N = (29232, 43848, 58464, 73080) # Ns # Appropriate for 16GB RAM
# NUM_BLOCKS = (1,) # of NBs
# BLOCK_SIZE = (32, 64, 96, 128, 232, 512) # NBs
# PROC_MAP = (0,) # PMAP process mapping (0=Row-,1=Column-major)
# NUM_PxQ = (1,) # of process grids (P x Q)
# P = (2, 4, 6, 8, 12, 16) # Ps
# Q = (6, 12, 24, 30, 48, 72) # Qs
# THRESH = (16.0,) # threshold
# NUM_PFACT = (1,) # of panel fact
# PFACT = (2,) # PFACTs (0=left, 1=Crout, 2=Right)
# NUM_REC_STOP_CRIT = (1,) # of recursive stopping criterium
# NBMIN = (4,) # NBMINs (= 1)
# NUM_REC_PANELS = (1,) # of panels in recursion
# NDIV = (2,) # NDIVs
# NUM_RPFACT = (1,) # of recursive panel fact.
# RPFACT = (2,) # RFACTs (0=left, 1=Crout, 2=Right)
# NUM_BCAST = (1,) # of broadcast
# BCAST = (2,) # BCASTs (0=1rg,1=1rM,2=2rg,3=2rM,4=Lng,5=LnM)
# NUM_DEPTH = (1,) # of lookahead depth
# DEPTH = (1,) # DEPTHs (=0)
# SWAP = (1,) # SWAP (0=bin-exch,1=long,2=mix)
# SWAP_THRESH = (64,) # swapping threshold
# L1_T = (0,) # L1 in (0=transposed,1=no-transposed) form
# U_T = (0,) # U in (0=transposed,1=no-transposed) form
# EQUIL = (1,) # Equilibration (0=no,1=yes)
# MEM_ALIGN = (8,) # memory alignment in double ( 0)
# SLURM_NNODES = (48,)
# SLURM_NTASKS_PER_NODE = (1, 8)
# OMP_THREADS = (1, 4, 8)
