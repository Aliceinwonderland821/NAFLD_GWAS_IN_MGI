#!/bin/bash
# This script runs regenie step2 (binary trait this time)
# `/usr/bin/time -o step2_time_mem_by_sex.log -a --format='(time=%E mem=%Mmax swap=%W)' ./step2_snptest_by_sex.sh`

cd ${DATA_OUT}
mkdir -p step2_by_sex_20pc && cd step2_by_sex_20pc

whecho "starting mgi nafld regenie step2 by sex using PC1-20_ALL, parallel chr1-22"

parallel \
'regenie \
  --step 2 \
  --bgen ${MGI_REGENIE_STEP2}Freeze6_TOPMed.UNFILTERED.xwalk.broad_sharable.chr{}.no_phase_new.bgen \
  --bgi ${MGI_REGENIE_STEP2}Freeze6_TOPMed.UNFILTERED.xwalk.broad_sharable.chr{}.no_phase_new.bgen.bgi \
  --sample ${MGI_REGENIE_STEP2}Freeze6_TOPMed.UNFILTERED.xwalk.broad_sharable.chr{}.no_phase_new.sample.identical.id1.id2 \
  --covarFile ${PHENO_DIR}Freeze6_MGI_NAFLD_pheno_regenie.txt \
  --covarColList SNPSEX,age,age2,PC1_ALL,PC2_ALL,PC3_ALL,PC4_ALL,PC5_ALL,PC6_ALL,PC7_ALL,PC8_ALL,PC9_ALL,PC10_ALL,PC11_ALL,PC12_ALL,PC13_ALL,PC14_ALL,PC15_ALL,PC16_ALL,PC17_ALL,PC18_ALL,PC19_ALL,PC20_ALL \
  --phenoFile ${PHENO_DIR}Freeze6_MGI_NAFLD_pheno_regenie.txt \
  --phenoColList NAFLD_F,NAFLD_M,NAFLD_EUR_F,NAFLD_EUR_M,NAFLD_AFR_F,NAFLD_AFR_M,NAFLD_AMR_F,NAFLD_AMR_M,NAFLD_CSA_F,NAFLD_CSA_M,NAFLD_EAS_F,NAFLD_EAS_M,NAFLD_WAS_F,NAFLD_WAS_M \
  --bsize 400 \
  --bt \
  --firth --firth-se --approx --pThresh 0.5 \
  --minINFO 0.85 --minMAC 3.5 \
  --pred ${DATA_OUT}/step1_out_20pc/mgi_nafld_by_sex_step1_out_pred.list \
  --out mgi_nafld_by_sex_chr{}' ::: $(seq 1 22)

whecho "finished mgi nafld regenie step2 by sex using PC1-20_ALL, parallel chr1-22"
