#!/bin/bash
#SBATCH --job-name=rabema
#SBATCH --output=sbatch.rabemai2
#SBATCH -p long
#SBATCH --c 40
#SBATCH --time=1440:00
#SBATCH --mem=130000

module load samtools

date
snakemake -j 40 index;
date
echo "Finished"
