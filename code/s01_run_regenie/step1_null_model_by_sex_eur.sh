#!/bin/bash
# This script run regenie step1
# Need to record time and mem
# `/usr/bin/time -o step1_time_mem_by_sex_eur.log -a --format='(time=%E mem=%Mmax swap=%W)' ./step1_null_model_by_sex_eur.sh > step1_by_sex_eur_20pc.log`

cd ${DATA_OUT}
mkdir -p step1_out_20pc && cd step1_out_20pc 

whecho "From server2: started MGI EUR NAFLD GWAS sex stratified with EUR PC1-20 step1"
regenie \
  --step 1 \
  --bed ${MGI_REGENIE_STEP1} \
  --covarFile ${PHENO_DIR}Freeze6_MGI_NAFLD_pheno_regenie.txt \
  --covarColList age,age2,PC1_EUR,PC2_EUR,PC3_EUR,PC4_EUR,PC5_EUR,PC6_EUR,PC7_EUR,PC8_EUR,PC9_EUR,PC10_EUR,PC11_EUR,PC12_EUR,PC13_EUR,PC14_EUR,PC15_EUR,PC16_EUR,PC17_EUR,PC18_EUR,PC19_EUR,PC20_EUR \
  --phenoFile ${PHENO_DIR}Freeze6_MGI_NAFLD_pheno_regenie.txt \
  --phenoColList NAFLD_EUR_F,NAFLD_EUR_M \
  --bsize 2000 \
  --threads 40 \
  --force-step1 --bt --lowmem \
  --out ${DATA_OUT}step1_out_20pc/mgi_nafld_by_sex_eur_step1_out 
whecho "From server2: finished MGI EUR NAFLD GWAS sex stratified with EUR PC1-20 step1"
