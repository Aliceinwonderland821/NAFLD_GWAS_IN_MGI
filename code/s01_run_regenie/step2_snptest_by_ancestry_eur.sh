#!/bin/bash
# This script runs regenie step2 (quantitative trait this time)
# `/usr/bin/time -o step2_time_mem_by_ancestry_eur.log -a --format='(time=%E mem=%Mmax swap=%W)' ./step2_snptest_by_ancestry_eur.sh`

cd ${DATA_OUT}
mkdir -p step2_by_ancestry_eur && cd step2_by_ancestry_eur

whecho "starting mgi nafld regenie step2 by ancestry eur using PC1-10_EUR \n parallel chr1-22"

parallel \
'regenie \
  --step 2 \
  --bgen ${MGI_REGENIE_STEP2}Freeze6_TOPMed.UNFILTERED.xwalk.broad_sharable.chr{}.no_phase_new.bgen \
  --bgi ${MGI_REGENIE_STEP2}Freeze6_TOPMed.UNFILTERED.xwalk.broad_sharable.chr{}.no_phase_new.bgen.bgi \
  --sample ${MGI_REGENIE_STEP2}Freeze6_TOPMed.UNFILTERED.xwalk.broad_sharable.chr{}.no_phase_new.sample.identical.id1.id2 \
  --covarFile ${PHENO_DIR}Freeze6.xwalk.broad_sharable.covariates.txt.addNA.extract_covs.txt.match_demog.txt.add_NAFLD.ALL_sample.nomiss.regenie \
  --covarColList SNPSEX,age,age2,PC1_EUR,PC2_EUR,PC3_EUR,PC4_EUR,PC5_EUR,PC6_EUR,PC7_EUR,PC8_EUR,PC9_EUR,PC10_EUR \
  --phenoFile ${PHENO_DIR}Freeze6.xwalk.broad_sharable.covariates.txt.addNA.extract_covs.txt.match_demog.txt.add_NAFLD.ALL_sample.nomiss.regenie \
  --phenoColList NAFLD_EUR \
  --bsize 400 \
  --bt \
  --firth --firth-se --approx --pThresh 0.5 \
  --minINFO 0.85 --minMAC 3.5 \
  --pred ${DATA_OUT}/step1_out/mgi_nafld_by_ancestry_eur_step1_out_pred.list \
  --out mgi_nafld_by_ancestry_eur_chr{} ' ::: $(seq 1 22)

whecho "finished mgi nafld regenie step2 EUR ancestry using PC1-10_EUR \n parallel chr1-22"
