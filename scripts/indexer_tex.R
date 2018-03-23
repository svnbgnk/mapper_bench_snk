source(file="scripts/indexer.R")

tex_out = snakemake@output[[1]]
RESULT_DIR = snakemake@wildcards[['prefix']]
reference = snakemake@wildcards[['reference']]
indextype = snakemake@wildcards[['indextype']]

DATASET = reference

COLUMNS = c("P_bin_size", "P_build_time","P_update_time", "P_memory")

MODES = c("build")

MODE2INDEXERS = list(
    # build = c("distyara_taxo_1024", "dyara_taxo_1024", "dyara_taxo_256", "dyara_taxo_64", "yara", "bowtie2", "bwamem", "gem")
    build = c("distyara_taxo_1024", "dyara_taxo_1024", "yara", "bowtie2", "bwamem", "gem")
)

write_table(tex_out)
