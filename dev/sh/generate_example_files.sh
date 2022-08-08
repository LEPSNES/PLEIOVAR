

############## Generate sample vcf files
# Process multiple chroms but not column selection and genotype substitution
seq 20 22 | parallel zcat /data/SardiNIA/vcf/compressed/Sardinia.b37.ss2120.FAref.impv4.chr{}.vcf.gz '|' head  -3000 '|' gz ip '>' PLEIOVAR_rpkg/inst/extdata/vcf/chr{}.gz
# Proces one chrom but with column selecton and genotype substitution
# VCF file is arranged by chrom position (row) x individual (column)
# The following command 1) Fetch columns 1-9 and 500-600; 2) Modify the 7th row (individual ID) by substitute the first digit for "ID" and 0 for 3; 3) modify genotype by substituting 0/0 for 1/0 and 0/1 for 1/1;
zcat /data/SardiNIA/vcf/compressed/Sardinia.b37.ss2120.FAref.impv4.chr22.vcf.gz | head -3000 | cut -f1-9,500-600 | sed -e ' 7s/\s[0-9]/\tID/g' -e '7s/0/3/g' -e '7s/1/2/g' -e 's/0\/0/1\/0/g' -e 's/0\/1/1\/1/g' | gzip > PLEIOVAR_rpkg/inst/extdata/vcf/Sardinia.b37.ss2120.FAref.impv4.chr22.vcf.gz

############## Generate gene bed file
zcat PLEIOVAR_rpkg/inst/extdata/vcf/Sardinia.b37.ss2120.FAref.impv4.chr20.vcf.gz | awk 'NR >7 && NR % 50 == 0 {print $1, $2}'| awk '{getline nl; print $0, nl}' | awk -v OFS='\t' '{print $1, $2, $4, "gene_"$1"_"NR}'  > PLEIOVAR_rpkg/inst/extdata/gene/chrom_20.bed
# Insert the title
sed -i '1i \chrom   chromStart      chromEnd        gene'  PLEIOVAR_rpkg/inst/extdata/gene/chr20.bed




