#!/bin/bash
# This script run regenie step1
# Need to record time and mem
# `/usr/bin/time -o step1_time_mem.log -a --format='(time=%E mem=%Mmax swap=%W)' ./step1_null_model.sh`

cd ${REGENIE}
mkdir -p output && cd output 

regenie \
  --step 1 \
  --bed /mnt/speliotes-lab/Projects/UK_ATLAS/GENODATA/PLINK/GRM_combine/merge \
  --covarFile ${REGENIE}pheno_file/covariate.txt \
  --phenoFile ${REGENIE}pheno_file/multi_pheno.txt \
  --phenocol \
  --bsize 45000 \
  --force-step1 --qt --out test_step1_out