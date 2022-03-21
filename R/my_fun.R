limites_outlier <- function(x,coefi=1.5){
  med = median(x)
  li = med - coefi*IQR(x)
  ls<- med + coefi*IQR(x)
  c(Lim_Inferior = li, Lim_Superior = ls)
}

# Função para o cálculo do CV
meu_cv <- function(x){
  100*sd(x)/mean(x)
}

# Função para o cálculo do erro padrão da média
meu_erro_padrao <- function(x){
  sd(x)/sqrt(length(x))
}

# Função para a estatística descritiva
est_descritiva <- function(x){
  n <- length(x)
  n_na <- sum(is.na(x)) # <<<<<<<------------
  m <- mean(x)
  dp <- sd(x)
  md <- median(x) # quantile(x, 0.50)
  cv <- meu_cv(x)
  mini <- min(x)
  maxi <- max(x)
  q1 <- quantile(x, 0.25)
  q3 <- quantile(x, 0.75)
  s2 <- var(x)
  g1 <- agricolae::skewness(x)
  g2 <- agricolae::kurtosis(x)
  epm <- meu_erro_padrao(x)
  pSW <- shapiro.test(x)$p.value
  return(c(N = n,
           N_perdidos = n_na, # <<<<<<<<<--------
           Media = m,Mediana = md,
           Min = mini,Max = maxi,
           Var = s2,DP = dp,
           Q1 = q1,Q3 = q3,
           CV = cv,EPM = epm,
           G1 = g1,G2 = g2,
           Norm = pSW))
}











