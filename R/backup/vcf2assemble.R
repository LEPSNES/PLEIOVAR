


#' Pull variants by gene from vcf files
#'
#' It wraps a shell script, which sequentially loops over the chroms under vcf_dir, pulls the variants for each gene present in the bed file
#' of the corresponding chrom under gene_dir -- this step is parallelized using GNU parallel utility, and save the output to the subdirectory,
#' chrom_i/vcf_output, under out_dir. i is the chrom number.  One gene generates three files, gene.012, gene.012.indv, and gene.012.pos.
#'
#' @param vcf_dir  path to the dir including zipped chrom-wise vcf file with naming format Sardinia.b37.ss2120.FAref.impv4.chr${i}.vcf.gz
#' @param gene_dir  path to the dir including bed files with naming format chrom_${i}.bed.  One bed file each chrom.
#' @param out_dir  path to the dir to store the outputs, a subdir, chrom_${i}/vcf_output, will created for each chrom.
#'
#' @return The return value is an error code (0 for success). See the "value" section of system2 for details.
#' @export
#'
#' @examples
#' # Get the dir path
#' library(fs)
#' vcf_dir <- path_package("PLEIOVAR", "extdata", "vcf"),
#' gene_dir <- path_package("PLEIOVAR", "extdata", "gene"),
#' out_dir <- "tmpout"
#' # Pull variants from vcf files
#' vcf2assemble(vcf_dir, gene_dir, out_dir)


vcf2assemble <- function(
    vcf_dir = fs::path_package("PLEIOVAR", "extdata", "vcf"),
    gene_dir = fs::path_package("PLEIOVAR", "extdata", "gene"),
    out_dir = "tmpout"

){
    # Locate of shell script
    shell_script = fs::path_package("PLEIOVAR", "shellscript", "pull_variants_by_gene_from_vcf_v2.sh")
    # File to store shell script output from stdout (fd1)
    pullvar_log = "pull_variants.log"
    # File to store vcftools output from stderr (fd2)
    vcftools_log = "vcftools.log"
    # Run the shell script
    system2(
        command = "zsh",
        args = c(
            shell_script,
            vcf_dir,
            gene_dir,
            out_dir,
            stringr::str_c("1>", out_dir, "/", pullvar_log),
            stringr::str_c("2>", out_dir, "/", vcftools_log)
        )
    )

}

