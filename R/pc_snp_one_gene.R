



#' Generate pc_snp for one gene
#'
#' Reads the assembled file from assembled dir, which contains the genotype information for each gene in the file
#' "gene_name.rds", run PCA, and write output to the three subdirectories, eigenvalue, loading, and pc_snp_score, under
#' pc_snp_dir.
#'
#'
#' @param gene Gene name
#' @param assembled_dir The directory containing assembled rds files
#' @param pc_snp_dir  The directory to which PCA analysis results will be written
#' @param freq_cut  Minor allele frequency cutoff for a SNP to be used for PC-SNP (in our case this is 0.005)
#' @param OPF_snp  Variance explained parameter (0.75 in our case) for PC-SNP dimension reduction
#'
#' @return  The return value of the function writing PCA results out
#' @export
#'
#' @examples
#'
#' pc_snp_one_gene(
#'   gene = "gene_20_2",
#'   assembled_dir = "tmpout/chrom_20/rds",
#'   pc_snp_dir ="tmpout/chrom_20/pc_snp",
#'   freq_cut =  0.005,
#'   OPF_snp = 0.75)
#'
#'
pc_snp_one_gene <- function(
    gene = "gene_20_2",
    assembled_dir = "tmpout/chrom_20/rds",
    pc_snp_dir ="tmpout/chrom_20/pc_snp",
    freq_cut =  0.005,
    OPF_snp = 0.75
){

  ########
  # Some cut off values
  VARCUT <- 2 * freq_cut * (1 - freq_cut)
  ########
  # Initialize the out list
  out <- list()
  out$eigenvalue$path <- fs::path(pc_snp_dir, "eigenvalue", gene)
  out$loading$path <- fs::path(pc_snp_dir, "loading", gene)
  out$score$path <- fs::path(pc_snp_dir, "pc_snp_score", gene)
  ########
  # Read in genotype data (X), filter by variance
  X_varcut <-
    readr::read_rds(path(assembled_dir, gene, ext = "rds")) |>   # Read in genotype for a gene
    dplyr::mutate(id = 1:n()) |>                              # Fill id column, the original values are all NA-- need to check
    tibble::column_to_rownames(var = "id") |>                # Turn "id" column to row name
    dplyr::select(where( ~ var(.x) > VARCUT)) |>                 # Select by variance
    tibble::as_tibble()
  ########
  # Run PCA and extract eigenvalue, loading, and pc_snp_score
  # Whether the gene has > 1 variants
  if (ncol(X_varcut) > 1){
    # run PCA
    pr <-
      X_varcut |>           # A data frame
      as.matrix() |>        # Convert to matrix
      jitter() |>           # Add noise
      stats::prcomp()              # Run PCA
    # Eigenevalues, corresponding to lambda and OFPcum_s in Osorio's code.
    out$eigenvalue$data <-
      broom::tidy(pr, matrix = "eigenvalues") |>
      # Simply filter by cumulative <= OPF_snp seems not ok since according to Osorio's code
      # the one row with smallest cumulative value larger than OPF_snp is kept.
      dplyr::filter(dplyr::lag(cumulative <= OPF_snp, default = TRUE)) |>
      dplyr::mutate(lambda = std.dev^2)
    # Loading, rotation, eigenvector
    out$loading$data <-
      broom::tidy(pr, matrix = "rotation") |>
      dplyr::filter(PC <= nrow(out$eigenvalue$data)) |>
      dplyr::rename(
        SNP_ID = column,
        loading = value
      )
    # OSNP,  score, the location of the observation in PCA space
    out$score$data <-
      broom::tidy(pr, matrix = "scores") |>
      dplyr::filter(PC <= nrow(out$eigenvalue$data)) |>
      dplyr::rename(
        Individual = row,
        score = value
      )
  } else if (ncol(X_varcut) == 1) {
    #if there was only a single SNP, then the PC-SNP is the SNP itself and lambda and the loadings is equal to 1 -#
    out$eigenvalue$data <- tibble::tibble(PC = 1,std.dev = sd(X_varcut[[1]]),percent = 1,cumulative = 1,lambda = var(X_varcut[[1]]))
    out$loading$data <- tibble::tibble(SNP_ID = colnames(X_varcut), PC = 1, loading=1)
    out$score$data <- X_varcut
  }
  ########
  ## Write out
  if (ncol(X_varcut) >= 1) {
    # Create the dir if not existed
    out |>
      purrr::walk(~ if (!fs::file_exists(fs::path_dir(.x$path)))
        fs::dir_create(fs::path_dir(.x$path)))

    # Write out
    out |>
      purrr::walk(~ readr::write_csv(.x$data, .x$path))
  }


}



