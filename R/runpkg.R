#' Download the 'main' file from a package
#'
#' @param pkg the name (and optionally the version) of an npm package. (e.g. 'jquery', 'jquery@3.0.0')
#'
#' @return a [htmltools::htmlDependency] object
#'
#' @rdname download
#' @export
#' @md
#' @examples
#'
#' (fa <- download_main("fontawesome"))
#' htmltools::renderDependencies(list(fa), "href")
#' htmltools::renderDependencies(list(fa), "file")
#'

download_main <- function(pkg) {
  # TODO: the main file always has to be one file, right?
  info <- resolve_pkg(pkg)
  res <- httr::GET(info$url)
  file <- sub("https://unpkg.com/[^/]*/", "", res$url)
  dependify(file, info$name, info$version)
}


#' Download npm package files and convert them to HTML dependencies
#'
#' @inheritParams download_main
#' @param files character vector of paths to files (these paths should be relative to .
#'
#' @return a [htmltools::htmlDependency] object
#' @references <https://unpkg.com/#/>
#'
#' @rdname download
#' @export
#' @md
#' @examples
#'
#' (jquery <- download_files("jquery@3.0.0", "dist", "jquery.slim.min.js"))
#'
download_files <- function(pkg, files = NULL) {
  # return the main file (defined in pkg config) if no path is specified
  if (is.null(files)) return(download_main(pkg))
  info <- resolve_pkg(pkg)
  # TODO: ensure files have reasonable extensions?
  dependify(files, info$name, info$version)
}



#' List package files
#'
#' @inheritParams download_main
#' @param path a path to a folder.
#'
#' @return a [htmltools::htmlDependency] object
#' @references <https://unpkg.com/#/>
#'
#' @export
#' @md
#' @examples
#'
#' ls_("jquery")
#' ls_("jquery", "dist")
#' ls_("jquery@3.2.1", "external/sizzle")
#'
ls_ <- function(pkg, path = "/") {
  home <- resolve_pkg(pkg)
  # if '...' is empty, file.path(...) returns `character(0)`
  # ensure path ends with a trailing slash
  if (!grepl("/$", path)) path <- paste0(path, "/")
  href <- file.path(home$url, path)
  rvest::html_table(xml2::read_html(href))[[1]]
}

