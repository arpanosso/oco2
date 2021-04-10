library(magrittr)
library(dplyr)
library(tidyr)

xco2 <- readr::read_rds("data/XCO2_20142020.rds")
glimpse(xco2)

oco_2<-xco2 %>% 
  select(longitude,
         latitude,
         time..YYYYMMDDHHMMSS.,
         xco2..Moles.Mole...1..)


oco_2 <- oco_2 %>% 
  mutate(
    xco2_obs = xco2..Moles.Mole...1.. *1e06,
    ano = time..YYYYMMDDHHMMSS.%/%1e10,
    mês = time..YYYYMMDDHHMMSS.%/%1e8 %%100,
    dia = time..YYYYMMDDHHMMSS.%/%1e6 %%100,
    data = as.Date(stringr::str_c(ano,mês,dia,sep="-"))
  ) %>% 
  glimpse()


muni <- geobr::read_municipality(code_muni = "SP",showProgress = FALSE)
estados <- geobr::read_state(code_state = "all",showProgress = FALSE)
regiao <- geobr::read_region(showProgress = FALSE)
br <- geobr::read_country(showProgress = FALSE)
sp <- geobr::read_state(code_state = "SP",showProgress = FALSE)
ms <- geobr::read_state(code_state = "MS",showProgress = FALSE)

source("r/graficos.R")
br %>% 
  ggplot() + 
  geom_sf(fill="#2D3E50", color="#FEBF57", 
          size=.15, show.legend = FALSE) +
  tema_mapa()


regiao %>% 
  ggplot() + 
  geom_sf(fill="#2D3E50", color="#FEBF57", 
          size=.15, show.legend = FALSE)+
  tema_mapa()

estados %>% 
  ggplot() + 
  geom_sf(fill="#2D3E50", color="#FEBF57", 
          size=.15, show.legend = FALSE)+
  tema_mapa()

pais %>% 
  ggplot() + 
  geom_sf(fill="#2D3E50", color="#FEBF57", 
          size=.15, show.legend = FALSE)+
  geom_sf(data=sp,fill="#2D3E50", color="#FEBF57")+ 
  geom_sf(data=ms,fill="#2D3E50", color="#FEBF57")+
  tema_mapa()

muni %>% 
  ggplot() + 
  geom_sf(fill="#2D3E50", color="#FEBF57", 
          size=.15, show.legend = FALSE)+
  tema_mapa()

br %>% 
  ggplot() + 
  geom_sf(fill="#2D3E50", color="#FEBF57", 
          size=.15, show.legend = FALSE)+
  tema_mapa() +
  geom_point(data=oco_2 %>% filter(ano == 2014) ,
             aes(x=longitude,y=latitude),
             shape=3,
             col="red",
             alpha=0.2)









