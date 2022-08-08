#!/usr/local/bin/zsh

# The script accept three arguments: the dir of vcf files; the dir of gene files; the output dir.
# The vcf dir should include zipped chrom-wise vcf file with naming format Sardinia.b37.ss2120.FAref.impv4.chr${i}.vcf.gz  
# The gene dir should include bed files with naming format chrom_${i}.bed 
# The assembled file dir includes the outputs, a subdir for each chrom.
# Command example
# zsh pull_variants_by_gene_from_vcf_v2.sh ~/project/PLEIOVAR/PLEIOVAR_rpkg/inst/extdata/vcf  ~/project/PLEIOVAR/PLEIOVAR_rpkg/inst/extdata/gene   ~/project/PLEIOVAR/PLEIOVAR_rpkg/tmpout 1>~/project/PLEIOVAR/PLEIOVAR_rpkg/tmpout/pull_by_gene.log 2>~/project/PLEIOVAR/PLEIOVAR_rpkg/tmpout/vcftools_output.log 

# Arguments
vcf_dir=$1
gene_dir=$2
assembled_dir=$3
echo "vcf file dir: ${vcf_dir}"
echo "gene dir: ${gene_dir}"
echo "assembled file dir: ${assembled_dir}"

# Increase the number of open file descriptors, specific for each tty
ulimit -n 30000

#for i in $(seq 20 22); do 
for i in $(seq 1 22); do 
  # Check whether vcf file exists
  if [[ -e  ${vcf_dir}/Sardinia.b37.ss2120.FAref.impv4.chr${i}.vcf.gz  ]]; then
	  echo "start chrom_${i}:  $(date)"
	  # Check if output dir exists
	  if [[ ! -e  ${assembled_dir}/chrom_${i} ]]; then
	    mkdir -p ${assembled_dir}/chrom_${i} 
	  fi

	  # Run vcftools paralelly
	  #head -n 20 ${gene_dir}/chrom_${i}.bed | \
	  cat ${gene_dir}/chrom_${i}.bed | \
		sed '1d' | \
		parallel --jobs 90 --colsep=$'\t' \
		vcftools --gzvcf ${vcf_dir}/Sardinia.b37.ss2120.FAref.impv4.chr${i}.vcf.gz  \
		--chr {1} \
		--from-bp {2} \
		--to-bp {3} \
		--remove-filtered-all \
		--012 \
		--out  ${assembled_dir}/chrom_${i}/{4}
    else
        echo "Does not exist vcf file: Sardinia.b37.ss2120.FAref.impv4.chr${i}.vcf.gz  "
    fi
done


