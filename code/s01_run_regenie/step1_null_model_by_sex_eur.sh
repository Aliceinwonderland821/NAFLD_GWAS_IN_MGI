#!/bin/bash
# This script run regenie step1
# Need to record time and mem
# `/usr/bin/time -o step1_time_mem_by_sex_eur.log -a --format='(time=%E mem=%Mmax swap=%W)' ./step1_null_model_by_sex_eur.sh > step1_by_sex_eur.log`

cd ${DATA_OUT}
mkdir -p step1_out && cd step1_out 

whecho "starting MGI Freeze6 NAFLD GWAS stratefied by sex and sex-ancestry EUR"
regenie \
  --step 1 \
  --bed ${MGI_REGENIE_STEP1} \
  --covarFile ${PHENO_DIR}Freeze6.xwalk.broad_sharable.covariates.txt.addNA.extract_covs.txt.match_demog.txt.add_NAFLD.ALL_sample.nomiss.regenie \
  --covarColList age,age2,PC1_EUR,PC2_EUR,PC3_EUR,PC4_EUR,PC5_EUR,PC6_EUR,PC7_EUR,PC8_EUR,PC9_EUR,PC10_EUR \
  --phenoFile ${PHENO_DIR}Freeze6.xwalk.broad_sharable.covariates.txt.addNA.extract_covs.txt.match_demog.txt.add_NAFLD.ALL_sample.nomiss.regenie \
  --phenoColList NAFLD_EUR_F,NAFLD_EUR_M \
  --bsize 2000 \
  --threads 40 \
  --force-step1 --bt --lowmem \
  --out ${DATA_OUT}step1_out/mgi_nafld_by_sex_eur_step1_out 
whecho "finished MGI Freeze6 NAFLD GWAS stratefied by sex and sex-ancestry EUR"