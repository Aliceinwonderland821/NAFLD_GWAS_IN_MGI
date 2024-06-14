#!/bin/bash
# This script run regenie step1
# Need to record time and mem
# `/usr/bin/time -o step1_time_mem_by_sex.log -a --format='(time=%E mem=%Mmax swap=%W)' ./step1_null_model_by_sex.sh > step1_by_sex_20pc.log`

cd ${DATA_OUT}
mkdir -p step1_out_20pc && cd step1_out_20pc 

whecho "starting MGI Freeze6 NAFLD GWAS stratefied by sex and sex-ancestry 20 pc"
regenie \
  --step 1 \
  --bed ${MGI_REGENIE_STEP1} \
  --covarFile /nfs/corenfs/INTMED-Speliotes-data/Projects/GoldPP_MGI_GWAS/data/Freeze6_MGI_NAFLD_pheno_regenie.txt \
  --covarColList SNPSEX,age,age2,PC1_ALL,PC2_ALL,PC3_ALL,PC4_ALL,PC5_ALL,PC6_ALL,PC7_ALL,PC8_ALL,PC9_ALL,PC10_ALL,PC11_ALL,PC12_ALL,PC13_ALL,PC14_ALL,PC15_ALL,PC16_ALL,PC17_ALL,PC18_ALL,PC19_ALL,PC20_ALL \
  --phenoFile /nfs/corenfs/INTMED-Speliotes-data/Projects/GoldPP_MGI_GWAS/data/Freeze6_MGI_NAFLD_pheno_regenie.txt \
  --phenoColList NAFLD_F,NAFLD_M,NAFLD_EUR_F,NAFLD_EUR_M,NAFLD_AFR_F,NAFLD_AFR_M,NAFLD_AMR_F,NAFLD_AMR_M,NAFLD_CSA_F,NAFLD_CSA_M,NAFLD_EAS_F,NAFLD_EAS_M,NAFLD_WAS_F,NAFLD_WAS_M \
  --bsize 2000 \
  --threads 40 \
  --force-step1 --bt --lowmem \
  --out mgi_nafld_by_sex_step1_out 
whecho "finished MGI Freeze6 NAFLD GWAS stratefied by sex and sex-ancestry 20 pc"