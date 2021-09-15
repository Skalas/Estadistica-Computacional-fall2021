for (i in c('UA')){
    for (j in seq(1,2)){
        Sys.setenv(carrier=i, month=j)
        rmarkdown::render(
                       'Ejemplo.Rmd',
                       output_format = 'pdf_document',
                       output_file=paste0('reports/', i,'-',j, '.pdf')
                   )}
}
