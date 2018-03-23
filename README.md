Configure config.jason file
```
  "jobs": [
      ["A_B_refseq_sample", "taxo", 1024, "ABSim100K", 1000]
  ],
  "jobs_DISABLED": [
      ["A_B_refseq_20170926", "taxo", 1024, "ABSim", 10000]
  ],
  "genbank": {
      "A_B_refseq_20170926_taxo_1024": "ftp://ftp.mi.fu-berlin.de/pub/dadi/test_site/A_B_refseq_20170926_taxo_1024.tar.gz",
      "A_B_refseq_sample_taxo_1024": "ftp://ftp.mi.fu-berlin.de/pub/dadi/test_site/A_B_refseq_sample_taxo_1024.tar.gz",
```

then run 

```
snakemake reference;
snakemake index;
snakemake map;
snakemake gold;
snakemake evaluate;
snakemake report;
```

in that particular order. OR

```
snakemake reference;
snakemake evaluate;
snakemake report;
```

OR simply:

```
./run_benchmark.sh
```


