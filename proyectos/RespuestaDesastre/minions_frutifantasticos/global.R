library(dplyr)


loadingLogo <- function(href, src, loadingsrc, height = NULL, width = NULL, alt = NULL) {
 tagList(
  tags$head(
   tags$script(
    "setInterval(function(){
      if ($('html').attr('class')=='shiny-busy') {
      $('div.busy').show();
      $('div.notbusy').hide();
      } else {
      $('div.busy').hide();
      $('div.notbusy').show();
      }
    },100)")
  ),
  tags$a(href=href,
         div(class = "busy",  
             img(src=loadingsrc,height = height, width = width, alt = alt)),
         div(class = 'notbusy',
             img(src = src, height = height, width = width, alt = alt))
  )
 )
}


data <- tibble(
  refugio = sample(letters, 200, replace = T),
  municipio = sample(LETTERS, 200, replace = T),
  lng = runif(200, min = -99.5, max = -99.3),
  lat = runif(200, min = 19.3, max = 19.5),
  telefono = sample(11111111:99999999, 200, replace = T)
)