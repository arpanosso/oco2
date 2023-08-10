MODELOS DE APRENDIZADO DE MÁQUINA PARA A EMISSÃO DE CO<sub>2</sub> DO
SOLO EM ÁREAS AGRÍCOLAS NO BRASIL
================

#### *Panosso, A. R.; Costa, L. M.; Lima, L. R. ; Crispim, V. S.*

##### Financiamento: CNPq (311981/2020-8); CNPq (301606/2017-0); Fapesp (2016/03861-5)

<!-- README.md is generated from README.Rmd. Please edit that file -->

## Resumo do Trabalho

### Aquisição dos dados de CO<sub>2</sub> atmosférico (xCO2)

A aquisição de dados de X<sub>co2</sub> e SIF, e seus processamentos
iniciais pode ser encontrados no link:

#### <https://arpanosso.github.io/oco2/>

Para facilitar o acesso, os dodos foram adquiridos por meio do pacote
`{fco2}`.

``` r
## Instalando pacotes (se necessário)
# install.packages("devtools")
# Sys.getenv("GITHUB_PAT")
# Sys.unsetenv("GITHUB_PAT")
# Sys.getenv("GITHUB_PAT")
# devtools::install_github("arpanosso/fco2r")
library(readxl)
library(tidyverse)
library(geobr)
library(fco2r)
library(skimr)
library(tidymodels)
library(ISLR)
library(modeldata)
library(vip)
library(ggpubr)
source("R/my_fun.R")

# Definindo o plano de multisession
future::plan("multisession")
```

### Carregando os dados meteorológicos

``` r
dados_estacao <- read_excel("data-raw/xlsx/estacao_meteorologia_ilha_solteira.xlsx", na = "NA") 
glimpse(dados_estacao)
#> Rows: 1,826
#> Columns: 16
#> $ data    <dttm> 2015-01-01, 2015-01-02, 2015-01-03, 2015-01-04, 2015-01-05, 2~
#> $ Tmed    <dbl> 30.5, 30.0, 26.8, 27.1, 27.0, 27.6, 30.2, 28.2, 28.5, 29.9, 30~
#> $ Tmax    <dbl> 36.5, 36.7, 35.7, 34.3, 33.2, 36.4, 37.2, 32.4, 37.1, 38.1, 38~
#> $ Tmin    <dbl> 24.6, 24.5, 22.9, 22.7, 22.3, 22.8, 22.7, 24.0, 23.0, 23.3, 24~
#> $ Umed    <dbl> 66.6, 70.4, 82.7, 76.8, 81.6, 75.5, 65.8, 70.0, 72.9, 67.6, 66~
#> $ Umax    <dbl> 89.6, 93.6, 99.7, 95.0, 98.3, 96.1, 99.2, 83.4, 90.7, 97.4, 90~
#> $ Umin    <dbl> 42.0, 44.2, 52.9, 43.8, 57.1, 47.5, 34.1, 57.4, 42.7, 38.3, 37~
#> $ PkPa    <dbl> 97.2, 97.3, 97.4, 97.5, 97.4, 97.5, 97.4, 97.4, 97.4, 97.4, 97~
#> $ Rad     <dbl> 23.6, 24.6, 20.2, 21.4, 17.8, 19.2, 27.0, 15.2, 21.6, 24.3, 24~
#> $ PAR     <dbl> 496.6, 513.3, 430.5, 454.0, 378.2, 405.4, 565.7, 317.2, 467.5,~
#> $ Eto     <dbl> 5.7, 5.8, 4.9, 5.1, 4.1, 4.8, 6.2, 4.1, 5.5, 5.7, 5.9, 6.1, 6.~
#> $ Velmax  <dbl> 6.1, 4.8, 12.1, 6.2, 5.1, 4.5, 4.6, 5.7, 5.8, 5.2, 5.2, 4.7, 6~
#> $ Velmin  <dbl> 1.0, 1.0, 1.2, 1.0, 0.8, 0.9, 0.9, 1.5, 1.2, 0.8, 0.8, 1.2, 1.~
#> $ Dir_vel <dbl> 17.4, 261.9, 222.0, 25.0, 56.9, 74.9, 53.4, 89.0, 144.8, 303.9~
#> $ chuva   <dbl> 0.0, 0.0, 3.3, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.~
#> $ inso    <dbl> 7.9, 8.7, 5.2, 6.2, 3.4, 4.5, 10.5, 1.3, 6.3, 8.4, 8.6, 7.9, 1~
```

### Conhecendo a base de dados de CO<sub>2</sub> atmosférico

``` r
help(oco2_br)
glimpse(fco2r::oco2_br)
#> Rows: 37,387
#> Columns: 32
#> $ longitude                                                     <dbl> -70.5, -~
#> $ longitude_bnds                                                <chr> "-71.0:-~
#> $ latitude                                                      <dbl> -5.5, -4~
#> $ latitude_bnds                                                 <chr> "-6.0:-5~
#> $ time_yyyymmddhhmmss                                           <dbl> 2.014091~
#> $ time_bnds_yyyymmddhhmmss                                      <chr> "2014090~
#> $ altitude_km                                                   <dbl> 3307.8, ~
#> $ alt_bnds_km                                                   <chr> "0.0:661~
#> $ fluorescence_radiance_757nm_uncert_idp_ph_sec_1_m_2_sr_1_um_1 <dbl> 7.272876~
#> $ fluorescence_radiance_757nm_idp_ph_sec_1_m_2_sr_1_um_1        <dbl> 2.537127~
#> $ xco2_moles_mole_1                                             <dbl> 0.000394~
#> $ aerosol_total_aod                                             <dbl> 0.148579~
#> $ fluorescence_offset_relative_771nm_idp                        <dbl> 0.016753~
#> $ fluorescence_at_reference_ph_sec_1_m_2_sr_1_um_1              <dbl> 2.615319~
#> $ fluorescence_radiance_771nm_idp_ph_sec_1_m_2_sr_1_um_1        <dbl> 3.088582~
#> $ fluorescence_offset_relative_757nm_idp                        <dbl> 0.013969~
#> $ fluorescence_radiance_771nm_uncert_idp_ph_sec_1_m_2_sr_1_um_1 <dbl> 5.577878~
#> $ xco2                                                          <dbl> 394.3686~
#> $ data                                                          <dttm> 2014-09~
#> $ ano                                                           <dbl> 2014, 20~
#> $ mes                                                           <dbl> 9, 9, 9,~
#> $ dia                                                           <int> 6, 6, 6,~
#> $ dia_semana                                                    <dbl> 7, 7, 7,~
#> $ x                                                             <int> 7, 8, 11~
#> $ xco2_est                                                      <dbl> 392.7080~
#> $ delta                                                         <dbl> -1.66062~
#> $ XCO2                                                          <dbl> 387.2781~
#> $ flag_norte                                                    <lgl> TRUE, TR~
#> $ flag_nordeste                                                 <lgl> FALSE, F~
#> $ flag_sul                                                      <lgl> FALSE, F~
#> $ flag_sudeste                                                  <lgl> FALSE, F~
#> $ flag_centroeste                                               <lgl> FALSE, F~
```

Inicialmente devemos transformar os dados de concentração de
CO<sub>2</sub>, variável `xco2_moles_mole_1` para ppm em seguida devemos
criar as variáveis de data a partir da variável `time_yyyymmddhhmmss`.

``` r
oco2<-oco2_br  %>% 
         mutate(
           xco2 = xco2_moles_mole_1*1e06,
           data = ymd_hms(time_yyyymmddhhmmss),
           ano = year(data),
           mes = month(data),
           dia = day(data),
           dia_semana = wday(data))
```

Existe uma tendência de aumento monotônica mundial da concentração de
CO2 na atmosfera, assim, ela deve ser retirada para podermos observar as
tendências regionais.

``` r
oco2  %>%  
  ggplot(aes(x=data,y=xco2)) +
  geom_point(color="blue") +
  geom_line(color="red")
```

![](README_files/figure-gfm/unnamed-chunk-6-1.png)<!-- --> Agora devemos
retirar a tendência ao longo do tempo, para isso, dentro do período
específico, faremos a retirada por meio de um ajuste linear:

``` r
oco2  %>%  
  mutate(x= 1:nrow(oco2))  %>%  
  ggplot(aes(x=data,y=xco2)) +
  geom_point(shape=21,color="black",fill="gray") +
  geom_smooth(method = "lm") +
  stat_regline_equation(ggplot2::aes(
  label =  paste(..eq.label.., ..rr.label.., sep = "*plain(\",\")~~")))
```

![](README_files/figure-gfm/unnamed-chunk-7-1.png)<!-- -->

Extrair os coeficientes
![\alpha](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;%5Calpha "\alpha")
e
![\beta](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;%5Cbeta "\beta")
da análise de regressão linear
![(y=\alpha+\beta x)](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;%28y%3D%5Calpha%2B%5Cbeta%20x%29 "(y=\alpha+\beta x)").

