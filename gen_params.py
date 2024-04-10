#!/usr/bin/env python3

from itertools import product

NUM_N = (1,) # of problems sizes (N)
N = (3000, 6000, 14616,) # Ns # Appropriate for 16GB RAM
NUM_BLOCKS = (1,) # of NBs
BLOCK_SIZE = (232,) # NBs
PROC_MAP = (0,) # PMAP process mapping (0=Row-,1=Column-major)
NUM_PxQ = (1,) # of process grids (P x Q)
P = (2,) # Ps
Q = (4,) # Qs
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
NUM_NODES = (1, 4, 16)
TASKS_PER_NODE = (1, 2, 4)

for args in product(NUM_N, N, NUM_BLOCKS, BLOCK_SIZE, PROC_MAP, NUM_PxQ, P, Q,
                    THRESH, NUM_PFACT, PFACT, NUM_REC_STOP_CRIT, NBMIN,
                    NUM_REC_PANELS, NDIV, NUM_RPFACT, RPFACT, NUM_BCAST, BCAST,
                    NUM_DEPTH, DEPTH, SWAP, SWAP_THRESH, L1_T, U_T, EQUIL,
                    MEM_ALIGN, NUM_NODES, TASKS_PER_NODE):
    print(','.join(str(x) for x in args))
