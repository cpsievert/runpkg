"%||%" <- function(x, y) {
  if (length(x)) x else y
}

# verify that the package exists and find the latest version (if not specified)
resolve_pkg <- function(pkg) {
  url <- paste0("https://unpkg.com/", pkg)
  res <- httr::GET(url)
  con <- httr::content(res)
  if (httr::http_error(res) && grepl("Cannot find package", con)) {
    stop(con, call = FALSE)
  }
  httr::warn_for_status(res)
  base_url <- sub("/$", "", strextract(res$url, "https://unpkg.com/[^/]*[/]?"))
  pieces <- strsplit(base_url, "@")[[1]]
  list(
    url = base_url,
    name = sub("https://unpkg.com/", "", pieces[[1]]),
    version = pieces[[2]],
    main = sub("https://unpkg.com/[^/]*/", "", res$url)
  )
}

# download hyperlink(s) and turn into an htmldependency
dependify <- function(files = NULL, name = NULL, version = NULL) {
  if (!length(files)) stop("files must be provided", call. = FALSE)

  base_url <- sprintf("https://unpkg.com/%s@%s", name, version)
  hrefs <- file.path(base_url, files)
  files_full <- file.path(runpkg_path(), files)

  ## TODO: support more content types?
  #types <- vapply(hrefs, content_type, character(1))
  #type_ok <- types %in% c("application/javascript", "application/json", "text/css")
  #if (!all(type_ok)) {
  #  browser()
  #  warning(
  #    "Only files with content-type 'application/javascript', 'application/json', and 'text/css' ",
  #    " are supported at the moment. \n",
  #    sprintf("These files have a different content-type: '%s'",
  #            paste(hrefs[!type_ok], collapse = "', '")),
  #    call. = FALSE
  #  )
  #}

  Map(download_file_, hrefs, files_full)

  # TODO: it's almost surely wrong to assume most everything is a script
  types <- vapply(hrefs, content_type, character(1))
  is_style <- types %in% "text/css"

  # htmlDependify
  htmltools::htmlDependency(
    name = name,
    version = version,
    src = c(href = base_url, file = runpkg_path()),
    # TODO: how to determine attachments?
    script = files[!is_style] %||% NULL,
    stylesheet = files[is_style] %||% NULL
  )
}

runpkg_path <- function() {
  # TODO: why is this set to knitr false by knitr???
  #if (!capabilities("cledit")) {
  #  stop(
  #    "Can't automatically determine a directory to download files on your machine. ",
  #    "Set `options(runpkg.path = 'a/suitable/path')`.", call. = FALSE
  #  )
  #}
  path <- getOption("runpkg.path", file.path(path.expand("~"), ".runkpg_cache"))
  if (!dir_exists(path)) dir.create(path)
  path
}

download_file_ <- function(url, destfile) {
  destdir <- dirname(destfile)
  if (!dir_exists(destdir)) dir.create(destdir, recursive = TRUE)
  download.file(url, destfile)
}

# find the content-type of a hyperlink
content_type <- function(href) {
  httr::HEAD(href)$headers$`content-type`
}

dir_exists <- function(paths) {
  utils::file_test("-d", paths)
}

strextract <- function(str, pattern) {
  regmatches(str, regexpr(pattern, str))
}
