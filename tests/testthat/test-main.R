test_that("Code Ocean panel uses named parameters accepted by main.R", {
  main_args <- extract_main_arguments(read_repo_file("code", "main.R"))
  panel_lines <- read_repo_file(".codeocean", "app-panel.json")
  panel_args <- extract_panel_param_names(panel_lines)

  expect_true(
    any(grepl('"named_parameters"[[:space:]]*:[[:space:]]*true', panel_lines)),
    info = "Code Ocean should pass parameters by name to main.R"
  )
  expect_same_values(
    panel_args,
    main_args,
    info = "Every app-panel param_name should match a main.R CLI argument"
  )
})

test_that("3D PCA capsule keeps expected PCA parameter contract", {
  main_lines <- read_repo_file("code", "main.R")
  panel_lines <- read_repo_file(".codeocean", "app-panel.json")

  shared_pca_args <- c(
    "count_type",
    "sub_count_type",
    "feature_id_colname",
    "sample_id_colname",
    "samples_to_rename",
    "group_colname",
    "label_colname",
    "principal_components",
    "point_size",
    "label_font_size",
    "color_values"
  )
  three_dimensional_args <- "plot_title"

  expect_same_values(
    extract_main_arguments(main_lines),
    c(shared_pca_args, three_dimensional_args),
    info = "3D PCA main.R should expose shared PCA args plus 3D-specific controls"
  )
  expect_match(paste(main_lines, collapse = "\n"), "plot_pca\\(")
  expect_equal(
    extract_panel_default(panel_lines, "principal_components"),
    "1,2,3"
  )
  expect_equal(extract_panel_default(panel_lines, "point_size"), "8")
  expect_equal(extract_panel_default(panel_lines, "label_font_size"), "24")
  expect_equal(extract_panel_default(panel_lines, "plot_title"), "PCA 3D")
})

test_that("3D PCA names colors by group before plotting", {
  main_text <- paste(read_repo_file("code", "main.R"), collapse = "\n")

  expect_match(main_text, "group_values <- sort\\(unique\\(as.character")
  expect_match(main_text, "stats::setNames")
  expect_match(main_text, "color_values\\[seq_along\\(group_values\\)\\]")
  expect_match(main_text, "color_values = color_values")
})

test_that("run wrapper prepares result directories and forwards CLI arguments", {
  run_lines <- read_repo_file("code", "run")
  run_text <- paste(run_lines, collapse = "\n")

  expect_match(run_text, "mkdir -p \\.\\./results/figures \\.\\./results/moo")
  expect_match(run_text, 'Rscript main\\.R "\\$@"')
})
