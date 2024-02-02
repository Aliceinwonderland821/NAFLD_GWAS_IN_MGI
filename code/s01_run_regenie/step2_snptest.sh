#!/bin/bash
# This script runs regenie step2 (quantitative trait this time)
# `/usr/bin/time -o step2_time_mem.log -a --format='(time=%E mem=%Mmax swap=%W)' ./step2_snptest.sh`

cd ${REGENIE}output 

regenie \
  --step 2 \
  --bgen /home/lishiy/regenie_dir/ukb_imp_wgs_np_phase_8bit_chr22_v1.bgen \
  --bgi /home/lishiy/regenie_dir/ukb_imp_wgs_np_phase_8bit_chr22_v1.bgen.bgi \
  --covarFile ${REGENIE}/pheno_file/covariate.txt \
  --phenoFile ${REGENIE}/pheno_file/multi_pheno.txt \
  --phenoCol \
  --bsize 45000 \
  --qt \
  --pred ${REGENIE}/output/test_step1_out_pred.list \
  --out test_step2_qt