``` r
modelo_linear_tendencia <- lm(xco2~data,
          data = oco2)
coefs <- modelo_linear_tendencia$coefficients
```

Criando a variável `xco2_est` a partir da retirada da tendência.

``` r
oco2 |> 
  mutate(
    xco2_est = coefs[1] + coefs[2] * as.numeric(data),
    delta = xco2_est - xco2,
    XCO2 = (coefs[1]-delta) - (mean(xco2) - coefs[1])
  ) 
#> # A tibble: 37,387 x 32
#>    longitude longitude_bnds latitude latitude_bnds time_yyyymmddhhmmss
#>        <dbl> <chr>             <dbl> <chr>                       <dbl>
#>  1     -70.5 -71.0:-70.0        -5.5 -6.0:-5.0                 2.01e13
#>  2     -70.5 -71.0:-70.0        -4.5 -5.0:-4.0                 2.01e13
#>  3     -69.5 -70.0:-69.0       -10.5 -11.0:-10.0               2.01e13
#>  4     -69.5 -70.0:-69.0        -9.5 -10.0:-9.0                2.01e13
#>  5     -69.5 -70.0:-69.0        -8.5 -9.0:-8.0                 2.01e13
#>  6     -69.5 -70.0:-69.0        -7.5 -8.0:-7.0                 2.01e13
#>  7     -69.5 -70.0:-69.0        -6.5 -7.0:-6.0                 2.01e13
#>  8     -69.5 -70.0:-69.0        -5.5 -6.0:-5.0                 2.01e13
#>  9     -68.5 -69.0:-68.0       -10.5 -11.0:-10.0               2.01e13
#> 10     -46.5 -47.0:-46.0        -1.5 -2.0:-1.0                 2.01e13
#> # i 37,377 more rows
#> # i 27 more variables: time_bnds_yyyymmddhhmmss <chr>, altitude_km <dbl>,
#> #   alt_bnds_km <chr>,
#> #   fluorescence_radiance_757nm_uncert_idp_ph_sec_1_m_2_sr_1_um_1 <dbl>,
#> #   fluorescence_radiance_757nm_idp_ph_sec_1_m_2_sr_1_um_1 <dbl>,
#> #   xco2_moles_mole_1 <dbl>, aerosol_total_aod <dbl>,
#> #   fluorescence_offset_relative_771nm_idp <dbl>, ...
glimpse(oco2)
#> Rows: 37,387
#> Columns: 32
#> $ longitude                                                     <dbl> -70.5, -~
#> $ longitude_bnds                                                <chr> "-71.0:-~
#> $ latitude                                                      <dbl> -5.5, -4~
#> $ latitude_bnds                                                 <chr> "-6.0:-5~
#> $ time_yyyymmddhhmmss                                           <dbl> 2.014091~
#> $ time_bnds_yyyymmddhhmmss                                      <chr> "2014090~
#> $ altitude_km                                                   <dbl> 3307.8, ~
#> $ alt_bnds_km                                                   <chr> "0.0:661~
#> $ fluorescence_radiance_757nm_uncert_idp_ph_sec_1_m_2_sr_1_um_1 <dbl> 7.272876~
#> $ fluorescence_radiance_757nm_idp_ph_sec_1_m_2_sr_1_um_1        <dbl> 2.537127~
#> $ xco2_moles_mole_1                                             <dbl> 0.000394~
#> $ aerosol_total_aod                                             <dbl> 0.148579~
#> $ fluorescence_offset_relative_771nm_idp                        <dbl> 0.016753~
#> $ fluorescence_at_reference_ph_sec_1_m_2_sr_1_um_1              <dbl> 2.615319~
#> $ fluorescence_radiance_771nm_idp_ph_sec_1_m_2_sr_1_um_1        <dbl> 3.088582~
#> $ fluorescence_offset_relative_757nm_idp                        <dbl> 0.013969~
#> $ fluorescence_radiance_771nm_uncert_idp_ph_sec_1_m_2_sr_1_um_1 <dbl> 5.577878~
#> $ xco2                                                          <dbl> 394.3686~
#> $ data                                                          <dttm> 2014-09~
#> $ ano                                                           <dbl> 2014, 20~
#> $ mes                                                           <dbl> 9, 9, 9,~
#> $ dia                                                           <int> 6, 6, 6,~
#> $ dia_semana                                                    <dbl> 7, 7, 7,~
#> $ x                                                             <int> 7, 8, 11~
#> $ xco2_est                                                      <dbl> 392.7080~
#> $ delta                                                         <dbl> -1.66062~
#> $ XCO2                                                          <dbl> 387.2781~
#> $ flag_norte                                                    <lgl> TRUE, TR~
#> $ flag_nordeste                                                 <lgl> FALSE, F~
#> $ flag_sul                                                      <lgl> FALSE, F~
#> $ flag_sudeste                                                  <lgl> FALSE, F~
#> $ flag_centroeste                                               <lgl> FALSE, F~
```

``` r
oco2  %>%  
  ggplot(aes(x=data,y=XCO2)) +
  geom_point(shape=21,color="black",fill="gray") +
  geom_smooth(method = "lm") +
  stat_regline_equation(ggplot2::aes(
  label =  paste(..eq.label.., ..rr.label.., sep = "*plain(\",\")~~")))
```

![](README_files/figure-gfm/unnamed-chunk-10-1.png)<!-- -->

### Alguns gráficos

``` r
# oco2 %>% 
#   sample_n(1000) %>% 
#   ggplot(aes(x = longitude, y = latitude)) + 
#   geom_point(color = "blue")
```

### Carregando o contorno do território

``` r
# br <- geobr::read_country(showProgress = FALSE)
```

### Construindo o mapa com os pontos

``` r
# br %>% 
#   ggplot() +
#   geom_sf(fill = "white") +
#     geom_point(data=oco2 %>% 
#                  sample_n(1000),
#              aes(x=longitude,y=latitude),
#              shape=3,
#              col="red",
#              alpha=0.2)
```

Observe que utilizamos `dplyr::sample_n()` para retirar apenas
![1000](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;1000 "1000")
amostras do total do banco de dados
![37387](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;37387 "37387").

#### Estatísticas descritivas

``` r
# skim(oco2_br)
```

### Conhecendo a base de dados de emissão de CO<sub>2</sub> do solo

``` r
# help(data_fco2)
glimpse(data_fco2)
#> Rows: 15,397
#> Columns: 39
#> $ experimento       <chr> "Espacial", "Espacial", "Espacial", "Espacial", "Esp~
#> $ data              <date> 2001-07-10, 2001-07-10, 2001-07-10, 2001-07-10, 200~
#> $ manejo            <chr> "convencional", "convencional", "convencional", "con~
#> $ tratamento        <chr> "AD_GN", "AD_GN", "AD_GN", "AD_GN", "AD_GN", "AD_GN"~
#> $ revolvimento_solo <lgl> FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FAL~
#> $ data_preparo      <date> 2001-07-01, 2001-07-01, 2001-07-01, 2001-07-01, 200~
#> $ conversao         <date> 1970-01-01, 1970-01-01, 1970-01-01, 1970-01-01, 197~
#> $ cobertura         <lgl> TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE~
#> $ cultura           <chr> "milho_soja", "milho_soja", "milho_soja", "milho_soj~
#> $ x                 <dbl> 0, 40, 80, 10, 25, 40, 55, 70, 20, 40, 60, 10, 70, 3~
#> $ y                 <dbl> 0, 0, 0, 10, 10, 10, 10, 10, 20, 20, 20, 25, 25, 30,~
#> $ longitude_muni    <dbl> 782062.7, 782062.7, 782062.7, 782062.7, 782062.7, 78~
#> $ latitude_muni     <dbl> 7647674, 7647674, 7647674, 7647674, 7647674, 7647674~
#> $ estado            <chr> "SP", "SP", "SP", "SP", "SP", "SP", "SP", "SP", "SP"~
#> $ municipio         <chr> "Jaboticabal", "Jaboticabal", "Jaboticabal", "Jaboti~
#> $ ID                <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 1~
#> $ prof              <chr> "0-0.1", "0-0.1", "0-0.1", "0-0.1", "0-0.1", "0-0.1"~
#> $ FCO2              <dbl> 1.080, 0.825, 1.950, 0.534, 0.893, 0.840, 1.110, 1.8~
#> $ Ts                <dbl> 18.73, 18.40, 19.20, 18.28, 18.35, 18.47, 19.10, 18.~
#> $ Us                <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, ~
#> $ pH                <dbl> 5.1, 5.1, 5.8, 5.3, 5.5, 5.7, 5.6, 6.4, 5.3, 5.8, 5.~
#> $ MO                <dbl> 20, 24, 25, 23, 23, 21, 26, 23, 25, 24, 26, 20, 25, ~
#> $ P                 <dbl> 46, 26, 46, 78, 60, 46, 55, 92, 55, 60, 48, 71, 125,~
#> $ K                 <dbl> 2.4, 2.2, 5.3, 3.6, 3.4, 2.9, 4.0, 2.3, 3.3, 3.6, 4.~
#> $ Ca                <dbl> 25, 30, 41, 27, 33, 38, 35, 94, 29, 36, 37, 29, 50, ~
#> $ Mg                <dbl> 11, 11, 25, 11, 15, 20, 16, 65, 11, 17, 15, 11, 30, ~
#> $ H_Al              <dbl> 31, 31, 22, 28, 27, 22, 22, 12, 31, 28, 28, 31, 18, ~
#> $ SB                <dbl> 38.4, 43.2, 71.3, 41.6, 50.6, 60.9, 55.0, 161.3, 43.~
#> $ CTC               <dbl> 69.4, 74.2, 93.3, 69.6, 77.9, 82.9, 77.0, 173.3, 74.~
#> $ V                 <dbl> 55, 58, 76, 60, 65, 73, 71, 93, 58, 67, 67, 58, 82, ~
#> $ Ds                <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, ~
#> $ Macro             <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, ~
#> $ Micro             <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, ~
#> $ VTP               <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, ~
#> $ PLA               <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, ~
#> $ AT                <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, ~
#> $ SILTE             <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, ~
#> $ ARG               <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, ~
#> $ HLIFS             <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, ~
```

