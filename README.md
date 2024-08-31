# SimPowerCrossoverBinary
Simulation-based power calculations for a cross-over trial with a dichotomous outcome modeled using GLMMs

<!-- ABOUT THE PROJECT -->
## Underlying assumptions and math

* $$\mathrm{logit}(Y_{ij}) = \beta_0 + \beta_{0i} + \beta_1 I(\mathrm{Treat_{ij}=B}) + \beta_2 I(\mathrm{Treat_{ij}=C}) + \xi_{j},$$ for individuals $i=1,\dots,N$ and crossover period $j=1,\dots,J$.  
