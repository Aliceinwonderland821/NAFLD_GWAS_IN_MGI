#!/bin/bash
# This script prepares phenotype file for regenie
# `./step1_prepare_pheno_file.sh`

# Freeze6.xwalk.broad_sharable.covariates.txt.addNA.extract_covs.txt.match_demog.txt.add_NAFLD.ALL_sample.nomiss
# Freeze6.xwalk.broad_sharable.covariates.txt.addNA.extract_covs.txt.match_demog.txt.add_NAFLD.EUR_sample.nomiss

Rscript prepare_pheno_file.R Freeze6.xwalk.broad_sharable.covariates.txt.addNA.extract_covs.txt.match_demog.txt.add_NAFLD.ALL_sample.nomiss Freeze6.xwalk.broad_sharable.covariates.txt.addNA.extract_covs.txt.match_demog.txt.add_NAFLD.ALL_sample.nomiss.regenie
Rscript prepare_pheno_file.R Freeze6.xwalk.broad_sharable.covariates.txt.addNA.extract_covs.txt.match_demog.txt.add_NAFLD.EUR_sample.nomiss Freeze6.xwalk.broad_sharable.covariates.txt.addNA.extract_covs.txt.match_demog.txt.add_NAFLD.EUR_sample.nomiss.regenie
