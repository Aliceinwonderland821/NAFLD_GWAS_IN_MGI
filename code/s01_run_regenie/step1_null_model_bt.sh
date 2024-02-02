#!/bin/bash
# This script run regenie step1
# Need to record time and mem
# `/usr/bin/time -o step1_time_mem.log -a --format='(time=%E mem=%Mmax swap=%W)' ./step1_null_model_bt.sh`

cd ${DATA_OUT}
mkdir -p step1_out && cd step1_out 

regenie \
  --step 1 \
  --bed ${GENO_STEP1}Freeze5_TOPMED_CoreExome_GSA_MAF_0.01 \
  --covarFile ${PHENO_IN}Freeze5_sample_info.txt.extract_covs.txt.match_demog.txt.add_NAFLD.add_Cirrho.add_Steato.add_NASH.EUR_sample.only.final.header \
  --covarColList SNPSEX,AGE_2022,AGE_2022_s2,PC1_EUR,PC2_EUR,PC3_EUR,PC4_EUR,PC5_EUR,PC6_EUR,PC7_EUR,PC8_EUR,PC9_EUR,PC10_EUR \
  --phenoFile ${PHENO_IN}Freeze5_sample_info.txt.extract_covs.txt.match_demog.txt.add_NAFLD.add_Cirrho.add_Steato.add_NASH.EUR_sample.only.final.header \
  --phenoColList NASH,NASH_steato \
  --bsize 40000 \
  --force-step1 --bt --out mgi_nash_step1_out \
