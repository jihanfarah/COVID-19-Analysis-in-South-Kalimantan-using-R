# COVID-19 Analysis in South Kalimantan using R
## Overview
This project is adapted from [DQLab project](https://academy.dqlab.id/main/package/practice/253/0?pf=0). The COVID-19 pandemic began to spread in 2020 throughout the world, including Indonesia. The government has also started to form a special task force to deal with COVID-19 in Indonesia to inform the development of the spread of COVID-19. Therefore, the COVID-19 task force collects and provides data regarding COVID-19 that is visible to all. The data is presented in web form and visualization in the form of images on the covid19.go.id website. The website also provides all information regarding the development of COVID-19 in various provinces, including South Kalimantan.

## Project
### Accessing API and Status Code

```
library(httr)
set_config(config(ssl_verifypeer = 0L))
resp_kalsel <- GET("https://data.covid19.go.id/public/api/prov_detail_KALIMANTAN_SELATAN.json")
status_code(resp_kalsel)
```
#### Result

![image](https://user-images.githubusercontent.com/103634806/180125423-23263f70-2bc3-412b-8fa5-c80e4c9435f1.png)

It shows [200], which means that our request is accepted and the content is ready to extract.

### Extract Data

```
cov_kalsel_raw <- content(resp_kalsel, as="parsed", simplifyVector = TRUE)
names(cov_kalsel_raw)
```

#### Result

![image](https://user-images.githubusercontent.com/103634806/180127554-21ad4828-b0ed-4b24-84d1-d1f7de3bbebf.png)

### Check Total Case, Death and Recovery Percentage
```
#Cek total kasus, persentase meninggal dan sembuh
cov_kalsel_raw$kasus_total
cov_kalsel_raw$meninggal_persen
cov_kalsel_raw$sembuh_persen
```

#### Result

![image](https://user-images.githubusercontent.com/103634806/180128083-a60a5d37-be4c-40fc-aa0e-a7fa447ace48.png)

We get the information that per July 19th, 2022, the total case is 84733 with death percentage is 2.99% and recovery percentage is 96.17%. 

### More Information
```
#Informasi lebih lengkap
cov_kalsel <- cov_kalsel_raw$list_perkembangan
str(cov_kalsel)
head(cov_kalsel)
```

#### Result

![image](https://user-images.githubusercontent.com/103634806/180129144-947e374e-6998-4ac0-867c-1b9cdd234aa8.png)

![image](https://user-images.githubusercontent.com/103634806/180129172-2f5007f7-6fca-458f-9868-3b8638f4382e.png)

From the result, we have problems with the format of the date and inconsistency of column writing format. Then, we have to tidy up the data into better version.

### Tidy up data

We have several steps to tidy up the data:
- Delete the "DIRAWAT_OR_ISOLASI" and "AKUMULASI_DIRAWAT_OR_ISOLASI" columns
- Delete all columns that contain cumulative values
- Rename the column “KASUS” to “kasus_baru”
- Change the writing format of the "MENINGGAL" and "SEMBUH" columns to lowercase
- Correct the data in "tanggal" column

```
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
```
#### Result

![image](https://user-images.githubusercontent.com/103634806/180130288-d044c125-76f3-4e01-956b-4b10a11144a2.png)

### Make Graphic
#### Daily Cases
```
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
```

#### Result

![image](https://user-images.githubusercontent.com/103634806/180213524-43e2556c-3611-4ecb-8141-dfba4e0126b8.png)

From the graphic above, it can be concluded that so far the highest total cases are around July 2021 to August 2021 with the highest total cases reaching more than 800 people. Furthermore, total cases decrease in September 2021 and increase in February 2022 to March 2022 with the highest total cases above 750 people.

#### Daily Recovery

```
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
```

#### Result

![image](https://user-images.githubusercontent.com/103634806/180213628-175f5f7c-6131-4dd2-adcf-2a6e5d992ef6.png)

From the graphic above, it can be concluded that so far the highest total recovery are around July 2021 to August 2021 with the highest total recovery reaching more than 1125 people. 

#### Daily Death

```
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
```

#### Result

![image](https://user-images.githubusercontent.com/103634806/180213730-9f1a2184-fcc4-4bc0-8839-2048d6085bae.png)

From the graphic above, it can be concluded that so far the highest total death are around July 2021 to August 2021 with the highest total death reaching more than 45 people. 

### Weekly Cases

We will collect the data of weekly cases. We can use `lubricate` package to convert the daily data into weekly data.

```
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
```
#### Result

![image](https://user-images.githubusercontent.com/103634806/180214561-13ef8645-27fa-41f0-b7cc-ddce27e984c2.png)

Then, we can compare the data of this week with previous week.

```
cov_kalsel_pekanan <-
  cov_kalsel_pekanan %>% 
  mutate(
    jumlah_pekanlalu = dplyr::lag(jumlah, 1),
    jumlah_pekanlalu = ifelse(is.na(jumlah_pekanlalu), 0, jumlah_pekanlalu),
    lebih_baik = jumlah < jumlah_pekanlalu
  )
glimpse(cov_kalsel_pekanan)
```

#### Result

![image](https://user-images.githubusercontent.com/103634806/180215373-687c68a6-c356-46f1-8bc0-9e04477bfa8d.png)


### Weekly Cases Graph

From the weekly data, we can make the graph of weekly cases of COVID-19 in South Kalimantan for this year.

```
ggplot(cov_kalsel_pekanan[cov_kalsel_pekanan$tahun==2022,], aes(pekan_ke, jumlah, fill = lebih_baik)) + geom_col(show.legend = FALSE) + 
  scale_x_continuous(breaks = 1:29, expand = c(0, 0)) +
  scale_fill_manual(values = c("TRUE" = "seagreen3", "FALSE" = "salmon")) +
  labs(
    x = NULL,
    y = "Total Cases",
    title = "Weekly Cases of COVID-19 in South Kalimantan",
    subtitle = "Green columns show the new case is less than the previous week",
    caption = "Data source: covid.19.go.id"
  ) +
  theme(plot.title.position = "plot")
```
#### Result

![image](https://user-images.githubusercontent.com/103634806/180215478-aafd69c6-709b-459c-a61f-bea690fa6760.png)

### Case Accumulation

From the data we get, we can count the accumulation of each cases and see the newest accumumation. 

```
cov_kalsel_akumulasi <- 
  new_cov_kalsel %>% 
  transmute(
    tanggal,
    akumulasi_aktif = cumsum(kasus_baru) - cumsum(sembuh) - cumsum(meninggal),
    akumulasi_sembuh = cumsum(sembuh),
    akumulasi_meninggal = cumsum(meninggal)
  )

tail(cov_kalsel_akumulasi)
```

#### Result

![image](https://user-images.githubusercontent.com/103634806/180216609-62eedfcc-e0e1-41aa-9805-11d88936727f.png)

### Data Transformation

Because the format of `cov_kalsel_akumulasi` is wide, we will change the data into long format so we can compare each cases.

```
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
```

#### Result

![image](https://user-images.githubusercontent.com/103634806/180220514-c8f68e0d-3b43-4536-b517-ae69b75b29aa.png)

![image](https://user-images.githubusercontent.com/103634806/180220566-f4f903bb-ef68-4413-8c5f-e2b72e8e1f0e.png)

### Cases Comparation

```
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
```

#### Result

![image](https://user-images.githubusercontent.com/103634806/180221314-b6e56871-a94c-4006-b348-138b4630977e.png)

From the graph, we can conclude that the recovery cases are increasing each time. For active cases, there are two peaks of highest case accumulation and for death cases, there are no significant increase.
