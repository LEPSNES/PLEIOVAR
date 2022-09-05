#!/usr/local/bin/zsh

# The script accept three arguments: the dir of vcf files; the dir of gene files; the output dir.
# The vcf dir should include zipped chrom-wise vcf file with naming format Sardinia.b37.ss2120.FAref.impv4.chr${i}.vcf.gz
# The gene dir should include bed files with naming format chrom_${i}.bed
# The assembled file dir includes the outputs, a subdir for each chrom.
# Command example
# zsh inst/shellscript/get_genewise_genotype_via_vcftools.sh inst/extdata/vcf/Sardinia.b37.ss2120.FAref.impv4.chr20.vcf.gz  inst/extdata/gene/chrom_20.bed  result/chrom_20/vcftools_output 30


vcf_file=$1
gene_file=$2
out_dir=$3
job_num=$4

echo "vcf file: ${vcf_file}"
echo "gene file: ${gene_file}"
echo "out dir: ${out_dir}"

# Increase the number of open file descriptors, specific for each tty
ulimit -n 30000


# Run vcftools paralelly
cat ${gene_file} | \
parallel --jobs ${job_num} --colsep=$'\t' \
vcftools --gzvcf ${vcf_file}  \
--chr {1} \
--from-bp {2} \
--to-bp {3} \
--remove-filtered-all \
--012 \
--out  ${out_dir}/{4}
