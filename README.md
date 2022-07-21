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

### Extract data

```
cov_kalsel_raw <- content(resp_kalsel, as="parsed", simplifyVector = TRUE)
names(cov_kalsel_raw)
```

- Result

![image](https://user-images.githubusercontent.com/103634806/180127554-21ad4828-b0ed-4b24-84d1-d1f7de3bbebf.png)

### Check total case, death and recovery percentage
```
#Cek total kasus, persentase meninggal dan sembuh
cov_kalsel_raw$kasus_total
cov_kalsel_raw$meninggal_persen
cov_kalsel_raw$sembuh_persen
```

- Result

![image](https://user-images.githubusercontent.com/103634806/180128083-a60a5d37-be4c-40fc-aa0e-a7fa447ace48.png)

We get the information that per July 19th, 2022, the total case is 84733 with death percentage is 2.99% and recovery percentage is 96.17%. 


