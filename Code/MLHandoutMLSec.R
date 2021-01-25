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
test.resp <- raw.data$test$y
test.exp <- raw.data$test$x
test.exp <- test.exp/255

model %>% evaluate(test.exp,test.resp)
predictions <-model %>% predict(test.exp)
table(apply(predictions,1,which.max)-1,test.resp)


#Convoluted network:
conv <- keras_model_sequential()%>%
  layer_conv_2d(filters=20, kernel_size=c(3,3), activation='relu',
                input_shape = c(28,28,1)) %>%
  layer_max_pooling_2d(pool_size=c(2,2))%>%
  #layer_dropout(rate=0.25)%>%
  layer_flatten() %>%
  layer_dense(units=20, activation='relu')%>%
  layer_dense(units=10, activation='softmax')%>%
  compile(optimizer='adam',
          loss='sparse_categorical_crossentropy',
          metrics=c('accuracy'))
  
array.exp <- array(exp, dim=c(dim(exp),1))
conv %>% fit(array.exp,resp,epochs=10)

#run in smaller subset:
subset.exp <- array.exp[1:500,,,]
s.array.exp <- array(subset.exp, dim=c(dim(subset.exp),1))
conv %>% fit(array.exp,resp,epochs=10)

#validate model:
test.resp <- array(raw.data$test$y, dim=c(dim(raw.data$test$y),1))
test.exp <- array(raw.data$test$x, dim=c(dim(raw.data$test$x),1))
test.exp <- test.exp/255

conv %>% evaluate(test.exp,test.resp)
predictions <-conv %>% predict(test.exp)
table(apply(predictions,1,which.max)-1,test.resp)

#freezing networks
#can continue training networks
new <- keras_model_sequential() %>%
  conv%>% #previous model
  layer_dense(units=10, activation = "softmax")%>%
  compile(optimizer = 'adam', loss="sparse_categorical_crossentropy", 
          metrics=c('accuracy'))
new %>% fit(s.array.exp, resp[1:500], epochs=10)

#freeze layers
freeze_weights(conv)
freeze_weights(conv, from="dense_8")

new %>% compile(
  optimizer = 'adam',
  loss = 'sparse_categorical_crossentropy',
  metrics = c('accuracy')
)
new %>% fit(s.array.exp, resp[1:500], epochs=10)

unfreeze_weights(conv)

#add augementation/ variation to data
for(i in 1:20){
  augmented <- array.exp + rnorm(length(as.numeric(exp)),sd=0.1)
  conv %>% fit(augmented, resp, epoch=1)
}

test.resp <- array(raw.data$test$y, dim=c(dim(raw.data$test$y),1))
test.exp <- array(raw.data$test$x, dim=c(dim(raw.data$test$x),1))
test.exp <- test.exp/255

conv %>% evaluate(test.exp,test.resp)
predictions <-conv %>% predict(test.exp)
table(apply(predictions,1,which.max)-1,test.resp)
lookup



##Excercise##
mnist <- dataset_mnist()
x_train <- mnist$train$x
y_train <- mnist$train$y
x_test <- mnist$test$x
y_test <- mnist$test$y


#flat neural network:
flat <- keras_model_sequential()
flat %>% layer_flatten(input_shape = c(28,28)) %>%
  layer_dense(units=128, activation='relu')%>%
  layer_dropout(rate=0.5) %>%
  layer_dense(units=10, activation = 'softmax') %>%
  compile(optimizer='adam',
          loss='sparse_categorical_crossentropy', 
          metrics= c('accuracy'))

x_train <- x_train/255
flat %>% fit(x_train, y_train, epochs=10)
x_test <- x_test/255

flat %>% evaluate(x_test,y_test) # 97.63% accuracy
predictions <- flat %>% predict(x_test)
table(apply(predictions,1,which.max)-1, y_test)


##CNN##
CNN <- keras_model_sequential()
  CNN %>% layer_conv_2d(filters=20, kernel_size=c(3,3), activation='relu',
                input_shape = c(28,28,1)) %>%
  layer_max_pooling_2d(pool_size = c(2,2))%>%
  #layer_dropout(rate=0.25)%>%
  layer_flatten()%>%
  layer_dense(units=20,activation='relu')%>%
  layer_dense(units=10, activation='softmax')%>%
  compile(optimizer='adam',
          loss='sparse_categorical_crossentropy',
          metrics=c('accuracy'))
  
array_x_train <- array(x_train, c(dim(x_train),1))
array_x_test <- array(x_test, c(dim(x_test),1))

CNN %>% fit(array_x_train, y_train, epochs=10)

CNN %>% evaluate(array_x_test,y_test)#98.63% accuracy, 99.39% accuracy without dropout
predictions <- CNN %>% predict(array_x_test)
table(apply(predictions,1,which.max)-1,y_test)


