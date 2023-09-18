#Packages and libraries
library(tidyverse)
library(lattice)

#Loading data
data1<-mtcars
data2<-read.csv("ttest.csv")
data3<-read.csv("ANOVA.csv")
data4<-read.csv("correl.csv")

#Creating objects
Y<-mtcars$mpg
X<-mtcars$wt

#Basic exploration of data
View(data1)
str(data1)

#Descriptive statistics for all variables
summary(data1)

#Descriptive stats plots per variable
histogram(Y)#same than histogram(data$Y) or histogram(~Y,data)
bwplot(Y)

#Inferential statistics

#two sample t-test
t.test(time~daytime,data2)

#ANOVA aov(Y ~ X, data)
ggplot(data3)+
  aes(mode, students, group = mode)+
  geom_boxplot()
summary(aov(students~mode,data=data3))

#Relationship
#Scatterplot
xyplot(FXRUSD~FXREUR,data4)
#correlation (Pearson)
cor(data4$FXRUSD,data4$FXREUR,method="pearson")
#correlation (Spearman)
cor(data4$FXRUSD,data4$FXREUR,method="spearman")
#linear regression
lm(FXRUSD~FXREUR,data4)


