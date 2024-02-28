#!/bin/bash
# This script run regenie step1
# Need to record time and mem
# `/usr/bin/time -o step1_time_mem.log -a --format='(time=%E mem=%Mmax swap=%W)' ./step1_null_model_by_ancestry.sh > step1_by_ancestry.log`

cd ${DATA_OUT}
mkdir -p step1_out && cd step1_out 

whecho "starting regenie step1 for MGI NAFLD GWAS stratefied by ancestry and using PC_ALL1-10"
regenie \
  --step 1 \
  --bed ${MGI_REGENIE_STEP1} \
  --covarFile ${PHENO_DIR}Freeze6.xwalk.broad_sharable.covariates.txt.addNA.extract_covs.txt.match_demog.txt.add_NAFLD.ALL_sample.nomiss.regenie \
  --covarColList SNPSEX,age,age2,PC1_ALL,PC2_ALL,PC3_ALL,PC4_ALL,PC5_ALL,PC6_ALL,PC7_ALL,PC8_ALL,PC9_ALL,PC10_ALL \
  --phenoFile ${PHENO_DIR}Freeze6.xwalk.broad_sharable.covariates.txt.addNA.extract_covs.txt.match_demog.txt.add_NAFLD.ALL_sample.nomiss.regenie \
  --phenoColList NAFLD,NAFLD_EUR,NAFLD_AFR,NAFLD_AMR,NAFLD_CSA,NAFLD_EAS,NAFLD_WAS \
  --bsize 2000 \
  --threads 36 \
  --force-step1 --bt --lowmem \
  --out mgi_nafld_by_ancestry_step1_out 

whecho "finished regenie step1 for MGI NAFLD GWAS stratefied by ancestry and using PC_ALL1-10"

