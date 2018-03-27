# vim: syntax=python tabstop=4 expandtab
# coding: utf-8

# Rabema pipeline


# === Configuration

configfile: "config.json"


# === Rules

# include: "rules/genbank.rules"
# include: "rules/sra.rules"
include: "rules/get_refs.rules"
include: "rules/fastq.rules"
include: "rules/samfiles.rules"
include: "rules/rabema.rules"
include: "rules/tex.rules"

include: "rules/razers3.rules"

include: "rules/didabwa.rules"
include: "rules/yara.rules"
include: "rules/dyara.rules"
include: "rules/distyara.rules"

include: "rules/gem.rules"
include: "rules/bowtie2.rules"
include: "rules/bwa.rules"

# ruleorder: bam_sort_name > rabema_prepare > razers3_map_se > razers3_map_se_parts
# === Functions

def get_references():
    return [row[0] for row in config["jobs"]]

def get_reads():
    return [row[1] for row in config["jobs"]]

def get_limits():
    return [row[2] for row in config["jobs"]]

def expand_jobs(pattern, **kwargs):
    jobs = []
    for reference, reads, limit in config["jobs"]:
        jobs.extend(expand(pattern, reference=reference, reads=reads, limit=limit, **kwargs))
    return jobs


# === Stages
 
rule reference:
    input:
        expand("data/{reference}_{bin_methods}_{num_bins}/ref_{num_bins}", 
            reference=get_references(),
            bin_methods=config["bin_methods"],
            num_bins=config["num_bins"])

rule reference_merge:
    input:
        expand("data/{reference}.fasta",  reference=get_references())

rule index:
    input:
        std=expand("data/{reference}.{indexer}.index", reference=get_references(), indexer=config["indexers"].keys()),
        dis=expand("data/{reference}.{indexer}_{bin_methods}_{num_bins}.index.log",
            reference=get_references(), 
            indexer=config["dindexers"].keys(),
            bin_methods=config["bin_methods"],
            num_bins=config["num_bins"]),
        ibf=expand("data/{reference}.{indexer}_{bin_methods}_{num_bins}.filter",
            reference=get_references(), 
            indexer=config["ibf_indexers"].keys(),
            bin_methods=config["bin_methods"],
            num_bins=config["num_bins"])

rule index_update:
    input:
        dis=expand("data/{reference}.{indexer}_{bin_methods}_{num_bins}.index_up.log",
            reference=get_references(), 
            indexer=config["dindexers"].keys(),
            bin_methods=config["bin_methods"],
            num_bins=config["num_bins"]),
        ibf=expand("data/{reference}.{indexer}_{bin_methods}_{num_bins}_up.filter",
            reference=get_references(), 
            indexer=config["ibf_indexers"].keys(),
            bin_methods=config["bin_methods"],
            num_bins=config["num_bins"])

rule reads:
    input:
        expand("data/{reads}_{limit}.fastq",
                reads=get_reads(),
                limit=get_limits()),
rule map:
    input:
        std=expand_jobs("data/{reads}_{limit}.{reference}.{mapper}.bam",
                    mapper=config["mappers"].keys()),
        dis=expand_jobs("data/{reads}_{limit}.{reference}.{mapper}_{bin_methods}_{num_bins}.bam",
                    mapper=config["dmappers"].keys(),
                    bin_methods=config["bin_methods"],
                    num_bins=config["num_bins"])

rule gold:
    input:
        expand_jobs("data/{reads}_{limit}.{reference}.{errors}.gsi.gz",
                    errors="5")

rule evaluate:
    input:
        std=expand_jobs("data/{reads}_{limit}.{reference}.{mapper}.{errors}.{category}.rabema_report_tsv",
                    mapper=config["mappers"].keys(),
                    bin_methods=config["bin_methods"],
                    num_bins=config["num_bins"],
                    errors="5",
                    category="all-best"),
        dis=expand_jobs("data/{reads}_{limit}.{reference}.{mapper}_{bin_methods}_{num_bins}.{errors}.{category}.rabema_report_tsv",
                    mapper=config["dmappers"].keys(),
                    bin_methods=config["bin_methods"],
                    num_bins=config["num_bins"],
                    errors="5",
                    category="all-best")

rule report:
    input:
        mapper=expand_jobs("data/{reads}_{limit}.{reference}.{errors}.{category}.pdf",
                    errors="5",
                    category="all-best"),
        indexer=expand_jobs("data/{reference}.pdf")
