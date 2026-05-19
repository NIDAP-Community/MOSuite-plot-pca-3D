#!/usr/bin/env Rscript
rlang::global_entrace()
library(argparse)
library(glue)
devtools::load_all('/code/MOSuite')
library(readr)
library(stringr)
library(dplyr)

# set up capsule environment
setup_capsule_environment()

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

# load multiOmicDataSet from data directory
moo <- load_moo_from_data_dir()

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
