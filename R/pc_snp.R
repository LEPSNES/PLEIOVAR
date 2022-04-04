#' Generate principle components for SNPs within genes
#'
#' This programs aims at selecting the SNPS from the SardiNIA vcf file which correspond to a specific gene region
#' After preprocessing was performed fom previous steps, we have a gene region dosage file for each gene
#' block files (one for each CPU when using multiple jobs in parallel) contain a list of all the genes in the block in UCSC format (chr,start,end,gene)
#' So, in summary, these block files are really subsets of the file All_Genes_hg19 which contains all the genes
#' Here is an example for the block file number 27 (out of a total of 64 blocks)
#' 7 137074384 137531609 DGKI
#'-7 137597556 137686847 CREB3L2
#'-7 137638093 137642712 LOC100130880
#'-7 137761177 137803050 AKR1D1
#' Of the block file described above, we use only the gene name so we can locate the corresponding gene region file {gene name}_assembled
#' Next, for each gene region (in the block) , read the "assembled" file for that gene and then we generate the PC-SNPs for each gene.
#'-Next, we perform a dimension reduction which results from a much smaller set of PC-SNPs than the number of SNPs in that gene region
#'
#' @param infolder This is the folder where the input files are located
#' @param outfolder This is the folder where the output results will be written to
#' @param OPF_snp variance explained parameter (0.75 in our case) for PC-SNP dimension reduction
#' @param freq_cut minor allele frequency cutoff for a SNP to be used for PC-SNP (in our case this is 0.005)
#' @param block_name the number of the block file
#'
#' @return No explicit returns specified yet
#' @export
#'
#' @examples
#'
#' infolder <- system.file("extdata", "pc_snp", package = "PLEIOVAR")
#' outfolder <- "dev/func_output"
#' OPF_snp <-  0.75
#' freq_cut <-  0.005
#' block_name <-  "blocktest"
#' pc_snp(infolder, outfolder, OPF_snp, freq_cut, block_name)
#'
# pc_snp <- function(infolder = "/home/liz30/work/project/small_proj/PLEIOVAR/package/by_step/data",
                   # outfolder = "/home/liz30/work/project/small_proj/PLEIOVAR/package/by_step/convert_PC-SNP/func_output",
