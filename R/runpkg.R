#' Download files from npm packages via unpkg
#'
#' @param pkg the name (and optionally the version) of an npm package. (e.g. 'jquery', 'jquery@3.0.0')
#' @param files character vector of paths to files. These are used as the `:file`
#' part of <https://unpkg.com/:package@:version/:file>
#'
#' @return a [htmltools::htmlDependency] object
#' @references <https://unpkg.com>
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
#'
#' (jquery <- download_files("jquery@3.0.0", "dist/jquery.slim.min.js"))
#'
download_main <- function(pkg) {
  # TODO: the main file always has to be one file, right?
  info <- resolve_pkg(pkg)
  dependify(info$main, info$name, info$version)
}

#' @rdname download
#' @export
#' @md
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
#' @param path character string with a path pointing to a package folder. This
#' is used as the `:file` part of `https://unpkg.com/:package@:version/:file`
#'
#' @return a [htmltools::htmlDependency] object
#' @seealso [download_files]
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
