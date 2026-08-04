setup_cli_workspace <- function(prefix = "mosuite_plot_pca_3d_test_") {
  workspace <- tempfile(prefix)
  dir.create(workspace)

  code_dir <- file.path(workspace, "code")
  data_dir <- file.path(workspace, "data")
  results_dir <- file.path(workspace, "results")
  dir.create(code_dir, recursive = TRUE)
  dir.create(data_dir, recursive = TRUE)
  dir.create(file.path(results_dir, "figures"), recursive = TRUE)
  dir.create(file.path(results_dir, "moo"), recursive = TRUE)

  repo_root <- normalizePath(
    file.path(testthat::test_path(), "..", ".."),
    mustWork = TRUE
  )

  test_data_file <- file.path(
    repo_root,
    "code",
    "MOSuite",
    "tests",
    "testthat",
    "data",
    "moo.rds"
  )

  expect_true(
    file.exists(test_data_file),
    info = paste("Test data file should exist at", test_data_file)
  )
  file.copy(test_data_file, file.path(data_dir, "moo.rds"), overwrite = TRUE)

  file.copy(
    file.path(repo_root, "code", "main.R"),
    file.path(code_dir, "main.R"),
    overwrite = TRUE
  )

  main_copy <- file.path(code_dir, "main.R")
  main_lines <- readLines(main_copy)
  main_lines <- gsub(
    "devtools::load_all('/code/MOSuite')",
    sprintf(
      "devtools::load_all('%s')",
      file.path(repo_root, "code", "MOSuite")
    ),
    main_lines,
    fixed = TRUE
  )
  writeLines(main_lines, main_copy)

  list(
    workspace = workspace,
    code_dir = code_dir,
    results_dir = results_dir,
    repo_root = repo_root
  )
}

expect_main_runs_with_count_type <- function(count_type) {
  setup <- setup_cli_workspace(paste0("mosuite_plot_pca_3d_", count_type, "_test_"))
  on.exit(unlink(setup$workspace, recursive = TRUE), add = TRUE)

  old_wd <- getwd()
  setwd(setup$code_dir)
  on.exit(setwd(old_wd), add = TRUE)

  exit_code <- system2(
    "Rscript",
    args = c("main.R", sprintf("--count_type=%s", count_type))
  )
  expect_equal(
    exit_code,
    0,
    info = paste("main.R should plot", count_type, "counts")
  )
}