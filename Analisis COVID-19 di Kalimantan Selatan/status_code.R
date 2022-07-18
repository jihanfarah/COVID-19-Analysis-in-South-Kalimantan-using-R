library(httr)
set_config(config(ssl_verifypeer = 0L))
resp_kalsel <- GET("https://data.covid19.go.id/public/api/prov_detail_KALIMANTAN_SELATAN.json")
status_code(resp_kalsel)
