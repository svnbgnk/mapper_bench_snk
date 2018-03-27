source(file="scripts/rabema.R")

#output = {prefix}/{reads}_{limit}_{suffix}.{reference}.{gold}.{errors}.{category}.tex

tex_out = snakemake@output[[1]]
RESULT_DIR = snakemake@wildcards[['prefix']]
reads = snakemake@wildcards[['reads']]
num_reads = strtoi(snakemake@wildcards[['limit']])
# suffix = snakemake@wildcards[['suffix']]
reference = snakemake@wildcards[['reference']]
# GOLD = snakemake@wildcards[['gold']]
MAX_ERRORS = strtoi(snakemake@wildcards[['errors']])
category = snakemake@wildcards[['category']]

READ_LENGTHS = c(100)
# DATASET = c(paste(paste(reads, num_reads, suffix, sep='_'), reference, sep='.'))
DATASET = c(paste(paste(reads, num_reads, sep='_'), reference, sep='.'))
#DATASET_LABEL = c("Illumina HiSeq 2000")
MODES = c("rabema")
MODE2MAPPERS = list(
    # rabema = c("yara_rabema","razers3_rabema","bowtie2_rabema","bwamem_rabema")
    rabema = c("dyara_rabema_taxo_1024","distyara_rabema_taxo_1024","yara_rabema","gem_rabema","bowtie2_rabema","bwa_rabema")
)

COLUMNS = c(paste("Rrx", category, sep="_"),"P_throughput","P_memory")

write_table(tex_out)