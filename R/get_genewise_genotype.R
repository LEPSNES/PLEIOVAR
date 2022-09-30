#' Get genewise genotype via vcftools
#'
#' It sequentially loops over the chroms under vcf_dir, pulls the variants for each gene in the bed file
#' of the corresponding chrom located in gene_dir, which is parallelized using GNU parallel utility, and output to
#' out_dir/chrom_i/vcf_output. i is the chrom number.  One gene generates three files, gene.012, gene.012.indv, and gene.012.pos.
#'
#' @param vcf_dir  path to the dir including zipped chrom-wise vcf files with "chr[om_]*\\d+" in their names
#' @param gene_dir  path to the dir including bed files with naming format chrom_${i}.bed.  One bed file each chrom.
#' @param out_dir  path to the dir to store the outputs, a subdir, chrom_${i}/vcf_output, will created for each chrom.
#' @param job_num  Jobs to run parallely, passed down to GNU parallel utility
#' @param extension  Integer, the nucleotide amount to be extended at both ends
#'
#' @return The status of pwalk
#' @export
#'
#' @examples
#'
#' # Get the dir path
#' library(fs)
#' vcf_dir <- path_package("PLEIOVAR", "extdata", "vcf")
#' gene_dir <- path_package("PLEIOVAR", "extdata", "gene")
#' out_dir <- "result"
#' job_num <- 30
#' extension <- 50000
#' # Pull variants from vcf files
#' get_genewise_genotype(vcf_dir, gene_dir, out_dir, job_num, extension)
#'
#'
# get_genewise_genotype_via_vcftools <- function(
get_genewise_genotype <- function(
    vcf_dir=fs::path_package("PLEIOVAR", "extdata", "vcf"),
    gene_dir=fs::path_package("PLEIOVAR", "extdata", "gene"),
    out_dir="result",
    job_num=30,
    extension=50000
){
  ### Some parameters
  # Locate of shell script
  shell_script =  fs::path_package("PLEIOVAR", "shellscript", "get_genewise_genotype_via_vcftools.sh")
  # File to store shell script output from stdout (fd1)
  pullvar_log = "pull_variants.log"
  # File to store vcftools output from stderr (fd2)
  vcftools_log = "vcftools.log"
  ### Get vcf file path
  # vcf_files is a tiblle with two cols, chrom and vcf file path
  vcf_files <-
    fs::dir_ls(vcf_dir) |>                        # Get vcf file path
    purrr::map_chr(
      ~stringr::str_extract(.x, "chr[om_]*\\d+")       # A named char vector
    ) |>
    tibble::enframe(value = "chrom", name = "vcf") |> # A tibble
    dplyr::mutate(
      chrom = as.integer(stringr::str_extract(chrom, "\\d+")) # Convert chrom to integer
    ) |>
    dplyr::relocate(chrom)
  ### Get gene bed file path and extend gene range
  # gene_files is a tibble with three cols, chrom, gene, and gene_extended
  gene_files <-
    fs::dir_ls(gene_dir) |>
    purrr::map_chr(                                     # Extract chrom
      ~stringr::str_extract(.x, "chr[om_]*\\d+")
    ) |>
    tibble::enframe(value = "chrom", name = "gene") |>   # Convert to tibble
    dplyr::mutate(
      chrom = as.integer(stringr::str_extract(chrom, "\\d+"))  # Convert chrom to integer
    ) |>
    dplyr::rowwise() |>
    dplyr::mutate(                                     # Extend gene range by extension
      gene_extended =  extend_gene_bed(         # Store in the temp dir
        gene_bed_file = gene,
        gene_extended_dir = fs::dir_create(fs::path_temp("gene_extended")),
        extension
      )
    ) |>
    dplyr::relocate(chrom)
  ### Merge vcf and gene together
  # vcf_gene tible includes vcf, gene, and out_dir_by_chrom paths
  vcf_gene <-
    dplyr::full_join(vcf_files, gene_files, by="chrom") |>
    dplyr::mutate(
      out_dir_by_chrom = fs::dir_create(fs::path(out_dir, stringr::str_c("chrom_", chrom), "vcftools_output"))
    )
  ### Run the shell script
  # Pull genewise genotype via shell script
  vcf_gene |>
    purrr::pwalk(function(chrom, vcf, gene, gene_extended, out_dir_by_chrom) {
      # Log starting time
      readr::write_lines(
        stringr::str_c("start chrom", chrom, ": ", Sys.time()),
        file = stringr::str_c(out_dir, "/", pullvar_log),
        append = TRUE
      )
      # Call shell script
      system2(
        command = "zsh",
        args = c(
          shell_script,
          vcf,
          gene_extended,
          out_dir_by_chrom,
          job_num,
          stringr::str_c("1>>", out_dir, "/", pullvar_log),
          stringr::str_c("2>>", out_dir, "/", vcftools_log)
        ),
        wait = TRUE
      )
    } # Close function definition
    ) # Close pwalk

}