### Visualização de dados

``` r
data_fco2 %>% 
  group_by(experimento, cultura, data) %>% 
  summarise(FCO2 = mean(FCO2, na.rm=TRUE)) %>% 
  ggplot(aes(y=FCO2, x=data)) +
  geom_line() +
   facet_wrap(~experimento + cultura, scale="free")
```

![](README_files/figure-gfm/unnamed-chunk-16-1.png)<!-- -->

### Construindo o mapa com os pontos

``` r
# br %>% 
#   ggplot() +
#   geom_sf(fill = "white") +
#     geom_point(data=oco2 %>% sample_n(1000),
#              aes(x=longitude,y=latitude),
#              shape=3,
#              col="red",
#              alpha=0.2)
```

Observe que utilizamos `dplyr::sample_n()` para retirar apenas
![1000](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;1000 "1000")
amostras do total do banco de dados
![146,646](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;146%2C646 "146,646").

#### Estatísticas descritivas

``` r
# skim(data_fco2)
```

``` r
visdat::vis_miss(data_fco2 %>% 
                   sample_n(15000))
```

![](README_files/figure-gfm/unnamed-chunk-19-1.png)<!-- -->

#### Estatísticas descritivas

``` r
# skim(dados_estacao)
```

``` r
dados_estacao <- dados_estacao %>% 
                   drop_na()
visdat::vis_miss(dados_estacao)
```

![](README_files/figure-gfm/unnamed-chunk-21-1.png)<!-- -->

``` r
# Lista do xCO2
# 01 passar as datas que estão em ano-mes-dia-horas-min-segundos
# para uma outra coluna denominada 'data' como ano-mes-dia
# Fazer em pipeline, usar o mutate do pacote dplyr e provavelmente
# a funçoes do pacote lubridate
oco2 <- oco2  %>% 
  mutate (
    ano = time_yyyymmddhhmmss%/%1e10,
    mês = time_yyyymmddhhmmss%/%1e8 %%100,
    dia = time_yyyymmddhhmmss%/%1e6 %%100,
    data = as.Date(stringr::str_c(ano,mês,dia,sep="-"))
  ) %>% 
  glimpse()
#> Rows: 37,387
#> Columns: 33
#> $ longitude                                                     <dbl> -70.5, -~
#> $ longitude_bnds                                                <chr> "-71.0:-~
#> $ latitude                                                      <dbl> -5.5, -4~
#> $ latitude_bnds                                                 <chr> "-6.0:-5~
#> $ time_yyyymmddhhmmss                                           <dbl> 2.014091~
#> $ time_bnds_yyyymmddhhmmss                                      <chr> "2014090~
#> $ altitude_km                                                   <dbl> 3307.8, ~
#> $ alt_bnds_km                                                   <chr> "0.0:661~
#> $ fluorescence_radiance_757nm_uncert_idp_ph_sec_1_m_2_sr_1_um_1 <dbl> 7.272876~
#> $ fluorescence_radiance_757nm_idp_ph_sec_1_m_2_sr_1_um_1        <dbl> 2.537127~
#> $ xco2_moles_mole_1                                             <dbl> 0.000394~
#> $ aerosol_total_aod                                             <dbl> 0.148579~
#> $ fluorescence_offset_relative_771nm_idp                        <dbl> 0.016753~
#> $ fluorescence_at_reference_ph_sec_1_m_2_sr_1_um_1              <dbl> 2.615319~
#> $ fluorescence_radiance_771nm_idp_ph_sec_1_m_2_sr_1_um_1        <dbl> 3.088582~
#> $ fluorescence_offset_relative_757nm_idp                        <dbl> 0.013969~
#> $ fluorescence_radiance_771nm_uncert_idp_ph_sec_1_m_2_sr_1_um_1 <dbl> 5.577878~
#> $ xco2                                                          <dbl> 394.3686~
#> $ data                                                          <date> 2014-09~
#> $ ano                                                           <dbl> 2014, 20~
#> $ mes                                                           <dbl> 9, 9, 9,~
#> $ dia                                                           <dbl> 6, 6, 6,~
#> $ dia_semana                                                    <dbl> 7, 7, 7,~
#> $ x                                                             <int> 7, 8, 11~
#> $ xco2_est                                                      <dbl> 392.7080~
#> $ delta                                                         <dbl> -1.66062~
#> $ XCO2                                                          <dbl> 387.2781~
#> $ flag_norte                                                    <lgl> TRUE, TR~
#> $ flag_nordeste                                                 <lgl> FALSE, F~
#> $ flag_sul                                                      <lgl> FALSE, F~
#> $ flag_sudeste                                                  <lgl> FALSE, F~
#> $ flag_centroeste                                               <lgl> FALSE, F~
#> $ mês                                                           <dbl> 9, 9, 9,~
```

``` r
dados_estacao <- dados_estacao %>% 
  mutate(
    ano = lubridate::year(data),
    mês = lubridate::month(data),
    dia = lubridate::day(data),
    data = as.Date(stringr::str_c(ano,mês,dia,sep="-"))
)
```

## Manipulação dos bancos de dados Fco2 e de estação.

``` r
# atributos <- data_fco2
atributos <- left_join(data_fco2, dados_estacao, by = "data")
```

#### Listando as datas em ambos os bancos de dados

``` r
# Lista das datas de FCO2 
lista_data_fco2 <- unique(atributos$data)
lista_data_oco2 <- unique(oco2$data)
lista_data_estacao <- unique(dados_estacao$data)
datas_fco2 <- paste0(lubridate::year(lista_data_fco2),"-",lubridate::month(lista_data_fco2)) %>% unique()

datas_oco2 <- paste0(lubridate::year(lista_data_oco2),"-",lubridate::month(lista_data_oco2)) %>% unique()
datas <- datas_fco2[datas_fco2 %in% datas_oco2]
```

Criação as listas de datas, que é chave para a mesclagem dos arquivos.

``` r
fco2 <- atributos %>% 
  mutate(ano_mes = paste0(lubridate::year(data),"-",lubridate::month(data))) %>% 
  dplyr::filter(ano_mes %in% datas)

xco2 <- oco2 %>%   
  mutate(ano_mes=paste0(ano,"-",mês)) %>% 
  dplyr::filter(ano_mes %in% datas)
```

Coordenadas das cidades

``` r
unique(xco2$ano_mes)[unique(xco2$ano_mes) %>% order()] == 
unique(fco2$ano_mes)[unique(fco2$ano_mes) %>% order()]
#>  [1] TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE
#> [16] TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE
```

Abordagem usando o join do `{dplyr}`

``` r
memory.limit(size=10001)
#> [1] 10001
data_set <- left_join(fco2 %>% 
            mutate(ano = lubridate::year(data),
                   mes = lubridate::month(data)
                   ) %>% 
            select(ID, data, cultura, ano, mes, x,y, FCO2, Ts,
                   Us, MO, Macro, VTP, ARG, ano_mes,Tmed,Tmax, Tmin, Umed,
                   Umax, Umin, PkPa, Rad, Eto, Velmax, Velmin, Dir_vel,
                   chuva, inso), 
          xco2 %>% 
            select(data,mês,dia,longitude,latitude,XCO2,fluorescence_radiance_757nm_idp_ph_sec_1_m_2_sr_1_um_1,fluorescence_radiance_771nm_idp_ph_sec_1_m_2_sr_1_um_1, ano_mes), by = "ano_mes") %>% 
  mutate(dist = sqrt((longitude-(-51.423519))^2+(latitude-(-20.362911))^2),
         SIF = (fluorescence_radiance_757nm_idp_ph_sec_1_m_2_sr_1_um_1*2.6250912*10^(-19)  + 1.5*fluorescence_radiance_771nm_idp_ph_sec_1_m_2_sr_1_um_1* 2.57743*10^(-19))/2)

data_set<-data_set %>%
  select(-fluorescence_radiance_757nm_idp_ph_sec_1_m_2_sr_1_um_1, -fluorescence_radiance_771nm_idp_ph_sec_1_m_2_sr_1_um_1 )  %>% 
  filter(dist <= .16, FCO2 <= 20 ) 

visdat::vis_miss(data_set %>% 
                   sample_n(2000)
                 )
```

