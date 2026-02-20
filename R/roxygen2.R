#' @export
#' @importFrom roxygen2 roxy_tag_parse
roxy_tag_parse.roxy_tag_dev <- function(x) {
  roxygen2::tag_words_line(x)
}

#' Extension of the Rd roclet
#'
#' @export
super_rd <- function() {
  roxygen2::roclet(c("super_rd", "rd"))
}

#' @importFrom roxygen2 roclet_process
#' @export

roclet_process.roclet_super_rd <- function(x, blocks, env, base_path) {
  blocks <- lapply(blocks, handle_dev, env, base_path)
  NextMethod()
}

# This function "marks" blocks with a dev tag
# by changing their title
handle_dev <- function(block, env, base_path) {
  has_dev <- "dev" %in% purrr::map_chr(block$tags, "tag")
  if (!has_dev) {
    return(block)
  }
  block$tags <- purrr::map(block$tags, \(x) {
    if (x$tag == "title") {
      x$val <- paste("Internal function:", x$val)
    }
    x
  })

  block
}

#' @importFrom roxygen2 roclet_output
#' @export

roclet_output.roclet_super_rd <- function(x, results, base_path, ...) {
  results <- lapply_with_names(results, rbuild_ignore, base_path)
  NextMethod()
}

#' My helper function
#'
#' @param topic A roxygen2 topic
#' @param base_path Path on which roxygenize is run
#'
#' @returns No idea, the Rd roclet uses it
#'
#' @dev
rbuild_ignore <- function(topic, base_path) {
  has_dev <- startsWith(topic$sections$title$val, "Internal function: ")
  if (!has_dev) {
    return(topic)
  }

  # clean title
  new_title <- sub(
    "^Internal function: ",
    "",
    topic$sections$title$val
  )
  topic$sections$title <- NULL
  topic$add_section(roxygen2::rd_section("title", new_title))

  rbuild_ignore <- readLines(".Rbuildignore")
  new_line <- sprintf("^man/%s", topic$filename)
  if (!(new_line %in% rbuild_ignore)) {
    rbuild_ignore <- c(rbuild_ignore, new_line)
    writeLines(rbuild_ignore, ".Rbuildignore")
    cli::cli_alert_success("Rbuildignored {topic$filename}!")
  }

  topic
}

# https://github.com/gaborcsardi/roxygenlabs/blob/5a7e4449c28f9e423de3f4e8e1be9bc9080f4e52/R/themed-rd.R#L26
lapply_with_names <- function(X, FUN, ...) {
  structure(
    lapply(X, FUN, ...),
    names = names(X) %||% (if (is.character(X)) X)
  )
}
