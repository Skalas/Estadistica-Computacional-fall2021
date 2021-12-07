source("./src/utils/utils.R" , encoding = 'UTF-8')

df = load_df() %>% first.transform.data() %>% data_clean()
dfinal = df[[1]] %>% var_lat_lon()

saveRDS(dfinal, file = "./data/refugios_nayarit.rds")
saveRDS(df[[2]], file = "./data/verificar.rds")
