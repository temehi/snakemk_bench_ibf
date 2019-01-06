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
snakemake download_files;
snakemake build_index;
snakemake classify_reads;
snakemake update_index;
snakemake create_csv;
```

OR simply:

```
./run_benchmark.sh
```


