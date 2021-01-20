# Will Pearse's Machine Learning Handout

##### Section 1: PCA #####
library(mvtnorm)

set.seed(123)

covariance <- matrix(c(5,3,0,-3,0,3,5,0,-3,0,0,0,5,0,0,-3,-3,0,6,0,0,0,0,0,3), nrow=5)

data <- rmvnorm(1000,sigma=covariance)

colnames(data) <- c("a","b","c","d","e")

pca <- prcomp(data)
biplot(pca)
biplot(pca,choices=2:3)

pca         
plot(pca$x[,2]~data[,3], xlab="c variable", ylab="PC2")

summary(pca) #can see relative importance of each axis
plot(pca)

#variance has to be equal to PCA to work, need to z transform data

pca <- prcomp(data,scale=TRUE)

biplot(pca)

##Excercises
library(raster)
r <- getData("worldclim", var="bio", res=10 )
e <- extent(150,170,-60,40)
data <- data.frame(na.omit(extract(r, e)))
names(data) <- c("temp.mean","diurnal.range", "isothermality",
                 "temp.season","max.temp","min.temp","temp.range","temp.wettest",
                 "temp.driest","temp.mean.warmest","temp.mean.coldest","precip",
                 "precip.wettest","precip.driest","precip.season","precip.wettest",
                 "precip.driest","precip.warmest","precip.coldest")

pca <- prcomp(data,scale=TRUE)
biplot(pca)
summary(pca)
pca
plot(pca)
# 4 important axes of variation is needed
# PCA1 caputres variance of everything, PCA2 captures mostly temperatures,
# PCA 3 captures diurnal range, PCA4 captures precipitation

# excercise 2
data(iris)
head(iris[,-5])
pca <- prcomp(iris[,-5],scale=TRUE )
biplot(pca)
pca
plot(pca)
summary(pca)

plot(pca$x[,1:2], pch=20,
     col=setNames(c("red","blue","black"),c("setosa","versicolor","virginica")))

# Not a good way to categorize them, cant seperate the different species


##### Section 2: Hierarchical Cluster Analysis #####
data <- data.frame(rbind(
  cbind(rnorm(50),rnorm(50)),
  cbind(rnorm(50,5), rnorm(50,5)),
  cbind(rnorm(50,-5), rnorm(50,-5))
))

# two columns of 3 different groups of data
data$groups <- rep(c("red","blue","black"), each=50)
names(data)[1:2] <- c("x","y")

with(data, plot(y ~ x, pch=20, col=groups))

#calculate euclidean distance matrix
distance <- dist(data[,c("x","y")])
upgma <- hclust(distance,method="average")
plot(upgma)
comp.link <- hclust(distance)
plot(comp.link)

#cut the tree by groups
cut.by.groups <- cutree(upgma, k=2)
plot(cut.by.groups)
cut.by.height <- cutree(upgma, h=8)
plot(cut.by.height)

library(splits)

gap.stat <- ddwtGap(data[,c("x","y")])
with(gap.stat, plot(colMeans(DDwGap),pch=15,type='b',
                    ylim=extendrange(colMeans(DDwGap),f=0.2),
                    xlab="Number of Clusters", ylab="Weighted Gap Statistic"))
#shows for how many clusters, what the DDgap is --> basically the optimal cluster number
print(gap.stat$mnGhatWG)

##Excercise 1##
library(cluster)
votes <- na.omit(cluster::votes.repub)
logit <- function(x) log(x/(1-x))
transformed <- logit(votes/100)

distance <- dist(transformed)
upgma <- hclust(distance,method="average")
plot(upgma)
comp.link <- hclust(distance)
plot(comp.link)

gap.stat <- ddwtGap(transformed, genRndm="uni")
with(gap.stat, plot(colMeans(DDwGap),pch=15,type='b',
                    ylim=extendrange(colMeans(DDwGap),f=0.2),
                    xlab="Number of Clusters", ylab="Weighted Gap Statistic"))
#dont particularly agree with results, but it is the best given the data



##### Section 3: K-Means Analysis #####
data <- data.frame(rbind(
  cbind(rnorm(50),rnorm(50)),
  cbind(rnorm(50,2.5),rnorm(50,2.5)),
  cbind(rnorm(50,-2.5),rnorm(50,-2.5)),
  cbind(rnorm(50,5), rnorm(50,5)),
  cbind(rnorm(50,-5), rnorm(50,-5))
))
data$groups <- rep(c("red","blue","grey80","grey60","grey20"), each=50)
names(data)[1:2] <- c("x","y")
with(data, plot(y ~ x, pch=20, col=groups))

k.means <- kmeans(data[,-3], centers=5, nstart=10)
table(k.means$cluster, data$groups)
#but need to set arbitiary number of groups

#Use gap statistics:
library(splits)
gap.stat <- ddwtGap(data[,c("x","y")])
with(gap.stat, plot(colMeans(DDwGap),pch=15,type='b',
                    ylim=extendrange(colMeans(DDwGap),f=0.2),
                    xlab="Number of Clusters", ylab="Weighted Gap Statistic"))
gap.stat$mnGhatWG 


#Fuzzy clustering
library(fclust)
fuzzy <- FKM(data[,c("x","y")], k=5)
summary(fuzzy)
plot(fuzzy)

#model based clustering
library(mclust)
model <- Mclust(data[,-3])
summary(model)
model
plot(model, what="BIC")

## Excercise
data(iris)
head(iris)

gap.stat <- ddwtGap(iris[,-5])
with(gap.stat, plot(colMeans(DDwGap),pch=15,type='b',
                    ylim=extendrange(colMeans(DDwGap),f=0.2),
                    xlab="Number of Clusters", ylab="Weighted Gap Statistic"))
gap.stat$mnGhatWG

#k means:
k.means <- kmeans(iris[,-5], centers=3, nstart=10)
table(k.means$cluster, iris$Species)
# kmeans does a much better job than PCA, identified species pretty well
# using a clustering paradigm works better when trying to group species, PCA just finds the groups that explains variances the best

# using model selection based:
model <- Mclust(iris[,-5])
summary(model)
model
plot(model, what="BIC")


##### Principle Co-ordinate Analysis #####
#simulating dataset:
intercepts <- rnorm(20, mean=20)
env1 <- rnorm(20)
env2 <- rnorm(20)

env <- expand.grid(env1=seq(-3,3,0.5), env2=seq(-3,3,0.5))
biomass <- matrix(ncol=20, nrow=nrow(env))
for(i in seq_len(nrow(biomass))){ 
  biomass[i,] <- intercepts + env1*env[i,1] + env2*env[i,2]}

library(vegan)
dist <- vegdist(biomass)
pcoa <- cmdscale(dist, eig=TRUE)
barplot(pcoa$eig)

plot(pcoa$points[,1:2], type="n", xlab="PCoA1", ylab="PCoA2")
plot(pcoa$points[,1:2], xlab="PCoA1", ylab="PCoA2")
text(pcoa$points[,1:2]+0.025, labels=env[,1], col="red")
text(pcoa$points[,1:2]-0.025, labels=env[,2], col="black")

