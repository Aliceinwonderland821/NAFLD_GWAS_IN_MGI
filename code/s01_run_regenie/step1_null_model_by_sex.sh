#!/bin/bash
# This script run regenie step1
# Need to record time and mem
# `/usr/bin/time -o step1_time_mem_by_sex.log -a --format='(time=%E mem=%Mmax swap=%W)' ./step1_null_model_by_sex.sh > step1_by_sex.log`

cd ${DATA_OUT}
mkdir -p step1_out && cd step1_out 

whecho "starting MGI Freeze6 NAFLD GWAS stratefied by sex and sex-ancestry"
regenie \
  --step 1 \
  --bed ${MGI_REGENIE_STEP1} \
  --covarFile ${PHENO_DIR}Freeze6.xwalk.broad_sharable.covariates.txt.addNA.extract_covs.txt.match_demog.txt.add_NAFLD.ALL_sample.nomiss.regenie \
  --covarColList age,age2,PC1_ALL,PC2_ALL,PC3_ALL,PC4_ALL,PC5_ALL,PC6_ALL,PC7_ALL,PC8_ALL,PC9_ALL,PC10_ALL \
  --phenoFile ${PHENO_DIR}Freeze6.xwalk.broad_sharable.covariates.txt.addNA.extract_covs.txt.match_demog.txt.add_NAFLD.ALL_sample.nomiss.regenie \
  --phenoColList NAFLD_F,NAFLD_M,NAFLD_EUR_F,NAFLD_EUR_M,NAFLD_AFR_F,NAFLD_AFR_M,NAFLD_AMR_F,NAFLD_AMR_M,NAFLD_CSA_F,NAFLD_CSA_M,NAFLD_EAS_F,NAFLD_EAS_M,NAFLD_WAS_F,NAFLD_WAS_M \
  --bsize 2000 \
  --threads 40 \
  --force-step1 --bt --lowmem \
  --out mgi_nafld_by_sex_step1_out 
whecho "finished MGI Freeze6 NAFLD GWAS stratefied by sex and sex-ancestry"