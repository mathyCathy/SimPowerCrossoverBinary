# SimPowerCrossoverBinary
Simulation-based power calculations for a cross-over trial with a dichotomous outcome modeled using GLMMs

<!-- ABOUT THE PROJECT -->
## Underlying assumptions and math

* Logistic random effects model (GLMM) given by $$\mathrm{logit}(Y_{ij}) = \beta_0 + \beta_{0i} + \beta_1 I(\mathrm{Treat_{ij}=B}) + \beta_2 I(\mathrm{Treat_{ij}=C}) + \xi_{j},$$ for individuals $i=1,\dots,N$ and crossover period $j=1,\dots,J$. Each individual has a random effect $\beta_{0i} \sim N(0,\sigma^2)$, and we allow for variation in the outcome prevalence during each crossover period given by $\xi_{j}$.
* Note that for a logistic GLMM, the intracluster coefficient is given by $$\mathrm{ICC}=\displaystyle\frac{\sigma^2}{\sigma^2 + \sigma_e^2},$$ where $\sigma_e^2 = \pi^2/3$. So for power calculation simulations, we can determine the value of $\sigma^2$ by setting the ICC, which is commonly done in power calculations, as follows: $$\sigma^2 = \displaystyle\frac{\sigma_e^2 \mathrm{ICC}}{(1-\mathrm{ICC})}.$$
