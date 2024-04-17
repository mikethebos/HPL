#!/bin/bash

for NNODES in 1 2 3; do
    for NTASKS in 1 8 16; do
        for CPUS in 1; do
            count=$(wc -l < HPL_params.csv)
            sbatch \
                --job-name HPL_ParamSweep_${NNODES}_${NTASKS} \
                --partition general \
                --time 00:10:00 \
                --nodes $NNODES \
                --ntasks-per-node $NTASKS \
                --cpus-per-task $CPUS \
                --mem 91GB \
                --array "1-$count" \
                parameter_sweep_array.slurm
        done
    done
done
