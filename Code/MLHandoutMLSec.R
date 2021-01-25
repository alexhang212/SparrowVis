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


#####Deep Learning and Tensor Flow#####
rm(list=ls())

exp <- replicate(10, rnorm(400))
resp <- exp[,1]*2 -0.5*exp[,2] - exp[,7]*exp[,8] + exp(abs(exp[,3])) + rnorm(nrow(exp))

exp <- as.matrix(scale(exp)); resp <- as.numeric(scale(resp))
training <- sample(nrow(exp), nrow(exp)/2)

library(keras)
install_keras()


model <- keras_model_sequential()
model %>%
  layer_dense(units=15, activation='relu',input_shape=10)%>%
  layer_dense(units=15, activation = 'relu') %>%
  layer_dense(units=1)

model %>% compile(loss='mean_squared_error', 
                  optimizer = optimizer_rmsprop(),
                  metrics=c('mean_squared_error'))

model %>% fit(exp[training,], resp[training], epoch =500)

plot(predict(model, exp[-training,])[,1]~resp[-training])
cor.test(predict(model, exp[-training,])[,1], resp[-training])

#visualization
model %>% fit(
  exp[training,],resp[training], epoch=500,
  callbacks=callback_tensorboard("../Results/")
)
tensorboard("../Results/")


data <- read.csv("../Data/2017-06-30.csv", row.names=1, as.is=T)
with(data,plot(rating~year))

#cant quite do it, data not appropriate


######Convolutional Neural Network#####
#demonstration data
raw.data <- dataset_fashion_mnist()
resp <- raw.data$train$y
exp <- raw.data$train$x

lookup <- c("T-shirt/top", "Trouser", "Pullover", "Dress",
            "Coat", "Sandal", "Shirt", "Sneaker", "Bag", "Ankle boot")
exp <- exp/255
pdf("../Results/images.pdf")
par(mfrow=c(5,5))
for(i in seq_len(5*5)) image(t(exp[i,28:1,]),main=lookup[resp[i]+1], col=grey.colors(255))
dev.off()

model <- keras_model_sequential()
model %>% layer_flatten(input_shape=c(28,28)) %>%
  layer_dense(units=128, activation = 'relu')%>%
  layer_dropout(rate=0.5) %>%
  layer_dense(units=10, activation = 'softmax') #output layer

model %>% compile(
  optimizer = 'adam',
  loss='sparse_categorical_crossentropy',
  metrics = c('accuracy')
)

model %>% fit(x=exp,y=resp,epochs=5)


