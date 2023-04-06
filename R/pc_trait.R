
#' Generate the principal components for phenotypic traits
#'
#'Read in phenotype data, conduct principal component analysis, save out the loadings and the scores.
#'
#' @param pheno_file    phenotype data. The first column should be named "ID", followed by one phenotype per column
#' @param pc_trait_dir   The outputs are saved to this directory
#' @param OPF_trait    The threshold for filtering cumulative eigen values, i.e., the percentage of explained variances
#'
#' @return The return value of the function saving trait PC components
#' @export
#'
#' @examples
#'
#' pheno_file <- fs::path_package("PLEIOVAR", "extdata", "pheno", "mainpheno.dat")
#' # pc_trait_dir <- fs::path_package("PLEIOVAR", "result", "pc_trait")
#' pc_trait_dir <- fs::path("~/project/PLEIOVAR/PLEIOVAR_rpkg", "result", "pc_trait")
#' OPF_trait <-  0.99
#' pc_trait(pheno_file = pheno_file, pc_trait_dir = pc_trait_dir, OPF_trait = OPF_trait)
#'
pc_trait <- function(pheno_file = "extdata/pheno/mainpheno.dat",
                     pc_trait_dir ="result/pc_trait",
                     OPF_trait = 0.99) {
  # Read in phenotype data
  # The first column need to be "ID"
  pheno_data <- readr::read_delim(pheno_file, show_col_types = FALSE)

  if (ncol(pheno_data) == 2) {  # Only one phenotype since the first columns is "ID"
    loadings = "PC-Trait-1 1.00"
    # Scale the 2nd, i.e., phenotype column only
    # OTrait <- scale(pheno_data[, 2])[, 1]
    OTrait <- pheno_data[,1:2] |>
      purrr::modify_at(2, ~ scale(.x)[,1])
  } else {
    # Run principal components
    prW <-
      pheno_data |>
      # Convert "ID" column as rowname, whhich will be kept in the matrix
      tibble::column_to_rownames("ID") |>
      as.matrix() |>
      stats::prcomp()
    # eigenvalues filtered by cumulative percentage >= the cutoff, OPF_trait
    eigenvalue <-
      broom::tidy(prW, matrix = "eigenvalues") |>
      # Simply filter by cumulative <= OPF_snp seems not ok since according to Osorio's code
      # the one row with smallest cumulative value larger than OPF_snp is kept.
      dplyr::filter(dplyr::lag(cumulative <= OPF_trait, n = 1L, default = TRUE)) |>
      dplyr::mutate(lambda = std.dev ^ 2)
    # Loading, rotation, eigenvector
    loadings <-
      broom::tidy(prW, matrix = "rotation") |>
      dplyr::filter(PC <= nrow(eigenvalue)) |>
      dplyr::rename(pheno = column,
                    loading = value)
    # OTrait,  score, the location of the observation in PCA space
    OTrait <-
      broom::tidy(prW, matrix = "scores") |>
      dplyr::filter(PC <= nrow(eigenvalue)) |>
      dplyr::rename(Individual = row,
                    score = value) |>
      dplyr::mutate(score = round(score, digits = 2))
  }

  # Write out
  fs::dir_create(pc_trait_dir)
  readr::write_csv(loadings, fs::path(pc_trait_dir, "PC_Traits_loadings.txt"))
  readr::write_csv(OTrait, fs::path(pc_trait_dir, "PC_Traits.txt"))

}

