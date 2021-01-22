#Machine learning sections for the ML handout
rm(list=ls())

x <- rnorm(1000)
y <- -x

data <- data.frame(scale(cbind(x,y)))
library(neuralnet)

model <- neuralnet(y~x, hidden=0, data=data)
plot(model)


#simulate more complicated data
explanatory <- data.frame(replicate(10,rnorm(400)))
names(explanatory) <- letters[1:10]
response<- with(explanatory, a*2 - 0.5*b - i*j + exp(abs(c)))
data <- data.frame(scale(cbind(explanatory, response)))


training <- sample(nrow(data),nrow(data)/2)
model <- neuralnet(response~a+b+c+d+e+f+g+h+i+j, dat=data[training,], hidden=5)

cor.test(compute(model, data[-training,1:10])$net.result[,1],data$response[-training])
plot(model)

library(NeuralNetTools)
garson(model, bar_plot=FALSE)
garson(model)


