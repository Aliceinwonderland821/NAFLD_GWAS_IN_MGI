#!/bin/bash
# This script correct bgen sample file for regenie
# what it really change is make ID_1 = ID_2
# runs as `./step0.2_correct_bgen_sample_file.sh`

parallel 'Rscript correct_bgen_sample_file.R ${GENO_STEP2_BGEN}MGI_F5_UNFILTERED_chr{}_no_phase_8bits.sample ${GENO_STEP2_BGEN}MGI_F5_UNFILTERED_chr{}_no_phase_8bits.sample.identical.id1.id2' ::: $(seq 1 22)