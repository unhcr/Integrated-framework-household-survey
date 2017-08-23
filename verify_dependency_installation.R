#if(!require(devtools))
#  install.packages("devtools")
#  install.packages("lubridate")

require(devtools)

# 1. Find missing packages ----------

p <- c()
for (f in list.files(pattern = "Rmd$")) {
  t <- readLines(f)
  p <- unique(c(p, t[grepl("^(library|require)", t)]))

}
p <- gsub("library|require|\\(|\\)", "", p)
p <- gsub("\"", "", p)
m <- p[!p %in% installed.packages()[, 1]]

if (!length(m)) {
  message("All necessary packages are installed.")

} else {
  message("Missing Packages : ", paste0(m, collapse = ", "))

}

# 2. Install missing packages (CRAN ou GitHub) ----------------

thru_github <- c("lubridate", #"questionr",
                 "JLutils", "labelled")
#repo_github <- c("hadley", "juba", "larmarange", "larmarange")

#for (i in m[m %in% thru_github])
#  install_github(i, username = repo_github[which(thru_github == i)])

for (i in m[!m %in% thru_github])
  install.packages(i, dependencies = TRUE)

if (any(!p %in% installed.packages()[, 1]))
  warning("Some packages installation failed.")

# 3. Manually verify certain packages --------------

library(lubridate)
if (!exists("time_length"))
  install_github("hadley/lubridate")

#library(questionr)
#if (is.null(getS3method("odds.ratio", "numeric", TRUE)))
#  install_github("juba/questionr")

# 4. identify mininal required version of R ---------------

#' @source http://stackoverflow.com/a/30600526/635806
min_r <- function(packages) {
  req <- NULL

  for (p in packages) {
    # get dependencies for the package
    dep <- packageDescription(p, fields = "Depends")

    if (!is.na(dep)) {
      dep <- unlist(strsplit(dep, ","))

      r.dep <- dep[grep("R \\(", dep)]

      if (!length(r.dep))
        r.dep <- NA

    } else {
      r.dep <- NA
    }

    if (!is.na(r.dep))
      req <- c(req, r.dep)

  }

  return(req)

}

v = min_r(p)
v = gsub("\\s?R\\s\\(>=\\s|\\)", "", v)
v = sort(v)[length(sort(v))]

message(" R version required is ", v, " or more recent.")
