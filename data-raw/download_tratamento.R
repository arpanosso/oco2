# Definindo o Pipe
`%>%` <- magrittr::`%>%`

# Links de download gerados pela NASA
## criando o arquivo com os nomdes dos diferentes jobs (requeste com um certo 
## número de links)
arqs_txt <- list.files(path = "data-raw/oco2",
                       pattern = ".txt",
                       full.names = TRUE)

## criando a função que prepara os links para o dwnload
preparador_link <- function(nome_arquivo){
  df <- nome_arquivo %>%
    read.table(sep=",") 
  df[1,] %>% 
    t() %>% 
    data.frame() %>% 
    dplyr::pull(X1)
}

links <- purrr::map(1:length(arqs_txt), ~preparador_link(arqs_txt[.x])) %>% 
  unlist()


# Definindo os caminhos e nomes dos arquivos
n_split <- lengths(stringr::str_split(links[1],"/"))
files_csv <- stringr::str_split(links,"/",simplify = TRUE)[,n_split]
files_csv <- paste0("data-raw/oco2/csv/",files_csv)

# Definindo o plano de multisession
future::plan("multisession")

# Criando a função para fazer o download dos arquivos
# Criando a função para fazer o download dos arquivos
download_arquivos <- function(url, dir){
  download.file(url, dir, mode = "wb")
  return(dir)
}

# Criando a função maybe_
maybe_download_nasa_prog <- function(url, dir, prog){
  prog()
  f <- purrr::possibly(download_arquivos, "")
  f(url, dir)
}

# Rodando com a barra de progresso
# progressr::with_progress({
#   prog <- progressr::progressor(along = links)
#   furrr::future_map2(links, files_csv,
#                      maybe_download_nasa_prog, prog=prog)
# })


# Faxina dos dados, retirando as falhas no sensor para a concentração de CO2
faxina_co2 <- function(arquivo, col, valor_perdido){
   da <- readr::read_csv(arquivo) %>%
     dplyr::filter({{col}} != valor_perdido)
   readr::write_csv(da,arquivo)
}

purrr::map(files_csv, faxina_co2,
           col=`xco2 (Moles Mole^{-1})`,
           valor_perdido= -999999)

# Compilando os arquivos e salvando a base em data
oco2 <- purrr::map_dfr(files_csv, ~readr::read_csv(.x))
readr::write_rds(oco2,"data/oco2.rds")
