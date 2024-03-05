#!/bin/bash
# This script runs regenie step2 
# `/usr/bin/time -o step2_time_mem_by_ancestry.log -a --format='(time=%E mem=%Mmax swap=%W)' ./step2_snptest_by_ancestry.sh`

cd ${DATA_OUT}
mkdir -p step2_by_ancestry && cd step2_by_ancestry

whecho "starting mgi nafld regenie step2 by ancestry using PC1-10_ALL \n parallel chr1-22"

parallel \
'regenie \
  --step 2 \
  --bgen ${MGI_REGENIE_STEP2}Freeze6_TOPMed.UNFILTERED.xwalk.broad_sharable.chr{}.no_phase_new.bgen \
  --bgi ${MGI_REGENIE_STEP2}Freeze6_TOPMed.UNFILTERED.xwalk.broad_sharable.chr{}.no_phase_new.bgen.bgi \
  --sample ${MGI_REGENIE_STEP2}Freeze6_TOPMed.UNFILTERED.xwalk.broad_sharable.chr{}.no_phase_new.sample.identical.id1.id2 \
  --covarFile ${PHENO_DIR}Freeze6.xwalk.broad_sharable.covariates.txt.addNA.extract_covs.txt.match_demog.txt.add_NAFLD.ALL_sample.nomiss.regenie \
  --covarColList SNPSEX,age,age2,PC1_ALL,PC2_ALL,PC3_ALL,PC4_ALL,PC5_ALL,PC6_ALL,PC7_ALL,PC8_ALL,PC9_ALL,PC10_ALL \
  --phenoFile ${PHENO_DIR}Freeze6.xwalk.broad_sharable.covariates.txt.addNA.extract_covs.txt.match_demog.txt.add_NAFLD.ALL_sample.nomiss.regenie \
  --phenoColList NAFLD,NAFLD_EUR,NAFLD_AFR,NAFLD_AMR,NAFLD_CSA,NAFLD_EAS,NAFLD_WAS \
  --bsize 400 \
  --bt \
  --firth --firth-se --approx --pThresh 0.5 \
  --minINFO 0.85 --minMAC 3.5 \
  --pred ${DATA_OUT}/step1_out/mgi_nafld_by_ancestry_step1_out_pred.list \
  --out mgi_nafld_by_ancestry_chr{}' ::: $(seq 1 22)

whecho "finished mgi nafld regenie step2 by ancestry using PC1-10_ALL \n parallel chr1-22"