![](README_files/figure-gfm/unnamed-chunk-28-1.png)<!-- -->

``` r
# head(data_set)
# fco2$ano_mes %>% unique()
# xco2$ano_mes %>% unique()
# data_set$ano_mes %>% unique()
```

``` r
tab_medias <- data_set %>% 
  # mutate(SIF = ifelse(SIF <=0, mean(data_set$SIF, na.rm=TRUE),SIF)) %>% 
  group_by(ano_mes, cultura) %>% 
  summarise(FCO2 = mean(FCO2, na.rm=TRUE),
            XCO2 = mean(XCO2, na.rm=TRUE),
            SIF = mean(SIF, na.rm=TRUE))

tab_medias %>% 
  ggplot(aes(x=XCO2, y=SIF)) +
  geom_point()+
  geom_smooth(method = "lm")+
  theme_bw()
```

![](README_files/figure-gfm/unnamed-chunk-29-1.png)<!-- -->

``` r

tab_medias %>% 
  ggplot(aes(x=XCO2, y=FCO2)) +
  geom_point()+
  geom_smooth(method = "lm")+
  theme_bw()
```

![](README_files/figure-gfm/unnamed-chunk-29-2.png)<!-- -->

``` r

tab_medias %>% 
  ggplot(aes(x=FCO2, y=SIF)) +
  geom_point()+
  geom_smooth(method = "lm") +
  theme_bw()
```

![](README_files/figure-gfm/unnamed-chunk-29-3.png)<!-- -->

## Estatística Descritiva

Completar posteriormente.

# Abordagem de Parendizado de Máquina

## Definindo a base de treino e a base de teste

Definindo a semente aleatória mais o conjunto de dados para teste e
treino dos modelos

``` r
data_set_ml <- data_set #%>%
#   select(cultura, FCO2, Ts,
#                    Us, MO, Tmed,Tmax, Tmin, Umed,
#                    Umax, Umin, PkPa, Rad, Eto, Velmax, Velmin, Dir_vel,
#                    chuva, inso, SIF, xco2) %>% 
#   drop_na(FCO2, Ts,Us,Tmed:inso)
# visdat::vis_miss(data_set_ml)
# set.seed(1235)
fco2_initial_split <- initial_split(data_set_ml, prop = 0.75)
```

``` r
fco2_train <- training(fco2_initial_split)
# fco2_test <- testing(fco2_initial_split)
# visdat::vis_miss(fco2_test)
fco2_train  %>% 
  ggplot(aes(x=FCO2, y=..density..))+
  geom_histogram(bins = 30, color="black",  fill="lightgray")+
  geom_density(alpha=.05,fill="red")+
  theme_bw() +
  labs(x="FCO2", y = "Densidade")
```

![](README_files/figure-gfm/unnamed-chunk-31-1.png)<!-- -->

``` r
fco2_train  %>% 
  ggplot(aes(x=SIF, y=..density..))+
  geom_histogram(bins = 11, color="black",  fill="lightgray")+
  geom_density(alpha=.05,fill="green")+
  theme_bw() +
  labs(x="SIF", y = "Densidade")
```

![](README_files/figure-gfm/unnamed-chunk-32-1.png)<!-- -->

``` r
fco2_train  %>% 
  ggplot(aes(x=XCO2, y=..density..))+
  geom_histogram(bins = 15, color="black",  fill="lightgray")+
  geom_density(alpha=.05,fill="blue")+
  theme_bw() +
  labs(x="XCO2", y = "Densidade")
```

![](README_files/figure-gfm/unnamed-chunk-33-1.png)<!-- -->

## Correlação

``` r
glimpse(fco2_train)
#> Rows: 6,103
#> Columns: 37
#> $ ID        <int> 45, 24, 90, 18, 14, 11, 13, 6, 95, 47, 51, 23, 59, 45, 22, 1~
#> $ data.x    <date> 2016-02-25, 2018-07-09, 2015-10-06, 2016-05-06, 2017-06-03,~
#> $ cultura   <chr> "eucalipto", "pasto", "eucalipto", "pinus", "silvipastoril",~
#> $ ano       <dbl> 2016, 2018, 2015, 2016, 2017, 2016, 2018, 2017, 2017, 2017, ~
#> $ mes       <dbl> 2, 7, 10, 5, 6, 1, 7, 6, 3, 3, 9, 5, 5, 5, 5, 5, 6, 3, 6, 7,~
#> $ x         <dbl> 0, 7747971, 30, 0, 40, 0, 7748008, 100, 70, 20, 7749399, 0, ~
#> $ y         <dbl> 0.0, 456858.5, 90.0, 0.0, 10.0, 0.0, 456851.0, 0.0, 90.0, 30~
#> $ FCO2      <dbl> 6.72, 0.81, 12.63, 3.14, 2.45, 2.04, 1.08, 2.83, 6.32, 4.95,~
#> $ Ts        <dbl> 25.80000, 22.60000, 26.51197, 22.70000, 19.20000, 25.90000, ~
#> $ Us        <dbl> 14.000000, 13.285927, 7.000000, 10.000000, 7.000000, 11.0000~
#> $ MO        <dbl> 36.00, 19.00, 39.00, 17.00, 25.00, 21.00, 15.00, 30.00, 39.0~
#> $ Macro     <dbl> 0.08391657, 0.18000000, 0.16400000, 0.04537568, NA, 0.034864~
#> $ VTP       <dbl> 42.28709, 0.35000, 56.10190, 40.58146, NA, 45.64706, 0.39000~
#> $ ARG       <dbl> 282.1974, 71.9700, NA, 323.9959, NA, 351.1699, 133.6000, NA,~
#> $ ano_mes   <chr> "2016-2", "2018-7", "2015-10", "2016-5", "2017-6", "2016-1",~
#> $ Tmed      <dbl> NA, 17.7, 27.4, 24.7, 22.0, 27.3, 17.7, 23.7, 28.4, 25.8, 25~
#> $ Tmax      <dbl> NA, 21.1, 35.2, 33.7, 30.0, 32.8, 21.1, 31.5, 34.1, 33.6, 33~
#> $ Tmin      <dbl> NA, 14.8, 20.3, 17.5, 15.4, 24.3, 14.8, 17.3, 22.6, 22.2, 17~
#> $ Umed      <dbl> NA, 82.8, 62.3, 65.4, 74.7, 84.6, 82.8, 67.7, 73.3, 86.5, 58~
#> $ Umax      <dbl> NA, 96.7, 87.4, 99.4, 90.8, 99.7, 96.7, 94.8, 95.3, 99.9, 83~
#> $ Umin      <dbl> NA, 63.7, 41.2, 36.5, 54.7, 60.3, 63.7, 38.8, 52.0, 50.3, 37~
#> $ PkPa      <dbl> NA, 98.1, 97.4, 97.6, 97.8, 97.3, 98.1, 97.6, 97.3, 97.3, 97~
#> $ Rad       <dbl> NA, 3.9, 21.5, 16.1, 13.8, 18.9, 3.9, 13.7, 20.5, 14.9, 18.0~
#> $ Eto       <dbl> NA, 1.6, 5.7, 3.8, 2.8, 4.7, 1.6, 3.1, 4.7, 3.5, 4.9, 3.8, 2~
#> $ Velmax    <dbl> NA, 6.1, 7.3, 5.5, 4.6, 10.5, 6.1, 5.2, 5.2, 5.2, 7.2, 5.5, ~
#> $ Velmin    <dbl> NA, 2.1, 2.0, 1.3, 1.2, 2.2, 2.1, 1.2, 1.2, 0.7, 1.9, 1.3, 0~
#> $ Dir_vel   <dbl> NA, 237.1, 130.0, 99.0, 93.0, 54.7, 237.1, 72.5, 78.4, 264.9~
#> $ chuva     <dbl> NA, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.0, 0.0, 0~
#> $ inso      <dbl> NA, 0.0, 7.5, 8.3, 8.2, 4.2, 0.0, 8.0, 7.5, 3.6, 7.3, 8.3, 6~
#> $ data.y    <date> 2016-02-26, 2018-07-18, 2015-10-21, 2016-05-09, 2017-06-29,~
#> $ mês       <dbl> 2, 7, 10, 5, 6, 1, 7, 6, 3, 3, 9, 5, 5, 5, 5, 5, 6, 3, 6, 7,~
#> $ dia       <dbl> 26, 18, 21, 9, 29, 2, 9, 29, 16, 25, 30, 9, 6, 25, 15, 15, 2~
#> $ longitude <dbl> -51.5, -51.5, -51.5, -51.5, -51.5, -51.5, -51.5, -51.5, -51.~
#> $ latitude  <dbl> -20.5, -20.5, -20.5, -20.5, -20.5, -20.5, -20.5, -20.5, -20.~
#> $ XCO2      <dbl> 383.5738, 388.2893, 384.3260, 389.9741, 386.6562, 384.9647, ~
#> $ dist      <dbl> 0.1569801, 0.1569801, 0.1569801, 0.1569801, 0.1569801, 0.156~
#> $ SIF       <dbl> 1.12135961, 0.17194793, 1.04607328, -0.17171688, -0.08236333~
fco2_train   %>%    select(-c(ID,ano,mes,x,y,latitude,longitude,dist,mês,dia)) %>% 
  select(where(is.numeric)) %>%
  drop_na() %>% 
  cor()  %>%  
  corrplot::corrplot()
```

