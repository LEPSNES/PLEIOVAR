## code to prepare `pc_snp` dataset goes here
## The test files for pc_snp step were prepared to include block files and assembled files. The gene names were
## masked with "gene1", "gene2", etc.  The preparation steps were recorded in the file /home/liz30/work/project/small_proj/PLEIOVAR/package/by_step/prepare_data.md.
## Under PLEIOVAR package, a folder inst/extdata/pc_snp was created and the files were copied here.
## These files can be access via the R command

system.file("extdata", "pc_snp", package = "PLEIOVAR")



# usethis::use_data(pc_snp, overwrite = TRUE)
