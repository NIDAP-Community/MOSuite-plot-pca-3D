#!/usr/bin/env Rscript
rlang::global_entrace()
library(argparse)
library(glue)
library(MOSuite)
library(readr)
library(stringr)
library(dplyr)

# set up results directory
results_dir <- file.path('..','results')
plots_dir <- file.path(results_dir, 'figures')
options(moo_plots_dir = plots_dir, moo_save_plots = TRUE)

# log installed packages & versions
pkg_versions <- tibble::as_tibble(installed.packages())
write_csv(pkg_versions, file.path(results_dir, 'r-packages.csv'))

# parse CLI arguments
parser <- ArgumentParser()

parser$add_argument("--count_type", type="character", default="filt")
parser$add_argument("--sub_count_type", type="character", default=NULL, help="Sub count type if count_type is a list")
parser$add_argument("--feature_id_colname", type="character", default=NULL, help="Column name for feature IDs")
parser$add_argument("--sample_id_colname", type="character", default=NULL, help="Column name for sample IDs")
parser$add_argument("--samples_to_rename", type="character", default="", help="Samples to rename in format old:new,old2:new2")
parser$add_argument("--group_colname", type="character", default="Group", help="Column name for sample groups")
parser$add_argument("--label_colname", type="character", default="Label", help="Column name for sample labels")
parser$add_argument("--principal_components", type="character", default="1,2,3", help="Principal components to plot (comma-separated)")
parser$add_argument("--point_size", type="integer", default=8, help="Size of points in plot")
parser$add_argument("--label_font_size", type="integer", default=24, help="Font size for labels")
parser$add_argument("--color_values", type="character", default="#5954d6,#e1562c,#b80058,#00c6f8,#d163e6,#00a76c,#ff9287,#008cf9,#006e00,#796880,#FFA500,#878500", help="Comma-separated color values")
parser$add_argument("--plot_title", type="character", default="PCA 3D", help="Title for the plot")

args <- parser$parse_args()

parse_optional_vector <- function(x) {
    if (is.null(x) || identical(x, "") || length(x) == 0) {
        return(NULL)
    }
    return(trimws(unlist(strsplit(x, ","))))
}

parse_vector_with_default <- function(x, default) {
    parsed <- parse_optional_vector(x)
    if (is.null(parsed)) {
        return(default)
    }
    return(parsed)
}

# validate inputs
regex_moo <- ".*\\.rds$"
data_files <- list.files(file.path('../data'), recursive = TRUE, full.names = TRUE)
moo_files <- Filter(\(x) str_detect(x, regex(regex_moo, ignore_case = TRUE)), data_files)

if (length(moo_files) == 0) {
    stop(glue("No files matching regex: {regex_moo}"))
}
moo_filename <- moo_files[1]
moo <- read_rds(moo_filename)
message(glue('Reading multiOmicDataSet from {moo_filename}'))
if (!inherits(moo, 'MOSuite::multiOmicDataSet')) {
    stop(glue('The input is not a multiOmicDataSet. class: {class(moo)}'))
}

# parse samples_to_rename
parse_samples_to_rename <- function(x) {
    if (is.null(x) || identical(x, "") || length(x) == 0) {
        return(NULL)
    }
    pairs <- trimws(unlist(strsplit(x, ",")))
    result <- list()
    for (pair in pairs) {
        parts <- trimws(unlist(strsplit(pair, ":")))
        if (length(parts) == 2) {
            result[[parts[1]]] <- parts[2]
        }
    }
    if (length(result) == 0) return(NULL)
    return(result)
}

# run MOSuite
plot_pca(
    moo,
    count_type = args$count_type,
    sub_count_type = args$sub_count_type,
    principal_components = as.integer(parse_optional_vector(args$principal_components)),
    feature_id_colname = args$feature_id_colname,
    sample_id_colname = args$sample_id_colname,
    samples_to_rename = parse_samples_to_rename(args$samples_to_rename),
    group_colname = args$group_colname,
    label_colname = args$label_colname,
    point_size = args$point_size,
    label_font_size = args$label_font_size,
    color_values = parse_optional_vector(args$color_values),
    plot_title = args$plot_title
)
