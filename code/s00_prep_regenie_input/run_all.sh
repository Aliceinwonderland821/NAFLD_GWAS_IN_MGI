#!/bin/bash
# This script run all steps in s00 directory
# runs like `./run_all.sh`

# step 1. prepare phenotype file
Rscript prepare_pheno_file.R Freeze6.xwalk.broad_sharable.covariates.txt.addNA.extract_covs.txt.match_demog.txt.add_NAFLD.ALL_sample.nomiss Freeze6.xwalk.broad_sharable.covariates.txt.addNA.extract_covs.txt.match_demog.txt.add_NAFLD.ALL_sample.nomiss.regenie

# step 2. prepare step1 input file
./step2_prepare_step1_input.sh

# step 3. correct bgen sample file
parallel 'Rscript correct_bgen_sample_file.R ${MGI_REGENIE_STEP2}Freeze6_TOPMed.UNFILTERED.xwalk.broad_sharable.chr{}.no_phase_new.sample ${MGI_REGENIE_STEP2}Freeze6_TOPMed.UNFILTERED.xwalk.broad_sharable.chr{}.no_phase_new.sample.identical.id1.id2' ::: $(seq 1 22)