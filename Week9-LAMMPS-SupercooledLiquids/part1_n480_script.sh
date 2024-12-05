#!/bin/bash
#SBATCH --job-name=kalj_anneal_n480
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=1
#SBATCH --time=01:00:00
#SBATCH --output=output_anneal_n480.log

# Load the LAMMPS module
source /scratch/work/courses/CHEM-GA-2671-2024fa/software/lammps-gcc-30Oct2022/setup_lammps.bash

# Ensure the Inputs directory exists and contains necessary files
if [ ! -d /home/yhp2008/comp-lab-class-2024/Week9-LAMMPS-SupercooledLiquids/Inputs ]; then
    echo "Error: Directory /Inputs does not exist."
    exit 1
fi

# Directory setup
mkdir -p Data
if ! cp /home/yhp2008/comp-lab-class-2024/Week9-LAMMPS-SupercooledLiquids/Inputs/kalj.lmp /home/yhp2008/comp-lab-class-2024/Week9-LAMMPS-SupercooledLiquids/Inputs/kalj_particles.lmp Data/; then
    echo "Error: Failed to copy input files to Data directory."
    exit 1
fi

# Move to the Data directory
cd Data || { echo "Error: Failed to enter Data directory."; exit 1; }

# Check LAMMPS executable
if ! command -v lmp &> /dev/null; then
    echo "Error: LAMMPS executable (lmp) not found."
    exit 1
fi

# System creation for n480 configuration
if ! mpirun lmp -var configfile /home/yhp2008/comp-lab-class-2024/Week9-LAMMPS-SupercooledLiquids/Inputs/n480/kalj_n480_create.lmp -var id 1 -in /home/yhp2008/comp-lab-class-2024/Week9-LAMMPS-SupercooledLiquids/Inputs/create_3d_binary.lmp; then
    echo "Error: LAMMPS system creation step for n480 failed."
    exit 1
fi

# Equilibration temperatures array
temperatures=(1.5 1.0 0.9 0.8 0.7 0.65 0.6 0.55 0.5 0.475)

# Loop over temperatures to run equilibration
for T in "${temperatures[@]}"; do
    if ! mpirun lmp -var configfile /home/yhp2008/comp-lab-class-2024/Week9-LAMMPS-SupercooledLiquids/Inputs/n480/kalj_n480_T$T.lmp -var id 1 -in /home/yhp2008/comp-lab-class-2024/Week9-LAMMPS-SupercooledLiquids/Inputs/anneal_3d_binary.lmp; then
        echo "Error: LAMMPS equilibration at temperature $T for n480 failed."
        exit 1
    fi
done
