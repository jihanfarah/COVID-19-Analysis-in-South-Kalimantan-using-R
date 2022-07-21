library(httr)
set_config(config(ssl_verifypeer = 0L))
resp_kalsel <- GET("https://data.covid19.go.id/public/api/prov_detail_KALIMANTAN_SELATAN.json")
status_code(resp_kalsel)

cov_kalsel_raw <- content(resp_kalsel, as="parsed", simplifyVector = TRUE)
names(cov_kalsel_raw)

#Cek total kasus, persentase meninggal dan sembuh terbaru
cov_kalsel_raw$last_date
cov_kalsel_raw$kasus_total
cov_kalsel_raw$meninggal_persen
cov_kalsel_raw$sembuh_persen

#Informasi lebih lengkap
cov_kalsel <- cov_kalsel_raw$list_perkembangan
str(cov_kalsel)
head(cov_kalsel)

#Merapikan data
library(dplyr)
new_cov_kalsel <-
  cov_kalsel %>% 
  select(-contains("DIRAWAT_OR_ISOLASI")) %>% 
  select(-starts_with("AKUMULASI")) %>% 
  rename(
    kasus_baru = KASUS,
    meninggal = MENINGGAL,
    sembuh = SEMBUH
  ) %>% 
  mutate(
    tanggal = as.POSIXct(tanggal / 1000, origin = "1970-01-01"),
    tanggal = as.Date(tanggal)
  )
str(new_cov_kalsel)  

#Membuat grafik
library(ggplot2)
library(hrbrthemes)
ggplot(data = new_cov_kalsel, aes(x = tanggal, y = kasus_baru)) +
  geom_col()

#Grafik kasus harian positif
ggplot(new_cov_kalsel, aes(tanggal, kasus_baru)) +
  geom_col(fill="salmon")+
  labs(
    x=NULL,
    y="Total cases",
    title="Daily Cases of COVID-19 in South Kalimantan",
    caption="Data source: covid.19.go.id"
  )+
  theme(plot.title.position="plot")

#Grafik kasus sembuh
ggplot(new_cov_kalsel, aes(tanggal,sembuh)) +
  geom_col(fill = "olivedrab2") +
  labs(
    x = NULL,
    y = "Total Cases",
    title = "Daily Recovery of COVID-19 in South Kalimantan",
    caption = "Data source: covid.19.go.id"
  ) +
  theme(plot.title.position = "plot")

#Grafik kasus meninggal
ggplot(new_cov_kalsel, aes(tanggal, meninggal)) +
  geom_col(fill = "darkslategray4") +
  labs(
    x = NULL,
    y = "Total cases",
    title = "Daily Death of COVID-19 in South Kalimantan",
    caption = "Data source: covid.19.go.id"
  ) +
  theme(plot.title.position = "plot")

#Apakah pekan ini lebih baik?
library(lubridate)

cov_kalsel_pekanan <- new_cov_kalsel %>% 
  count(
    tahun = year(tanggal),
    pekan_ke = week(tanggal),
    wt = kasus_baru,
    name = "jumlah"
  )

glimpse(cov_kalsel_pekanan)

cov_kalsel_pekanan <-
  cov_kalsel_pekanan %>% 
  mutate(
    jumlah_pekanlalu = dplyr::lag(jumlah, 1),
    jumlah_pekanlalu = ifelse(is.na(jumlah_pekanlalu), 0, jumlah_pekanlalu),
    lebih_baik = jumlah < jumlah_pekanlalu
  )
glimpse(cov_kalsel_pekanan)

ggplot(cov_kalsel_pekanan[cov_kalsel_pekanan$tahun==2022,], aes(pekan_ke, jumlah, fill = lebih_baik)) + geom_col(show.legend = FALSE) + 
  scale_x_continuous(breaks = 1:29, expand = c(0, 0)) +
  scale_fill_manual(values = c("TRUE" = "seagreen3", "FALSE" = "salmon")) +
  labs(
    x = NULL,
    y = "Total Cases",
    title = "Weekly Cases of COVID-19 in South Kalimantan",
    subtitle = "Green columns show the new case is increasing less than a week before",
    caption = "Data source: covid.19.go.id"
  ) +
  theme(plot.title.position = "plot")

cov_kalsel_akumulasi <- 
  new_cov_kalsel %>% 
  transmute(
    tanggal,
    akumulasi_aktif = cumsum(kasus_baru) - cumsum(sembuh) - cumsum(meninggal),
    akumulasi_sembuh = cumsum(sembuh),
    akumulasi_meninggal = cumsum(meninggal)
  )

tail(cov_kalsel_akumulasi)

library(ggplot2)
ggplot(data = cov_kalsel_akumulasi, aes(x = tanggal, y = akumulasi_aktif)) +
  geom_line()

#Transformasi data
library(dplyr)
library(tidyr)

dim(cov_kalsel_akumulasi)

cov_kalsel_akumulasi_pivot <- 
  cov_kalsel_akumulasi %>% 
  gather(
    key = "kategori",
    value = "jumlah",
    -tanggal
  ) %>% 
  mutate(
    kategori = sub(pattern = "akumulasi_", replacement = "", kategori)
  )

dim(cov_kalsel_akumulasi_pivot)

glimpse(cov_kalsel_akumulasi_pivot)

ggplot(cov_kalsel_akumulasi_pivot, aes(tanggal, jumlah, colour=(kategori))) + 
  geom_line(size=0.9)+
  scale_y_continuous(sec.axis=dup_axis(name=NULL))+
  scale_colour_manual(
    values=c(
      "aktif"="salmon",
      "meninggal"="darkslategray4",
      "sembuh"="olivedrab2"
    ),
    labels=c("Active", "Death", "Recover")
  )+
  labs(
    x=NULL,
    y="Cases accumulation",
    colour=NULL,
    title="Case Dynamics of COVID-19 in South Kalimantan",
    caption="Data source: covid.19.go.id"
  )+
  theme(
    plot.title=element_text(hjust=0.5),
    legend.position="top")

