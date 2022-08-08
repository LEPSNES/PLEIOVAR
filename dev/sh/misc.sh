
# move vcftools output to specified dir for all chroms
ls -d chrom_tst* | parallel cd {}';' mkdir vcf_output';' mv "*012*" vcf_output
ls -d chrom_[1-9]* | parallel cd {}';' mkdir vcf_output';' mv "*012*" vcf_output


