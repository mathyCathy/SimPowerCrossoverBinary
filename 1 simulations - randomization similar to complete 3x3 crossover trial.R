source("src/funcs.R")
library(dplyr)
library(lme4)

# These simulations are based on a logistic GLMM with random effects for each individual 
#    to account for the clustering from the 4-repeat experiments.

# Model: logit(p_t) = b0 + b1 * I(treat_t = treat) + (b_s)_t, random effect for each individual
# b_s ~ N(0, sd = sigma_s)

# As a first step (while I'm thinking through the blocks size),
# I'm first considering a 3X3 cross over type design (which might be a reasonable option)
# 8 X each randomization sequence [12 of them] = 96 individuals


##.         Setting up simulation parameters.         ##

# For these power simulations, I will need the 12 cross-over scenarios enumerated in Adi's Table 1.
# Enumerating all 12 randomization sequences
# V: Valsalva
# RC: right carotid
# LC: left carotid
randomSeqTab = data.frame(sequence_no = 1:12,
                          period1 = c(rep("V", 6), rep("RC", 3), rep("LC", 3)),
                          period2 = c(rep("V", 2), rep("RC", 2), rep("LC", 2), "V", "LC", rep("V", 2), "RC", "V"),
                          period3 = c("RC", "LC", "V", "LC", "V", "RC", "V", "V", "LC", "V", "V", "RC"),
                          period4 = c("LC", "RC", "LC", "V", "RC", "V", "LC", "V", "V", "RC", "V", "V")
)

# First considering a 3X3 cross over type design
# 8 X each randomization sequence = 96 individuals
assignmentList = rep(seq(1:12), 8)

# Randomization list
set.seed(1)
randomList = sample(assignmentList, length(assignmentList), replace = FALSE)

# Getting b0 and b1 based on estimated outcome prevalences
p_ref = 0.20 # 20% conversion in carotid
p_v = 0.35   # 35% conversion in valsalva

b0 = logit(p_ref) # -1.386294
odds_ref = p_ref / (1 - p_ref)
odds_V = p_v / (1 - p_v)
b1 = log(odds_V / odds_ref) # 0.7672552

# Note: random intercept variance is a function of intracluster correlation, ICC
# Here we consider a range from minimal to moderate clustering
icc = c(0.01, 0.05, 0.1, 0.2, 0.3, 0.4)

# Generating R simulated datasets
R = 1000

# Collecting operating characteristics for all simulation runs (vary # datasets, vary icc)
simArr = array(NA, dim = c(R, 6, length(icc)), 
               dimnames = list(1:R, 
                               c("b0", "b1", "Var", "p<0.05", "phat_ref", "phat_v"), 
                               paste("icc:", icc)))

for (r in 1:R){
  for (i in 1:length(icc)){
    set.seed(r)
    
    # Randomize here
    randomList = sample(assignmentList, length(assignmentList), replace = FALSE)
    
    # Setting up data
    idDat = data.frame(ID = 1:length(randomList), 
                       randomList = randomList)
    covDat_wide = dplyr::left_join(idDat, randomSeqTab, dplyr::join_by("randomList" == "sequence_no"))
    n_subj = nrow(idDat)
    
    covDat_long = tidyr::gather(covDat_wide, key = "period", value = "treat_cat", 3:6) %>% arrange(ID, period) %>%
      mutate(valsalva = ifelse(treat_cat == "V", 1, 0))
    
    # Random effects
    re_var = sigmasq_given_icc(icc[i])
    rand_eff = rep(rnorm(n = n_subj, mean = 0, sd = sqrt(re_var)), each = 4)
    
    simDat = covDat_long %>% 
      mutate(lin_pred = b0 + b1 * (treat_cat == "V") + rand_eff,
             phat = expit(lin_pred),
             y = rbinom(n = nrow(covDat_long), size = 1, prob = phat)
      )
    
    mod = lme4::glmer(y ~ valsalva + (1 | ID), 
                      data = simDat, 
                      family = binomial(link = "logit"), 
                      control = glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=2e5)),
                      nAGQ = 2)
    sum_mod = summary(mod)
    
    simArr[r,1:3,i] = c(sum_mod$coef[,1], as.numeric(sum_mod$varcor))
    simArr[r,4,i] = ifelse(sum_mod$coef[2,4] < 0.05, 1, 0)
    simArr[r,5:6,i] = simDat %>% group_by(valsalva) %>% summarise(m = mean(y)) %>% ungroup() %>% dplyr::select(m) %>% unlist()
  }
}

save(simArr, file = "output/20240904_simArr_run1.Rdat")