![](README_files/figure-gfm/unnamed-chunk-34-1.png)<!-- -->

## Data-prep

``` r
fco2_recipe <- recipe(FCO2 ~ ., data = fco2_train %>% 
                        select(-c(data.x,data.y,ID,ano,mes,x,y,latitude,longitude,dist,mês,dia,ano_mes))
) %>%  
  step_normalize(all_numeric_predictors())  %>% 
  step_novel(all_nominal_predictors()) %>% 
  step_zv(all_predictors()) %>%
  #step_naomit(c(Ts, Us)) %>% 
  #step_impute_mean(c(Us,Ts)) %>% 
  #step_poly(c(Us,Ts), degree = 2)  %>%  
  step_dummy(all_nominal_predictors())
bake(prep(fco2_recipe), new_data = NULL)
#> # A tibble: 6,103 x 29
#>          Ts       Us     MO  Macro    VTP     ARG    Tmed    Tmax   Tmin   Umed
#>       <dbl>    <dbl>  <dbl>  <dbl>  <dbl>   <dbl>   <dbl>   <dbl>  <dbl>  <dbl>
#>  1  0.526    0.00436  1.36  -0.742  0.372 -0.193  NA      NA      NA     NA    
#>  2 -0.0248  -0.0934  -0.323 -0.726 -1.56  -1.30   -1.43   -2.18   -0.715  1.30 
#>  3  0.649   -0.954    1.66  -0.728  1.01  NA       0.783   0.806   0.521 -0.818
#>  4 -0.00753 -0.543   -0.521 -0.748  0.293  0.0268  0.168   0.488  -0.108 -0.498
#>  5 -0.610   -0.954    0.273 NA     NA     NA      -0.447  -0.295  -0.580  0.463
#>  6  0.544   -0.406   -0.124 -0.750  0.526  0.170   0.760   0.298   1.42   1.49 
#>  7 -0.231    0.0996  -0.720 -0.717 -1.55  -0.974  -1.43   -2.18   -0.715  1.30 
#>  8 -1.16     1.03     0.769 NA     NA     NA      -0.0597  0.0225 -0.153 -0.260
#>  9  0.923    0.351    1.66  NA     NA     NA       1.01    0.573   1.04   0.319
#> 10  0.141    2.32     0.570 NA     NA     NA       0.418   0.467   0.948  1.68 
#> # i 6,093 more rows
#> # i 19 more variables: Umax <dbl>, Umin <dbl>, PkPa <dbl>, Rad <dbl>,
#> #   Eto <dbl>, Velmax <dbl>, Velmin <dbl>, Dir_vel <dbl>, chuva <dbl>,
#> #   inso <dbl>, XCO2 <dbl>, SIF <dbl>, FCO2 <dbl>, cultura_eucalipto <dbl>,
#> #   cultura_mata.ciliar <dbl>, cultura_pasto <dbl>, cultura_pinus <dbl>,
#> #   cultura_silvipastoril <dbl>, cultura_new <dbl>
```

``` r
visdat::vis_miss(bake(prep(fco2_recipe), new_data = NULL))
```

![](README_files/figure-gfm/unnamed-chunk-36-1.png)<!-- --> \## TUNAGEM

``` r
fco2_resamples <- vfold_cv(fco2_train, v = 10)
grid <- grid_regular(
  penalty(range = c(-8, 0)),
  levels = 20
)
```

## ÁRVORE DE DECISÃO (decision tree - dt)

``` r
fco2_dt_model <- decision_tree(
  cost_complexity = tune(),
  tree_depth = tune(),
  min_n = tune()
)  %>%  
  set_mode("regression")  %>%  
  set_engine("rpart")
```

### Workflow

``` r
fco2_dt_wf <- workflow()   %>%  
  add_model(fco2_dt_model) %>% 
  add_recipe(fco2_recipe)
```

### Criando a matriz (grid) com os valores de hiperparâmetros a serem testados

``` r
grid_dt <- grid_random(
  cost_complexity(c(-6, -4)),
  tree_depth(range = c(8, 18)),
  min_n(range = c(42, 52)),
  size = 2
)
glimpse(grid_dt)
#> Rows: 2
#> Columns: 3
#> $ cost_complexity <dbl> 1.539228e-05, 1.403220e-06
#> $ tree_depth      <int> 8, 8
#> $ min_n           <int> 51, 42
```

``` r
fco2_dt_tune_grid <- tune_grid(
  fco2_dt_wf,
  resamples = fco2_resamples,
  grid = grid_dt,
  metrics = metric_set(rmse)
)
```

``` r
autoplot(fco2_dt_tune_grid)
```

![](README_files/figure-gfm/unnamed-chunk-42-1.png)<!-- -->

``` r
collect_metrics(fco2_dt_tune_grid)
#> # A tibble: 2 x 9
#>   cost_complexity tree_depth min_n .metric .estimator  mean     n std_err
#>             <dbl>      <int> <int> <chr>   <chr>      <dbl> <int>   <dbl>
#> 1      0.0000154           8    51 rmse    standard    1.32    10  0.0359
#> 2      0.00000140          8    42 rmse    standard    1.32    10  0.0375
#> # i 1 more variable: .config <chr>
```

## Desempenho dos modelos finais

``` r
fco2_dt_best_params <- select_best(fco2_dt_tune_grid, "rmse")
fco2_dt_wf <- fco2_dt_wf %>% finalize_workflow(fco2_dt_best_params)
fco2_dt_last_fit <- last_fit(fco2_dt_wf, fco2_initial_split)
```

## Criar os preditos

``` r
fco2_test_preds <- bind_rows(
  collect_predictions(fco2_dt_last_fit)  %>%   mutate(modelo = "dt")
)

fco2_test <- testing(fco2_initial_split)
visdat::vis_miss(fco2_test)
```

![](README_files/figure-gfm/unnamed-chunk-45-1.png)<!-- -->

``` r
fco2_test_preds %>% 
  ggplot(aes(x=.pred, y=FCO2)) +
  geom_point()+
  theme_bw() +
  geom_smooth(method = "lm") +
  stat_regline_equation(ggplot2::aes(
  label =  paste(..eq.label.., ..rr.label.., sep = "*plain(\",\")~~"))) 
```

![](README_files/figure-gfm/unnamed-chunk-46-1.png)<!-- -->

## Variáveis importantes

``` r
fco2_dt_last_fit_model <-fco2_dt_last_fit$.workflow[[1]]$fit$fit
vip(fco2_dt_last_fit_model)
```

![](README_files/figure-gfm/unnamed-chunk-47-1.png)<!-- -->

## Métricas

``` r
da <- fco2_test_preds %>% 
  filter(FCO2 > 0, .pred>0 )

my_rmse <- Metrics::rmse(da$FCO2,
                         da$.pred)
my_mape <- Metrics::mape(da$FCO2,da$.pred)*100

fco2_test_preds %>% 
  ggplot(aes(x=FCO2,y=.pred))+
  geom_point()+
  geom_smooth(method = "lm")+
  stat_regline_equation(ggplot2::aes(
    label =  paste(..eq.label.., ..rr.label.., sep = "*plain(\",\")~~")),size=5)+
  ggplot2::annotate('text',x=10.4,y=16.7,label=paste0('RMSE = ',round(my_rmse,2),', MAPE = '
                                                      ,round(my_mape,2),'%'),size=5)+
  theme_bw()
```

![](README_files/figure-gfm/unnamed-chunk-48-1.png)<!-- -->

# Random Forest (rf)

Corrigindo os `NAs` no teste.

``` r
visdat::vis_miss(fco2_test)
```

![](README_files/figure-gfm/unnamed-chunk-49-1.png)<!-- -->

``` r
data_set_ml <- data_set_ml %>%
  select(cultura, FCO2, Ts, XCO2, SIF, 
                   Us, MO, Tmed,Tmax, Tmin, Umed,
                   Umax, Umin, PkPa, Rad, Eto, Velmax, Velmin, Dir_vel,
                   chuva, inso) %>%
  drop_na(FCO2, Ts,Us,Tmed:inso)
visdat::vis_miss(data_set_ml)
```

