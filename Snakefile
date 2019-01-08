# vim: syntax=python tabstop=4 expandtab
# coding: utf-8

# Rabema pipeline

import platform
import os

from math import log10, ceil
from snakemake.utils import linecount
from snakemake.remote.FTP import RemoteProvider as FTPRemoteProvider
FTP = FTPRemoteProvider()

def make_parts(p):
    return [str(x).zfill(int(ceil(log10(p)))) for x in range(0, p)]


# === detect arch and chose sed and time
SED="sed"
TIME="command time -f 'RES:%e\\t%M\\t%P' "
if platform.system() == 'Darwin':
    SED="gsed"
    TIME="command gtime -f 'RES:%e\\t%M\\t%P' "

# === Configuration
configfile: "config.json"

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

# === Rules
include: "rules/references.rules"
include: "rules/reads.rules"
include: "rules/ibf.rules"
include: "rules/collect_vals.rules"
# include: "rules/rabema.rules"
# include: "rules/tex.rules"



# === Stages

rule download_files:
    input:
        refs=expand("data/{reference}_{bin_methods}_{num_bins}/ref_{num_bins}",
            reference=get_references(),
            bin_methods=config["bin_methods"],
            num_bins=config["num_bins"]),
        refs_up=expand("data/{reference}_{bin_methods}_{num_bins}_up/ref_up_{num_bins}",
            reference=get_references(),
            bin_methods=config["bin_methods"],
            num_bins=config["num_bins"]),
        reads=expand("data/{reads}_{limit}.fastq",
            reads=get_reads(),
            limit=get_limits())

rule build_index:
    input:
        ibf=expand("data/{reference}_{bin_method}_{num_bin}_n{ibf_size}_k{kmer_size}.filter",
            reference=get_references(),
            bin_method=config["bin_methods"],
            num_bin=config["num_bins"],
            ibf_size=config["ibf_sizes"],
            kmer_size=config["kmer_sizes"])

rule update_index:
    input:
        ibf=expand("data/{reference}_{bin_method}_{num_bin}_n{ibf_size}_k{kmer_size}.filter.up",
            reference=get_references(),
            bin_method=config["bin_methods"],
            num_bin=config["num_bins"],
            ibf_size=config["ibf_sizes"],
            kmer_size=config["kmer_sizes"])


rule classify_reads:
    input:
        expand("data/{reference}_{bin_method}_{num_bin}_n{ibf_size}_k{kmer_size}_{reads}.csv",
            reference=get_references(),
            bin_method=config["bin_methods"],
            num_bin=config["num_bins"],
            ibf_size=config["ibf_sizes"],
            kmer_size=config["kmer_sizes"],
            reads=get_reads())

rule create_csv:
    input:"data/report_ibf_all.csv"

