###
### Simulate grouped, zero-truncated Poisson count data and 
### fit model using zt.poisson.varying.coef.3.mcmc.R
###

rm(list=ls())
library(mvtnorm)

I <- 200  # number of observations per group
J <- 10  # number of groups
g <- rep(1:J,each=I)  # grouping variable


##########################################################
### Population-level process model parameters
##########################################################

mu.beta <- matrix(c(0,2.5),,1)  # mean of betas
qX <- nrow(mu.beta)
rho <- -0.15  # correlation between betas
Sigma <- diag(qX)*0.75  # variance-covariance of betas
Sigma[1,2] <- Sigma[2,1] <- Sigma[1,1]*Sigma[2,2]*rho

##########################################################
### Simulate group-level process model parameters
##########################################################

beta <- t(rmvnorm(J,mu.beta,Sigma))  # betas for each group
plot(t(beta))

##########################################################
### Simulate count data
##########################################################

X <- cbind(1,rnorm(I*J,0,sd=1))  # design matrix
beta.tmp <- t(beta[,g])
lambda <- exp(rowSums(X*beta.tmp))  # intensity of Poisson process
hist(lambda,breaks=100)
z <- rpois(I*J,lambda)  # observed count data
table(z>0)

##########################################################
### Fit model
##########################################################

source('~/Documents/git/zero/truncated/zt.poisson.varying.coef.3.mcmc.R')
start <- list(beta=beta,mu.beta=mu.beta,Sigma=Sigma)
priors <- list(sigma.beta=5,S0=diag(qX),nu=qX+1)
tune <- list(beta=rep(0.5,J))
out1 <- zt.poisson.varying.coef.3.mcmc(z[z>0],X[z>0,],g[z>0],
	priors,start,tune,adapt=TRUE,n.mcmc=2000)
out1$tune

# Examine estimates for beta_j
g.idx <- 1  # group idx for plotting beta_j
matplot(out1$beta[,,g.idx],type="l",lty=1);abline(h=beta[,g.idx],col=1:qX,lty=2)

# Examine estimates for mu.beta
matplot(out1$mu.beta,type="l");abline(h=mu.beta,col=1:qX,lty=2)

# Examine estimates for Lambda
matplot(cbind(out1$Sigma[1,1,],out1$Sigma[1,2,]),type="l")
abline(h=c(Sigma[1,1],Sigma[1,2]),lty=2,col=1:qX)


