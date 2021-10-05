library(dplyr)
library(stringr)
library(tidyr)
library(readxl)


data <- data %>% 
  separate(latitud,c("d","m","s_int","s_dec", "basura"), sep = "([°º'\\,ª.;\"])") %>% 
  separate(longitud, c("d_lg","m_lg","s_int_lg","s_dec_lg", "basura_lg"), sep = "([°º'\\,ª.;\"])") %>% 
  mutate(lat=as.numeric(d)+as.numeric(m)/60+as.numeric(s_int)/3600+as.numeric(s_dec)/360000,
         lng=as.numeric(d_lg)+as.numeric(m_lg)/60+as.numeric(s_int_lg)/3600+as.numeric(s_dec_lg)/360000) %>% 
  select(-c(d,m,s_int,s_dec, basura, d_lg, m_lg, s_int_lg, s_dec_lg,basura_lg))
