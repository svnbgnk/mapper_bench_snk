#!/bin/bash

snakemake reference;
snakemake index;
snakemake map;
snakemake gold;
snakemake evaluate;
snakemake report;