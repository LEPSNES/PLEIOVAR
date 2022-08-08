#!/usr/local/bin/zsh

# Increase the number of open file descriptors, specific for each tty
ulimit -n 30000

#for i in $(seq 20 22); do 
for i in $(seq 1 22); do 
  echo "start chrom_${i}:  $(date)"
  # Check if output dir exists
  if [[ ! -e  ./assembled/variants_by_gene/chrom_${i} ]]; then
    mkdir -p ./assembled/variants_by_gene/chrom_${i} 
  fi

  # Run vcftools paralelly
  #head -n 20 ./data/gene/gene_by_chrom/chrom_${i}.bed | \
  cat ./data/gene/gene_by_chrom/chrom_${i}.bed | \
	sed '1d' | \
	parallel --jobs 90 --colsep=$'\t' \
	vcftools --gzvcf ./data/vcf/compressed/Sardinia.b37.ss2120.FAref.impv4.chr${i}.vcf.gz  \
	--chr {1} \
	--from-bp {2} \
	--to-bp {3} \
	--remove-filtered-all \
	--012 \
	--out  ./assembled/variants_by_gene/chrom_${i}/{4}
done



