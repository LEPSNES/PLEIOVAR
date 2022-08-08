
# cd to PLEIOVAR dir since the paths in the scrip is hardcoded
cd /home/liz30/project/PLEIOVAR
# Run by zsh
# Version 1
zsh code/pull_variants_by_gene_from_vcf.sh 1>assembled/variants_by_gene/pull_by_gene.log 2>assembled/variants_by_gene/vcftools_output.log 
# Version 2
# The script accept three arguments: the dir of vcf files; the dir of gene files; the output dir.
zsh pull_variants_by_gene_from_vcf_v2.sh ~/project/PLEIOVAR/PLEIOVAR_rpkg/inst/extdata/vcf  ~/project/PLEIOVAR/PLEIOVAR_rpkg/inst/extdata/gene   ~/project/PLEIOVAR/PLEIOVAR_rpkg/tmpout 1>~/project/PLEIOVAR/PLEIOVAR_rpkg/tmpout/pull_by_gene.log 2>~/project/PLEIOVAR/PLEIOVAR_rpkg/tmpout/vcftools_output.log 

