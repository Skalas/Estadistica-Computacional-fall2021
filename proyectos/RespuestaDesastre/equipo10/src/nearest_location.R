library(geosphere)

nearest_location <- function(df, user_long, user_lat, n_shelters=10){
  nearest_data <-
    df %>%
    mutate(USER_LONG = user_long,
           USER_LAT = user_lat,
           DISTANCE = distHaversine(cbind(LONGITUD,LATITUD), cbind(USER_LONG,USER_LAT))/1000
    ) %>% 
    arrange(DISTANCE) %>%
    head(n_shelters) %>% 
    select(LONGITUD, LATITUD, USER_LONG, USER_LAT, DISTANCE, No., REFUGIO,DIRECCIÓN, TELÉFONO)
  return(nearest_data)
}