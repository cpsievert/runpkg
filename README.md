# runpkg




An R package for working with [unpkg](https://unpkg.com) -- content delivery network (CDN) for everything on [npm](https://www.npmjs.com/). The goal is to make it easy to find, download, and manage *any file* from any *npm package* in R by storing them as `htmltools::htmlDependency()` objects.

## Installation

**runpkg** is not available on CRAN, but you may install with:

```r
devtools::install_github('cpsievert/runpkg')
```

## Overview

Many npm packages distribute a ['main' file](https://docs.npmjs.com/files/package.json#main) which provides the 'primary entry point to the program'. The `download_main()` function downloads that file and returns a [`htmltools::htmlDependency()`](https://www.rdocumentation.org/packages/htmltools/versions/0.3.6/topics/htmlDependency) object, which makes it easy to incorporate these dependencies in other R projects that leverage **htmltools** (e.g., **shiny** and **htmlwidgets**).


```r
library(runpkg)
(jq_main <- download_main("jquery"))
#> List of 10
#>  $ name      : chr "jquery"
#>  $ version   : chr "3.2.1"
#>  $ src       :List of 2
#>   ..$ href: chr "https://unpkg.com/jquery@3.2.1"
#>   ..$ file: chr "/Users/cpsievert/.runkpg_cache"
#>  $ meta      : NULL
#>  $ script    : chr "dist/jquery.js"
#>  $ stylesheet: NULL
#>  $ head      : NULL
#>  $ attachment: NULL
#>  $ package   : NULL
#>  $ all_files : logi TRUE
#>  - attr(*, "class")= chr "html_dependency"

library(htmltools)
cat(renderDependencies(list(jq_main), "href"))
#> <script src="https://unpkg.com/jquery@3.2.1/dist/jquery.js"></script>
cat(renderDependencies(list(jq_main), "file"))
#> <script src="/Users/cpsievert/.runkpg_cache/dist/jquery.js"></script>
```

Sometimes you want/need additional files from a package, especially if that package distributes optional dependencies. In this case, you may want to see what other files are distributed with the package via the `ls_()` function:


```r
ls_("jquery")
#>           Name             Type     Size            Last Modified
#> 1  AUTHORS.txt       text/plain 11.22 kB 2017-03-20T19:01:15.000Z
#> 2  LICENSE.txt       text/plain   1.6 kB 2017-03-20T19:01:15.000Z
#> 3    README.md  text/x-markdown     2 kB 2017-03-20T19:01:58.000Z
#> 4   bower.json application/json    190 B 2017-03-20T19:01:15.000Z
#> 5         dist                -        -                        -
#> 6     external                -        -                        -
#> 7 package.json application/json  2.35 kB 2017-03-20T19:01:15.000Z
#> 8          src                -        -                        -
ls_("jquery", "dist")
#>                  Name                   Type      Size
#> 1                  ..                      -         -
#> 2             core.js application/javascript   11.2 kB
#> 3           jquery.js application/javascript 268.04 kB
#> 4       jquery.min.js application/javascript  86.66 kB
#> 5      jquery.min.map       application/json 131.67 kB
#> 6      jquery.slim.js application/javascript 215.26 kB
#> 7  jquery.slim.min.js application/javascript   69.6 kB
#> 8 jquery.slim.min.map       application/json 104.58 kB
#>              Last Modified
#> 1                        -
#> 2 2017-03-20T19:01:15.000Z
#> 3 2017-03-20T19:01:15.000Z
#> 4 2017-03-20T19:01:15.000Z
#> 5 2017-03-20T19:01:15.000Z
#> 6 2017-03-20T19:01:15.000Z
#> 7 2017-03-20T19:01:15.000Z
#> 8 2017-03-20T19:01:15.000Z
ls_("jquery@3.2.1", "external/sizzle")
#>          Name       Type    Size            Last Modified
#> 1          ..          -       -                        -
#> 2 LICENSE.txt text/plain 1.61 kB 2017-03-20T19:01:15.000Z
#> 3        dist          -       -                        -
```

Once you've targetted your file(s) of interest, use `download_files()` to acquire those files


```r
files <- c(
  "dist/jquery.slim.min.js",
  "external/sizzle/dist/sizzle.min.js"
)
jq_full <- download_files("jquery", files)
cat(renderDependencies(list(jq_full), "file"))
#> <script src="/Users/cpsievert/.runkpg_cache/dist/jquery.slim.min.js"></script>
#> <script src="/Users/cpsievert/.runkpg_cache/external/sizzle/dist/sizzle.min.js"></script>
```

## Storing local files

If you need to store your dependencies in a special location, provide a relevant path to the "runpkg.path" option:


```r
options(runpkg.path = system.file(package = "runpkg"))
(jq_main <- download_main("jquery"))
#> List of 10
#>  $ name      : chr "jquery"
#>  $ version   : chr "3.2.1"
#>  $ src       :List of 2
#>   ..$ href: chr "https://unpkg.com/jquery@3.2.1"
#>   ..$ file: chr "/Library/Frameworks/R.framework/Versions/3.4/Resources/library/runpkg"
#>  $ meta      : NULL
#>  $ script    : chr "dist/jquery.js"
#>  $ stylesheet: NULL
#>  $ head      : NULL
#>  $ attachment: NULL
#>  $ package   : NULL
#>  $ all_files : logi TRUE
#>  - attr(*, "class")= chr "html_dependency"
cat(renderDependencies(list(jq_main), "file"))
#> <script src="/Library/Frameworks/R.framework/Versions/3.4/Resources/library/runpkg/dist/jquery.js"></script>
```