![](README_files/figure-gfm/unnamed-chunk-50-1.png)<!-- -->

``` r
fco2_initial_split <- initial_split(data_set_ml, prop = 0.75)
fco2_test <- testing(fco2_initial_split)
visdat::vis_miss(fco2_test)
```

![](README_files/figure-gfm/unnamed-chunk-50-2.png)<!-- -->

``` r
fco2_train <- training(fco2_initial_split)
visdat::vis_miss(fco2_train)
```

![](README_files/figure-gfm/unnamed-chunk-50-3.png)<!-- -->

``` r

fco2_resamples_rf <- vfold_cv(fco2_train, v = 5)
```

## Data prep

``` r
fco2_rf_recipe <- recipe(FCO2 ~ ., data = fco2_train) %>% 
  step_string2factor(all_nominal(), skip = TRUE) %>% 
  step_normalize(all_numeric_predictors())  %>% 
  step_novel(all_nominal_predictors()) %>% 
  step_zv(all_predictors()) %>%
  # step_naomit(all_predictors()) #%>% 
  # step_impute_mean(c(Ts,Us)) %>% 
  # step_poly(c(Ts, Us), degree = 2)  %>%  
  step_dummy(all_nominal_predictors())
bake(prep(fco2_rf_recipe), new_data = NULL)
#> # A tibble: 5,459 x 26
#>         Ts   XCO2     SIF     Us     MO    Tmed    Tmax   Tmin   Umed   Umax
#>      <dbl>  <dbl>   <dbl>  <dbl>  <dbl>   <dbl>   <dbl>  <dbl>  <dbl>  <dbl>
#>  1  0.365   0.556 -0.427  -1.70  -0.183  1.04    1.22    0.935  0.311  0.475
#>  2  0.0824  0.108  0.118  -0.924  0.869 -0.0468  0.0348 -0.141 -0.250  0.288
#>  3 -1.56   -0.185 -0.525   1.43   0.964 -1.39   -0.960  -1.84  -0.770  0.748
#>  4  1.06   -0.162  2.28   -0.441  0.964  0.726   0.649   0.576  0.550  0.906
#>  5  0.796   1.28  -1.26   -0.832 -0.565 -0.183  -0.0498 -0.320 -0.936 -0.776
#>  6 -1.01    1.05  -0.437   0.903  0.678 -1.84   -2.02   -1.35  -0.385 -1.06 
#>  7  1.08   -0.162  2.28   -0.712  0.773  1.27    0.797   1.41   0.259 -0.316
#>  8  0.365   0.472  0.0807 -1.70  -0.183  1.04    1.22    0.935  0.311  0.475
#>  9  0.913   1.90  -0.387   0.399 -1.52  -0.274  -0.0922 -0.477 -1.28  -0.158
#> 10 -1.01   -1.99  -0.170   0.903  0.678 -1.84   -2.02   -1.35  -0.385 -1.06 
#> # i 5,449 more rows
#> # i 16 more variables: Umin <dbl>, PkPa <dbl>, Rad <dbl>, Eto <dbl>,
#> #   Velmax <dbl>, Velmin <dbl>, Dir_vel <dbl>, chuva <dbl>, inso <dbl>,
#> #   FCO2 <dbl>, cultura_eucalipto <dbl>, cultura_mata.ciliar <dbl>,
#> #   cultura_pasto <dbl>, cultura_pinus <dbl>, cultura_silvipastoril <dbl>,
#> #   cultura_new <dbl>
visdat::vis_miss(bake(prep(fco2_rf_recipe), new_data = NULL))
```

![](README_files/figure-gfm/unnamed-chunk-51-1.png)<!-- -->

## Modelo

``` r
fco2_rf_model <- rand_forest(
  min_n = tune(),
  mtry = tune(),
  trees = tune()
)   %>%  
  set_mode("regression")  %>% 
  set_engine("randomForest")
```

## Workflow

``` r
fco2_rf_wf <- workflow()   %>%  
  add_model(fco2_rf_model) %>%  
  add_recipe(fco2_rf_recipe)
```

## Tune

mtry trees min_n .config 10 769 21 Preprocessor1_Model39

``` r
grid_rf <- grid_random(
  min_n(range = c(20, 30)),
  mtry(range = c(10,20)),
  trees(range = c(769,1500) ),
  size = 2
)
```

``` r
fco2_rf_tune_grid <- tune_grid(
 fco2_rf_wf,
  resamples = fco2_resamples_rf,
  grid = grid_rf,
  metrics = metric_set(rmse)
) 
autoplot(fco2_rf_tune_grid)
```

![](README_files/figure-gfm/unnamed-chunk-55-1.png)<!-- -->

``` r
collect_metrics(fco2_rf_tune_grid)
#> # A tibble: 2 x 9
#>    mtry trees min_n .metric .estimator  mean     n std_err .config             
#>   <int> <int> <int> <chr>   <chr>      <dbl> <int>   <dbl> <chr>               
#> 1    10  1129    30 rmse    standard    1.15     5  0.0180 Preprocessor1_Model1
#> 2    19  1335    25 rmse    standard    1.13     5  0.0214 Preprocessor1_Model2
```

## Desempenho dos modelos finais

``` r
fco2_rf_best_params <- select_best(fco2_rf_tune_grid, "rmse")
fco2_rf_wf <- fco2_rf_wf %>% finalize_workflow(fco2_rf_best_params)
fco2_rf_last_fit <- last_fit(fco2_rf_wf, fco2_initial_split)
```

## Criar os preditos

``` r
fco2_test_preds <- bind_rows(
  collect_predictions(fco2_rf_last_fit)  %>%   mutate(modelo = "rf")
)
```

``` r
fco2_test_preds %>% 
  ggplot(aes(x=.pred, y=FCO2)) +
  geom_point()+
  theme_bw() +
  geom_smooth(method = "lm") +
  stat_regline_equation(ggplot2::aes(
  label =  paste(..eq.label.., ..rr.label.., sep = "*plain(\",\")~~"))) 
```

![](README_files/figure-gfm/unnamed-chunk-59-1.png)<!-- -->

## Variáveis importantes

``` r
fco2_rf_last_fit_model <-fco2_rf_last_fit$.workflow[[1]]$fit$fit
vip(fco2_rf_last_fit_model)
```

![](README_files/figure-gfm/unnamed-chunk-60-1.png)<!-- -->

## Métricas

``` r
da <- fco2_test_preds %>% 
  filter(FCO2 > 0, .pred> 0 )

my_rmse <- Metrics::rmse(da$FCO2,
                         da$.pred)
my_mape <- Metrics::mape(da$FCO2,da$.pred)*100

fco2_test_preds %>% 
  ggplot(aes(x=FCO2,y=.pred))+
  geom_point()+
  geom_smooth(method = "lm")+
  stat_regline_equation(ggplot2::aes(
    label =  paste(..eq.label.., ..rr.label.., sep = "*plain(\",\")~~")),size=5)+
  ggplot2::annotate('text',x=10.4,y=16.7,label=paste0('RMSE = ',round(my_rmse,2),', MAPE = '
                                                      ,round(my_mape,2),'%'),size=5)+
  theme_bw()
```

![](README_files/figure-gfm/unnamed-chunk-61-1.png)<!-- -->

# Boosting gradient tree (xgb)

## Data prep

``` r
fco2_xgb_recipe <- recipe(FCO2 ~ ., data = fco2_train) %>% 
  step_string2factor(all_nominal(), skip = TRUE) %>% 
  step_normalize(all_numeric_predictors())  %>% 
  step_novel(all_nominal_predictors()) %>% 
  # step_zv(all_predictors()) %>%
  # step_naomit(all_predictors()) #%>% 
  #step_poly(c(Ts, Us), degree = 3)  %>%  
  step_dummy(all_nominal_predictors())
bake(prep(fco2_xgb_recipe), new_data = NULL)
#> # A tibble: 5,459 x 26
#>         Ts   XCO2     SIF     Us     MO    Tmed    Tmax   Tmin   Umed   Umax
#>      <dbl>  <dbl>   <dbl>  <dbl>  <dbl>   <dbl>   <dbl>  <dbl>  <dbl>  <dbl>
#>  1  0.365   0.556 -0.427  -1.70  -0.183  1.04    1.22    0.935  0.311  0.475
#>  2  0.0824  0.108  0.118  -0.924  0.869 -0.0468  0.0348 -0.141 -0.250  0.288
#>  3 -1.56   -0.185 -0.525   1.43   0.964 -1.39   -0.960  -1.84  -0.770  0.748
#>  4  1.06   -0.162  2.28   -0.441  0.964  0.726   0.649   0.576  0.550  0.906
#>  5  0.796   1.28  -1.26   -0.832 -0.565 -0.183  -0.0498 -0.320 -0.936 -0.776
#>  6 -1.01    1.05  -0.437   0.903  0.678 -1.84   -2.02   -1.35  -0.385 -1.06 
#>  7  1.08   -0.162  2.28   -0.712  0.773  1.27    0.797   1.41   0.259 -0.316
#>  8  0.365   0.472  0.0807 -1.70  -0.183  1.04    1.22    0.935  0.311  0.475
#>  9  0.913   1.90  -0.387   0.399 -1.52  -0.274  -0.0922 -0.477 -1.28  -0.158
#> 10 -1.01   -1.99  -0.170   0.903  0.678 -1.84   -2.02   -1.35  -0.385 -1.06 
#> # i 5,449 more rows
#> # i 16 more variables: Umin <dbl>, PkPa <dbl>, Rad <dbl>, Eto <dbl>,
#> #   Velmax <dbl>, Velmin <dbl>, Dir_vel <dbl>, chuva <dbl>, inso <dbl>,
#> #   FCO2 <dbl>, cultura_eucalipto <dbl>, cultura_mata.ciliar <dbl>,
#> #   cultura_pasto <dbl>, cultura_pinus <dbl>, cultura_silvipastoril <dbl>,
#> #   cultura_new <dbl>
visdat::vis_miss(bake(prep(fco2_xgb_recipe), new_data = NULL))
```

