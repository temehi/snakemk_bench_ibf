#!/bin/bash
snakemake download_files;
sleep 10s; rm -rf .snakemake;
snakemake build_index;
sleep 10s; rm -rf .snakemake;
snakemake update_index;
sleep 10s; rm -rf .snakemake;
snakemake classify_reads;
sleep 10s; rm -rf .snakemake;
snakemake create_csv;
