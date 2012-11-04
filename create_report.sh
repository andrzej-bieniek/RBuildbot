RMDFILE=test

Rscript -e "require(knitr); require(markdown); knit('$RMDFILE.Rmd', '$RMDFILE.md'); markdownToHTML('$RMDFILE.md', '$RMDFILE.html', options=c('use_xhml', 'base64_images')); browseURL(paste('file://', file.path(getwd(),'$RMDFILE.html'), sep=''))"
