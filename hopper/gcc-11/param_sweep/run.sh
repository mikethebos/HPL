#!/bin/bash
for NNODES in 1 2 8; do
    for NTASKS in 1 8 16; do
        for CPUS in 1 2 4; do
            sbatch \
                --job-name HPL_ParamSweep_${NNODES}_${NTASKS} \
                --partition general \
                --time 00:00:05 \
                --nodes $NNODES \
                --ntasks-per-node $NTASKS \
                --cpus-per-task $CPUS \
                --mem-per-cpu 1400M \
                --array "1-$(wc -l < HPL_params.csv)" \
                parameter_sweep_array.slurm
        done
    done
done
