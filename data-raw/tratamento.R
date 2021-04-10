# Download dos dados
# buscar o nome do arquivo contendo o termo CUSTON
%>%` <- magrittr::`%>%`
nome <- dir("data-raw/", pattern = "CUSTOM")

# ler os endereços armazenados no arquivo
enderecos<-read.table(paste0("data-raw/", nome))
n_links <- nrow(enderecos)
n_split <- length(stringr::str_split(enderecos[1,1],"/",simplify = TRUE))
nomes_arquivos_csv <- stringr::str_split_fixed(enderecos[,1],"/",n=Inf)[,n_split]
nomes_arquivos_txt<-sub(".csv",".txt",nomes_arquivos_csv)

### download dos arquivos - aproximadamente 2 GB ao todo
# for(i in 1:n_links){
#  download.file(enderecos[i,1], 
#                paste0("data-raw/CSV",nomes_arquivos_csv[i]), 
#                mode="wb")
# }

# Realizando a faxina de NA e posterior armazenamento dos arquivos em TXT
# for(i in 1:n_links){
#    da<-read.csv(paste0("data-raw/CSV/", nomes_arquivos_csv[i]), sep=",")
#      da <- da %>%
#      filter(xco2..Moles.Mole...1.. != -999999)
#      write.table(da,
#                 paste0("data-raw/TXT/",nomes_arquivos_txt[i]),
#                 quote = FALSE,
#                 sep="\t",row.names = FALSE)
# }

# Lendo os arquivo totais
for(i in 1:n_links){
  if(i == 1){
    tab<-read.table(paste0("data-raw/TXT/",nomes_arquivos_txt[i]),h=TRUE,sep="\t")
  }else{
    da<-read.table(paste0("data-raw/TXT/",nomes_arquivos_txt[i]),h=TRUE,sep="\t")
    tab<-rbind(tab,da)
  }
}
dplyr::glimpse(tab)
readr::write_rds(tab,"data/XCO2_20142020.rds")
