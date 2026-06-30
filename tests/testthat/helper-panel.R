repo_path <- function(...) {
  file.path(normalizePath(file.path(testthat::test_path(), "..", "..")), ...)
}

read_repo_file <- function(...) {
  readLines(repo_path(...), warn = FALSE)
}

extract_main_arguments <- function(main_lines) {
  main_text <- paste(main_lines, collapse = "\n")
  matches <- regmatches(
    main_text,
    gregexpr(
      'parser\\$add_argument\\(\\s*"--([[:alnum:]_]+)"',
      main_text,
      perl = TRUE
    )
  )[[1]]

  sub('.*"--([[:alnum:]_]+)".*', "\\1", matches)
}

extract_panel_param_names <- function(panel_lines) {
  matches <- regmatches(
    panel_lines,
    gregexpr('"param_name"[[:space:]]*:[[:space:]]*"([[:alnum:]_]+)"', panel_lines)
  )
  matches <- unlist(matches, use.names = FALSE)

  sub('.*"param_name"[[:space:]]*:[[:space:]]*"([[:alnum:]_]+)".*', "\\1", matches)
}

extract_panel_default <- function(panel_lines, param_name) {
  param_line <- grep(sprintf('"param_name"[[:space:]]*:[[:space:]]*"%s"', param_name), panel_lines)
  if (length(param_line) != 1) {
    return(NA_character_)
  }

  next_param <- grep('"param_name"[[:space:]]*:', panel_lines)
  next_param <- next_param[next_param > param_line]
  end_line <- if (length(next_param) > 0) next_param[[1]] - 1 else length(panel_lines)
  block <- panel_lines[param_line:end_line]
  default_line <- grep('"default_value"[[:space:]]*:', block, value = TRUE)
  if (length(default_line) != 1) {
    return(NA_character_)
  }

  sub('.*"default_value"[[:space:]]*:[[:space:]]*"([^"]*)".*', "\\1", default_line)
}

expect_same_values <- function(actual, expected, info = NULL) {
  testthat::expect_setequal(actual, expected)
  testthat::expect_equal(length(actual), length(unique(actual)), info = "Values should not be duplicated")
}