pc_snp <- function(infolder = system.file("extdata", "pc_snp", package = "PLEIOVAR"),
                   outfolder = "dev/func_output",
                   OPF_snp = 0.75,
                   freq_cut = 0.005,
                   block_name = "blocktest") {

  # VARCUT is a cutoff that would exclude SNPs that might have a variance lower than  a threhold.
  # The advanteage of using this rather than minor allele frequency is that we could have an
  # allele frequency that is greater than the threshold
  # but has very low variance (and consequently, low information).
  # Not sure though if this makes much difference compared to using a MAF cutoff instead.
  VARCUT <- 2 * freq_cut * (1 - freq_cut)
  # infile is the folder where the block files are located
  infile <- fs::path(infolder, "Regions", block_name)
  # AA is the block file
  AA <- readr::read_delim(infile, col_names = FALSE, show_col_types=FALSE) %>%
    rlang::set_names(c("chr", "start", "end", "gene"))
  #--- here we loop for every gene in the block file #
  for (gene in AA$gene)
  {
    #- get chr and gene region file called {gene name}_assembled ---
    SNPfile <- stringr::str_c(infolder, "/Assemble/", gene, "_assembled")
    print(SNPfile)
    # the SNPfile (gene dosages for the gene) will only exist if there was at least one SNP in the gene from the SardiNIA dosage dataset
    if (file.exists(SNPfile)) {
      X <- readr::read_table(SNPfile, show_col_types = FALSE)
      # eliminate the SNPs that did not meet the variance threshold
      VarSnps_select <- X %>%
        dplyr::summarise(dplyr::across(-ID, ~ var(.) > VARCUT)) %>%
        rlang::flatten_lgl()
      X <- X[, c(TRUE, VarSnps_select)]

      # only do if at least one SNP at this stage --#
      # if (dim(X)[2] > 1) {
      if (ncol(X) > 1) {
        #- only do if at least two SNPs at this stage -#
        if (ncol(X) > 2) {
          #-- getting the dimensions of SNP dataset and insert small noise to overcome LD as SNPs with 100% correlation will crash when running PCA --#
          # browser()
          S <- X[, -1]
          noise <- matrix(stats::runif(nrow(S) * ncol(S), -0.0001, 0.0001), nrow(S), ncol(S))
          S <- S + noise
          #--- principal components of SNPs , loadings and lambdas (variance explained) ---#
          pr <- stats::prcomp(S)
          #--- getting the cummulative variance of PC-SNPs ---#
          lambda_all <- (pr$sdev)^2
          OPFcum_s <- cumsum(lambda_all) / sum(lambda_all)
          # GAOS's estimation of # of independent SNPs and # of PC-SNPS meeting cutoff #
          indep_SNPs <- min(which(OPFcum_s >= 0.995))
          #--- number of PC-SNPs needed to meet the varaince explained cutoff (#PC-SNP's with cummulative var explained > cutoff (0.75 in our case) #
          select_snp <- min(which(OPFcum_s >= OPF_snp))
          #- calculating cummulative variance explained to save into file later #
          OPFcum_s <- OPFcum_s[1:indep_SNPs]
          OPFcum_s <- floor(1000 * OPFcum_s + 0.5) / 1000
          #- OSNP is the set of PC-SNPS after dimension reduction and round off OSNP to neighest hundreth ---#
          OSNP <- pr$x[, 1:select_snp] %>%
            as.matrix()
          OSNP <- floor(100 * OSNP + 0.5) / 100
          colnames(OSNP) <- stringr::str_c("PC_SNP-", 1:select_snp)
          OSNP <- cbind(X[, "ID"], OSNP)
          #--- lambda now is the variance explained only for the PC-SNPS that met the threshold #
          lambda <- (lambda_all / sum(lambda_all))[1:select_snp]

          loadings <- pr$rotation
          loadings <- floor(10000 * loadings + 0.5) / 10000
          loadings <- loadings[1:select_snp, ]
        } else {
          #--- if there was only a single SNP, then the PC-SNP is the SNP itself and lambda and the loadings is equal to 1 -#
          OSNP <- X
          OPFcum_s <- 1
          loadings <- 1
          lambda <- 1
        }

        # Create outfolder if it does not exist
        if(! fs::dir_exists(outfolder)) fs::dir_create(outfolder)

        #-- output folder for PC-SNP_{gene name} files and saved on the PC-SNP folder
        outfile1 <- paste(outfolder, "/PC-SNPS/PC-SNP_", gene, sep = "")
        if(! fs::dir_exists(fs::path_dir(outfile1))) fs::dir_create(fs::path_dir(outfile1))
        #-- output folder for PC-SNP_load_{gene name}.  Loadings files (paramters that generate the PC-SNPs when combined with the original SNPs (dosages) #
        outfile2 <- paste(outfolder, "/PC-SNPS_loadings/PC-SNP_load_", gene, sep = "")
        if(! fs::dir_exists(fs::path_dir(outfile2))) fs::dir_create(fs::path_dir(outfile2))
        #-- output folder for PC-SNP_var_{gene name} files.  These contain the cummulative variance explained (var explained PC-1, var explained PC-1 and PC-2, ... )
        outfile3 <- paste(outfolder, "/PC-SNPS_var_exp/PC-SNP_var_", gene, sep = "")
        if(! fs::dir_exists(fs::path_dir(outfile3))) fs::dir_create(fs::path_dir(outfile3))
        # lambdas are just the variance explained (non-cummulative) such as var-explained PC-1, var explained PC-2,
        outfile4 <- paste(outfolder, "/PC-SNPS_lambdas/PC-SNP_lambdas_", gene, sep = "")
        if(! fs::dir_exists(fs::path_dir(outfile4))) fs::dir_create(fs::path_dir(outfile4))
        # write OSNP (the PC-SNPs) to the PC-SNP file -#
        utils::write.table(OSNP, outfile1, col.names = TRUE, row.names = FALSE, quote = FALSE)
        #--  write the loadings to the loadings file ---#
        utils::write.table(loadings, outfile2, row.names = TRUE, col.names = FALSE, quote = FALSE)
        # write the cummulative lambdas into the PC-SNP_var files  -#
        utils::write.table(OPFcum_s, outfile3, col.names = FALSE, row.names = FALSE, quote = FALSE)
        #--  write the lambdas to the lambda file PC-SNP_lambda files---#
        utils::write.table(lambda, outfile4, col.names = FALSE, row.names = FALSE, quote = FALSE)
      }
    }
  }
}
