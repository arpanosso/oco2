limites_outlier <- function(x,coefi=1.5){
  med = median(x)
  li = med - coefi*IQR(x)
  ls<- med + coefi*IQR(x)
  c(Lim_Inferior = li, Lim_Superior = ls)
}