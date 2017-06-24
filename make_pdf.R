require(xml2)
require(stringr)

## Home page
index <- read_html("index.html", encoding = "UTF-8")
res <- as.character(xml_find_first(index, ".//article"))

## Identify chapter
divs <- xml_find_all(index, ".//div")
for (div in divs)
  if (!is.na(xml_attr(div, 'id')))
    if (xml_attr(div, 'id') == 'tdm')
      tdm <- div

chapitres <- xml_attr(xml_find_all(tdm, ".//a"), 'href')

## Get content from Chapter
for (chap in chapitres) {
  page <- read_html(chap, encoding = "UTF-8")
  contenu <- as.character(xml_find_first(page, ".//article"))
  rac <- str_sub(chap, 1, -6)
  contenu <- str_replace_all(contenu, 'id="TOC', 'class="TOC')
  contenu <- str_replace_all(contenu, 'id="', paste0('id="', rac, "_"))
  contenu <- str_replace_all(contenu, 'href="#', paste0('href="#', rac, "_"))
  contenu <- str_replace_all(contenu, '<article>', paste0('<article id="', rac, '">'))
  res <- paste(res, contenu, sep="\n")
}

# Some adjustments
res <- str_replace_all(res, '&#13;', '')
for (chap in chapitres) {
  rac <- str_sub(chap, 1, -6)
  res <- str_replace_all(res, paste0('href="', chap, '#'), paste0('href="#', rac, '_'))
  res <- str_replace_all(res, paste0('href="', chap, '"'), paste0('href="#', rac, '"'))
}

## Final Export 
before <- paste(readLines("include/pdf_before.html", encoding = "UTF-8"), collapse = "\n")
after <- paste(readLines("include/pdf_after.html", encoding = "UTF-8"), collapse = "\n")
res <- paste(before, res, after, sep="\n")
cat(res, file = "protection-assessment-toolkit.html", sep="\n")

## PDF Generation
system('prince protection-assessment-toolkit.html --javascript')
