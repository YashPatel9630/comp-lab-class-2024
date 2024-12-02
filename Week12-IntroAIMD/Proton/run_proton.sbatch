#!/bin/bash
#SBATCH --job-name=proton_aimd_1ns
#SBATCH --output=proton_aimd_output.log
#SBATCH --error=proton_aimd_error.log
#SBATCH --time=06:00:00
#SBATCH --cpus-per-task=1
#SBATCH --ntasks-per-node=12
#SBATCH --mem=20GB

# Load the required CP2K module
module purge
module load cp2k/openmpi/intel/20201212

# Run the simulation
mpirun -np 12 cp2k.popt -i Proton.inp -o proton_aimd_1ns.log