![](README_files/figure-gfm/unnamed-chunk-62-1.png)<!-- -->

### Estratégia de Tunagem de Hiperparâmetros

#### Passo 1:

Achar uma combinação `learning_rate` e `trees` que funciona
relativamente bem.

- learn_rate - 0.05, 0.1, 0.3

- trees - 100, 500, 1000, 1500

## Modelo

``` r
cores = 4
fco2_xgb_model <- boost_tree(
  mtry = 0.8, 
  trees = tune(), # <---------------
  min_n = 5, 
  tree_depth = 4,
  loss_reduction = 0, # lambda
  learn_rate = tune(), # epsilon
  sample_size = 0.8
)  %>%   
  set_mode("regression")  %>% 
  set_engine("xgboost", nthread = cores, counts = FALSE)
```

## Workflow

``` r
fco2_xgb_wf <- workflow()  %>%  
  add_model(fco2_xgb_model) %>%  
  add_recipe(fco2_xgb_recipe)
```

## Tune

``` r
grid_xgb <- expand.grid(
  learn_rate =  c(0.05, 0.3),
  trees = c(2, 250, 500)
)
```

``` r
fco2_xgb_tune_grid <- tune_grid(
 fco2_xgb_wf,
  resamples = fco2_resamples,
  grid = grid_xgb,
  metrics = metric_set(rmse)
)
```

``` r
autoplot(fco2_xgb_tune_grid)
```

![](README_files/figure-gfm/unnamed-chunk-67-1.png)<!-- -->

``` r
fco2_xgb_tune_grid   %>%   show_best(metric = "rmse", n = 6)
#> # A tibble: 6 x 8
#>   trees learn_rate .metric .estimator  mean     n std_err .config             
#>   <dbl>      <dbl> <chr>   <chr>      <dbl> <int>   <dbl> <chr>               
#> 1   500       0.05 rmse    standard    1.20    10  0.0363 Preprocessor1_Model3
#> 2   250       0.05 rmse    standard    1.21    10  0.0359 Preprocessor1_Model2
#> 3   250       0.3  rmse    standard    1.23    10  0.0354 Preprocessor1_Model5
#> 4   500       0.3  rmse    standard    1.24    10  0.0345 Preprocessor1_Model6
#> 5     2       0.3  rmse    standard    2.07    10  0.0446 Preprocessor1_Model4
#> 6     2       0.05 rmse    standard    3.16    10  0.0461 Preprocessor1_Model1
```

``` r
fco2_xgb_select_best_passo1 <- fco2_xgb_tune_grid %>% 
  select_best(metric = "rmse")
fco2_xgb_select_best_passo1
#> # A tibble: 1 x 3
#>   trees learn_rate .config             
#>   <dbl>      <dbl> <chr>               
#> 1   500       0.05 Preprocessor1_Model3
```

#### Passo 2:

São bons valores inciais. Agora, podemos tunar os parâmetros
relacionados à árvore.

- tree_depth: vamos deixar ele variar entre 3 e 10.
- min_n: vamos deixar variar entre 5 e 90.

``` r
fco2_xgb_model <- boost_tree(
  mtry = 0.8,
  trees = fco2_xgb_select_best_passo1$trees,
  min_n = tune(),
  tree_depth = tune(), 
  loss_reduction = 0, 
  learn_rate = fco2_xgb_select_best_passo1$learn_rate, 
  sample_size = 0.8
) %>% 
  set_mode("regression")  %>% 
  set_engine("xgboost", nthread = cores, counts = FALSE)

#### Workflow
fco2_xgb_wf <- workflow() %>%  
    add_model(fco2_xgb_model)   %>%   
    add_recipe(fco2_xgb_recipe)

#### Grid
fco2_xgb_grid <- expand.grid(
  tree_depth = c(1, 3, 4), 
  min_n = c(5, 30, 60)
)

fco2_xgb_tune_grid <- fco2_xgb_wf   %>%   
  tune_grid(
    resamples =fco2_resamples,
    grid = fco2_xgb_grid,
    control = control_grid(save_pred = TRUE, verbose = FALSE, allow_par = TRUE),
    metrics = metric_set(rmse)
  )

#### Melhores hiperparâmetros
autoplot(fco2_xgb_tune_grid)
```

![](README_files/figure-gfm/unnamed-chunk-70-1.png)<!-- -->

``` r
fco2_xgb_tune_grid  %>%   show_best(metric = "rmse", n = 5)
#> # A tibble: 5 x 8
#>   min_n tree_depth .metric .estimator  mean     n std_err .config             
#>   <dbl>      <dbl> <chr>   <chr>      <dbl> <int>   <dbl> <chr>               
#> 1     5          4 rmse    standard    1.20    10  0.0370 Preprocessor1_Model3
#> 2    30          4 rmse    standard    1.22    10  0.0373 Preprocessor1_Model6
#> 3     5          3 rmse    standard    1.22    10  0.0344 Preprocessor1_Model2
#> 4    60          4 rmse    standard    1.23    10  0.0379 Preprocessor1_Model9
#> 5    30          3 rmse    standard    1.24    10  0.0364 Preprocessor1_Model5
fco2_xgb_select_best_passo2 <- fco2_xgb_tune_grid  %>%   select_best(metric = "rmse")
fco2_xgb_select_best_passo2
#> # A tibble: 1 x 3
#>   min_n tree_depth .config             
#>   <dbl>      <dbl> <chr>               
#> 1     5          4 Preprocessor1_Model3
```

#### Passo 3

Vamos tunar o `loss_reduction`

``` r
fco2_xgb_model <- boost_tree(
  mtry = 0.8,
  trees = fco2_xgb_select_best_passo1$trees,
  min_n = fco2_xgb_select_best_passo2$min_n,
  tree_depth = fco2_xgb_select_best_passo2$tree_depth, 
  loss_reduction =tune(), 
  learn_rate = fco2_xgb_select_best_passo1$learn_rate, 
  sample_size = 0.8
)  %>%  
  set_mode("regression")  %>%  
  set_engine("xgboost", nthread = cores, counts = FALSE)

#### Workflow
fco2_xgb_wf <- workflow()  %>%   
    add_model(fco2_xgb_model)  %>%   
    add_recipe(fco2_xgb_recipe)

#### Grid
fco2_xgb_grid <- expand.grid(
  loss_reduction = c(0.01, 0.05, 1, 2, 4, 8)
)

fco2_xgb_tune_grid <- fco2_xgb_wf   %>%   
  tune_grid(
    resamples = fco2_resamples,
    grid = fco2_xgb_grid,
    control = control_grid(save_pred = TRUE, verbose = FALSE, allow_par = TRUE),
    metrics = metric_set(rmse)
  )

#### Melhores hiperparâmetros
autoplot(fco2_xgb_tune_grid)
```

![](README_files/figure-gfm/unnamed-chunk-72-1.png)<!-- -->

``` r
fco2_xgb_tune_grid   %>%   show_best(metric = "rmse", n = 5)
#> # A tibble: 5 x 7
#>   loss_reduction .metric .estimator  mean     n std_err .config             
#>            <dbl> <chr>   <chr>      <dbl> <int>   <dbl> <chr>               
#> 1           0.05 rmse    standard    1.20    10  0.0356 Preprocessor1_Model2
#> 2           1    rmse    standard    1.20    10  0.0369 Preprocessor1_Model3
#> 3           2    rmse    standard    1.20    10  0.0367 Preprocessor1_Model4
#> 4           4    rmse    standard    1.20    10  0.0365 Preprocessor1_Model5
#> 5           0.01 rmse    standard    1.21    10  0.0373 Preprocessor1_Model1
fco2_xgb_select_best_passo3 <- fco2_xgb_tune_grid %>% select_best(metric = "rmse")
fco2_xgb_select_best_passo3
#> # A tibble: 1 x 2
#>   loss_reduction .config             
#>            <dbl> <chr>               
#> 1           0.05 Preprocessor1_Model2
```

