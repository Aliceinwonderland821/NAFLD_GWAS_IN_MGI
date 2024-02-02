#!/bin/bash
# This script runs regenie step2 (quantitative trait this time)
# `/usr/bin/time -o step2_time_mem.log -a --format='(time=%E mem=%Mmax swap=%W)' ./step2_snptest_bt.sh > step2.log`

cd ${DATA_OUT}
mkdir -p binary_eur && cd binary_eur

for ((i=1;i<=22;i++))
do
regenie \
  --step 2 \
  --bgen ${GENO_STEP2_BGEN}MGI_F5_UNFILTERED_chr${i}_no_phase_8bits.bgen \
  --bgi ${GENO_STEP2_BGEN}MGI_F5_UNFILTERED_chr${i}_no_phase_8bits.bgen.bgi \
  --sample ${GENO_STEP2_BGEN}MGI_F5_UNFILTERED_chr${i}_no_phase_8bits.sample.identical.id1.id2 \
  --covarFile ${PHENO_IN}Freeze5_sample_info.txt.extract_covs.txt.match_demog.txt.add_NAFLD.add_Cirrho.add_Steato.add_NASH.EUR_sample.only.final.header \
  --covarColList SNPSEX,AGE_2022,AGE_2022_s2,PC1_EUR,PC2_EUR,PC3_EUR,PC4_EUR,PC5_EUR,PC6_EUR,PC7_EUR,PC8_EUR,PC9_EUR,PC10_EUR \
  --phenoFile ${PHENO_IN}Freeze5_sample_info.txt.extract_covs.txt.match_demog.txt.add_NAFLD.add_Cirrho.add_Steato.add_NASH.EUR_sample.only.final.header \
  --phenoColList NASH,NASH_steato \
  --bsize 200000 \
  --bt \
  --firth --approx --pThresh 0.05 \
  --minINFO 0.85 --minMAC 20 \
  --pred ${DATA_OUT}/step1_out/mgi_nash_step1_out_pred.list \
  --out mgi_step2_bt_chr${i}
done