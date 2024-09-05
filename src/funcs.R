# helper functions

expit <- function(x) exp(x)/(1 + exp(x))
logit <- function(x) log(x/(1-x))

# For a logistic GLMM, the icc is given by sigma-squared / (sigma-squared + pi^2 / 3)
# This function takes in an icc and returns the random intercept variance, sigma-squared, which will come in handly for simuat
sigmasq_given_icc <- function(icc){
  var_logistic = (pi^2) / 3
  return(sigmasq = (var_logistic * icc) / (1 - icc))
}