#### Passo 4:

Vamos então tunar o `mtry` e o `sample_size`:

``` r
fco2_xgb_model <- boost_tree(
  mtry = tune(),
  trees = fco2_xgb_select_best_passo1$trees,
  min_n = fco2_xgb_select_best_passo2$min_n,
  tree_depth = fco2_xgb_select_best_passo2$tree_depth, 
  loss_reduction = fco2_xgb_select_best_passo3$loss_reduction, 
  learn_rate = fco2_xgb_select_best_passo1$learn_rate, 
  sample_size = tune()
)%>%  
  set_mode("regression")  |> 
  set_engine("xgboost", nthread = cores, counts = FALSE)
```

``` r
#### Workflow
fco2_xgb_wf <- workflow()  %>%   
    add_model(fco2_xgb_model)  %>%   
    add_recipe(fco2_xgb_recipe)
```

``` r
#### Grid
fco2_xgb_grid <- expand.grid(
    sample_size = seq(0.5, 1.0, length.out = 2), ## <---
    mtry = seq(0.1, 1.0, length.out = 2) ## <---
)
```

``` r
fco2_xgb_tune_grid <- fco2_xgb_wf   %>%   
  tune_grid(
    resamples = fco2_resamples,
    grid = fco2_xgb_grid,
    control = control_grid(save_pred = TRUE, verbose = FALSE, allow_par = TRUE),
    metrics = metric_set(rmse)
  )
```

``` r
#### Melhores hiperparâmetros
autoplot(fco2_xgb_tune_grid)
```

![](README_files/figure-gfm/unnamed-chunk-78-1.png)<!-- -->

``` r
fco2_xgb_tune_grid  |>  show_best(metric = "rmse", n = 5)
#> # A tibble: 4 x 8
#>    mtry sample_size .metric .estimator  mean     n std_err .config             
#>   <dbl>       <dbl> <chr>   <chr>      <dbl> <int>   <dbl> <chr>               
#> 1   1           1   rmse    standard    1.21    10  0.0363 Preprocessor1_Model4
#> 2   1           0.5 rmse    standard    1.22    10  0.0352 Preprocessor1_Model3
#> 3   0.1         1   rmse    standard    1.23    10  0.0336 Preprocessor1_Model2
#> 4   0.1         0.5 rmse    standard    1.23    10  0.0333 Preprocessor1_Model1
fco2_xgb_select_best_passo4 <- fco2_xgb_tune_grid   %>%   select_best(metric = "rmse")
fco2_xgb_select_best_passo4
#> # A tibble: 1 x 3
#>    mtry sample_size .config             
#>   <dbl>       <dbl> <chr>               
#> 1     1           1 Preprocessor1_Model4
```

#### Passo 5

Agora vamos tunar o `learn_rate` e o trees de novo, mas deixando o
`learn_rate` assumir valores menores.

``` r
fco2_xgb_model <- boost_tree(
  mtry = fco2_xgb_select_best_passo4$mtry,
  trees = tune(),
  min_n = fco2_xgb_select_best_passo2$min_n,
  tree_depth = fco2_xgb_select_best_passo2$tree_depth, 
  loss_reduction = fco2_xgb_select_best_passo3$loss_reduction, 
  learn_rate = tune(), 
  sample_size = fco2_xgb_select_best_passo4$sample_size
) |> 
  set_mode("regression")  %>%  
  set_engine("xgboost", nthread = cores, counts = FALSE)

#### Workflow
fco2_xgb_wf <- workflow() %>%   
    add_model(fco2_xgb_model)  %>%   
    add_recipe(fco2_xgb_recipe)

#### Grid
fco2_xgb_grid <- expand.grid(
    learn_rate = c(0.05, 0.10, 0.15, 0.25),
    trees = c(100, 250, 500)
)

fco2_xgb_tune_grid <- fco2_xgb_wf   %>%   
  tune_grid(
    resamples = fco2_resamples,
    grid = fco2_xgb_grid,
    control = control_grid(save_pred = TRUE, verbose = FALSE, allow_par = TRUE),
    metrics = metric_set(rmse)
  )

#### Melhores hiperparâmetros
autoplot(fco2_xgb_tune_grid)
```

![](README_files/figure-gfm/unnamed-chunk-80-1.png)<!-- -->

``` r
fco2_xgb_tune_grid  %>%   show_best(metric = "rmse", n = 5)
#> # A tibble: 5 x 8
#>   trees learn_rate .metric .estimator  mean     n std_err .config              
#>   <dbl>      <dbl> <chr>   <chr>      <dbl> <int>   <dbl> <chr>                
#> 1   500       0.25 rmse    standard    1.18    10  0.0372 Preprocessor1_Model12
#> 2   250       0.25 rmse    standard    1.18    10  0.0372 Preprocessor1_Model11
#> 3   500       0.15 rmse    standard    1.18    10  0.0379 Preprocessor1_Model09
#> 4   500       0.1  rmse    standard    1.19    10  0.0386 Preprocessor1_Model06
#> 5   250       0.15 rmse    standard    1.20    10  0.0376 Preprocessor1_Model08
fco2_xgb_select_best_passo5 <- fco2_xgb_tune_grid   %>%   select_best(metric = "rmse")
fco2_xgb_select_best_passo5
#> # A tibble: 1 x 3
#>   trees learn_rate .config              
#>   <dbl>      <dbl> <chr>                
#> 1   500       0.25 Preprocessor1_Model12
```

### Desempenho dos modelos finais

``` r
fco2_xgb_model <- boost_tree(
  mtry = fco2_xgb_select_best_passo4$mtry,
  trees = fco2_xgb_select_best_passo5$trees,
  min_n = fco2_xgb_select_best_passo2$min_n,
  tree_depth = fco2_xgb_select_best_passo2$tree_depth, 
  loss_reduction = fco2_xgb_select_best_passo3$loss_reduction, 
  learn_rate = fco2_xgb_select_best_passo5$learn_rate, 
  sample_size = fco2_xgb_select_best_passo4$sample_size
) %>%  
  set_mode("regression")  %>%  
  set_engine("xgboost", nthread = cores, counts = FALSE)
```

## Desempenho dos modelos finais

``` r
# fco2_xgb_best_params <- select_best(fco2_xgb_tune_grid, "rmse")
df <- data.frame(
  mtry = fco2_xgb_select_best_passo4$mtry,
  trees = fco2_xgb_select_best_passo5$trees,
  min_n = fco2_xgb_select_best_passo2$min_n,
  tree_depth = fco2_xgb_select_best_passo2$tree_depth, 
  loss_reduction = fco2_xgb_select_best_passo3$loss_reduction, 
  learn_rate = fco2_xgb_select_best_passo5$learn_rate, 
  sample_size = fco2_xgb_select_best_passo4$sample_size
)
fco2_xgb_wf <- fco2_xgb_wf %>% finalize_workflow(df) # <------
fco2_xgb_last_fit <- last_fit(fco2_xgb_wf, fco2_initial_split) # <--------
```

## Criar os preditos

``` r
fco2_test_preds <- bind_rows(
  collect_predictions(fco2_xgb_last_fit)  %>%   mutate(modelo = "xgb")
)
```

``` r
fco2_test_preds %>% 
  ggplot(aes(x=.pred, y=FCO2)) +
  geom_point()+
  theme_bw() +
  geom_smooth(method = "lm") +
  stat_regline_equation(ggplot2::aes(
  label =  paste(..eq.label.., ..rr.label.., sep = "*plain(\",\")~~"))) 
```

![](README_files/figure-gfm/unnamed-chunk-85-1.png)<!-- -->

## Variáveis importantes

``` r
fco2_xgb_last_fit_model <-fco2_xgb_last_fit$.workflow[[1]]$fit$fit
vip(fco2_xgb_last_fit_model)
```

![](README_files/figure-gfm/unnamed-chunk-86-1.png)<!-- -->

## Métricas

``` r
da <- fco2_test_preds %>% 
  filter(FCO2 > 0, .pred> 0 )

my_rmse <- Metrics::rmse(da$FCO2,
                         da$.pred)
my_mape <- Metrics::mape(da$FCO2,da$.pred)*100

fco2_test_preds %>% 
  ggplot(aes(x=FCO2,y=.pred))+
  geom_point()+
  geom_smooth(method = "lm")+
  stat_regline_equation(ggplot2::aes(
    label =  paste(..eq.label.., ..rr.label.., sep = "*plain(\",\")~~")),size=5)+
  ggplot2::annotate('text',x=10.4,y=16.7,label=paste0('RMSE = ',round(my_rmse,2),', MAPE = '
                                                      ,round(my_mape,2),'%'),size=5)+
  theme_bw()
```

![](README_files/figure-gfm/unnamed-chunk-87-1.png)<!-- -->
