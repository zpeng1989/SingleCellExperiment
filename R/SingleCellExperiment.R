#' The SingleCellExperiment class
#'
#' The SingleCellExperiment class is designed to represent single-cell sequencing data.
#' It inherits from the \linkS4class{RangedSummarizedExperiment} class and is used in the same manner.
#' In addition, the class supports storage of dimensionality reduction results (e.g., PCA, t-SNE) via \code{\link{reducedDims}},
#' and storage of alternative feature types (e.g., spike-ins) via \code{\link{altExps}}.
#' 
#' @param ... Arguments passed to the \code{\link{SummarizedExperiment}} constructor to fill the slots of the base class.
#' @param reducedDims A list of any number of matrix-like objects containing dimensionality reduction results,
#' each of which should have the same number of rows as the output SingleCellExperiment object.
#' @param altExps A list of any number of \linkS4class{SummarizedExperiment} objects containing alternative Experiments,
#' each of which should have the same number of columns as the output SingleCellExperiment object.
#'
#' @details
#' In this class, rows should represent genomic features (e.g., genes) while columns represent samples generated from single cells.
#' As with any \linkS4class{SummarizedExperiment} derivative,
#' different quantifications (e.g., counts, CPMs, log-expression) can be stored simultaneously in the \code{\link{assays}} slot,
#' and row and column metadata can be attached using \code{\link{rowData}} and \code{\link{colData}}, respectively.
#'
#' The \code{\link{reducedDims}} and \code{\link{altExps}} concepts are the main extensions of the SingleCellExperiment class.
#' This enables formalized representation of data structures that are commonly encountered during single-cell data analysis.
#' Readers are referred to the specific documentation pages for more details.
#' 
#' A SingleCellExperiment can also be created by coercing from a \linkS4class{SummarizedExperiment}
#' or \linkS4class{RangedSummarizedExperiment} instance.
#'
#' @return A SingleCellExperiment object.
#'
#' @author
#' Aaron Lun and Davide Risso
#' 
#' @seealso
#' \code{\link{reducedDims}}, for representation of dimensionality reduction results.
#'
#' \code{\link{altExps}}, for representation of data for alternative feature sets.
#' 
#' \code{\link{sizeFactors}}, to store size factors for normalization.
#'
#' \code{?"\link{SCE-combine}"}, to combine or subset a SingleCellExperiment object.
#'
#' \code{?"\link{SCE-internals}"}, for developer use.
#' @examples
#' ncells <- 100
#' u <- matrix(rpois(20000, 5), ncol=ncells)
#' v <- log2(u + 1)
#' 
#' pca <- matrix(runif(ncells*5), ncells)
#' tsne <- matrix(rnorm(ncells*2), ncells)
#' 
#' sce <- SingleCellExperiment(assays=list(counts=u, logcounts=v),
#'     reducedDims=SimpleList(PCA=pca, tSNE=tsne))
#' sce
#' 
#' ## coercion from SummarizedExperiment
#' se <- SummarizedExperiment(assays=list(counts=u, logcounts=v))
#' as(se, "SingleCellExperiment")
#' 
#' @docType class
#' @aliases
#' coerce,SummarizedExperiment,SingleCellExperiment-method
#' coerce,RangedSummarizedExperiment,SingleCellExperiment-method
#' @export
#' @importFrom S4Vectors SimpleList 
#' @importFrom methods is as
#' @importFrom SummarizedExperiment SummarizedExperiment
#' @importClassesFrom SummarizedExperiment RangedSummarizedExperiment
SingleCellExperiment <- function(..., reducedDims=list(), altExps=list()) {
    se <- SummarizedExperiment(...)
    if(!is(se, "RangedSummarizedExperiment")) {
        se <- as(se, "RangedSummarizedExperiment")
    }
    .rse_to_sce(se, reducedDims, altExps)
}

#' @importFrom S4Vectors DataFrame SimpleList
#' @importClassesFrom S4Vectors DataFrame
#' @importFrom methods new
#' @importFrom BiocGenerics nrow ncol
.rse_to_sce <- function(rse, reducedDims=SimpleList(), altExps=SimpleList()) {
    old <- S4Vectors:::disableValidity()
    if (!isTRUE(old)) {
        S4Vectors:::disableValidity(TRUE)
        on.exit(S4Vectors:::disableValidity(old))
    }
    
    out <- new("SingleCellExperiment", rse, 
        int_elementMetadata=new("DFrame", nrows=nrow(rse)),
        int_colData=new("DFrame", nrows=ncol(rse)))

    reducedDims(out) <- reducedDims
    altExps(out) <- altExps
    out
}

#' @exportMethod coerce
#' @importClassesFrom SummarizedExperiment RangedSummarizedExperiment
setAs("RangedSummarizedExperiment", "SingleCellExperiment", function(from) {
    .rse_to_sce(from)
})

#' @exportMethod coerce
#' @importClassesFrom SummarizedExperiment RangedSummarizedExperiment SummarizedExperiment
setAs("SummarizedExperiment", "SingleCellExperiment", function(from) {
    .rse_to_sce(as(from, "RangedSummarizedExperiment"))
})
