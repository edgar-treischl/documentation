## Raw Material for EBF Slides: Confounder and Co

```r
library(ggplot2) 
library(dplyr) 
library(tidyverse)
library(broom)
library(jtools)
library(stargazer)

#Confounder############################
confounder <- rnorm(1000, 10, 2)

x <- rnorm(1000, 5, 3) + 0.5*confounder

y <- 1 + rnorm(1000, 1, 1) + 0.5*confounder


(data <- data.frame(x, y, confounder) %>%
    as_tibble())



fm <- lm(y ~ x)
summary(fm)




fm <- lm(y ~ x + confounder)
summary(fm)


#Grafisch
y_hat<- fitted.values(fm)
error <- residuals(fm)
(data <- data.frame(x, y, confounder,y_hat, error) %>%
    as_tibble())


# Setting up the building blocks
basic_plot <- ggplot(data,
                     aes(x = confounder,
                         y = x)) +
  labs(x = "Confunder",
       y = "Y/X")
basic_plot



basic_plot +
  geom_point(alpha = .3, 
             size = .9) +
  geom_smooth(method = "lm", fullrange=TRUE)+
  scale_shape_manual(values=c(16, 3))+
  scale_color_manual(values=c("#dc3522", "#0395DE"))+
  theme_minimal()+
  theme(legend.position="bottom")


#Shoe size example################
set.seed(12334)

men <- rep(c(0,1), 500)
men.label <- c("Women", "Men")



length(men)

schoesize <- rnorm(1000, 36, 4) + men*rnorm(1000, 4, 2)

income <- rnorm(1000, 1000, 333) + men*rnorm(1000, 600, 250)


(data <- data.frame(men, schoesize, income) %>%
    as_tibble())

#Raw Data Grafisch
data %>% 
  group_by(men) %>% 
  summarise(count = n()) %>% 
  ggplot(aes(y=count, x=men, fill = men)) + 
  geom_bar(position="stack", stat="identity")

ggplot(data, aes(x=income, fill = men)) + 
  geom_histogram()

ggplot(data, aes(x=schoesize, y = men)) + 
  geom_boxplot()


#Regress it

m1 <- lm(income ~ schoesize)
summary(m1)

#summ(m1)



m2 <- lm(income ~ schoesize + men)
summary(m2)

#stargazer(m1, m2, type="text")

#export_summs(m1, m2, scale = FALSE, model.info = FALSE)

#Graphisch
p1<- ggplot(data,
       aes(x = schoesize,
           y = income)) +
  labs(x = "Shoesize",
       y = "Income")+
  geom_point(alpha = .3, 
             size = .9) +
  geom_smooth(method = "lm", formula = y ~ x, fullrange=TRUE)+
  scale_shape_manual(values=c(16, 3))+
  scale_color_manual(values=c("#dc3522", "#0395DE"))+
  theme_minimal(base_size = 18)+
  theme(legend.position="bottom")



#Sub-Plot for Men and Women
data$men <- factor(data$men, levels = c("0", "1"), 
                   labels = c("Women", "Men"))


p2<- ggplot(data,
       aes(x = schoesize,
           y = income)) +
  labs(x = "Shoesize",
       y = "Income")+
  geom_point(alpha = .3, 
             size = .9) +
  geom_smooth(method = "lm", fullrange=TRUE)+
  scale_shape_manual(values=c(16, 3))+
  scale_color_manual(values=c("#dc3522", "#0395DE"))+
  theme_minimal(base_size = 18)+
  theme(legend.position="bottom")+
  facet_wrap(. ~ men, ncol=2)

gridExtra::grid.arrange(p1, p2, ncol=2)


#Mediator################################
set.seed(12334)

x <-  rnorm(1000, 10, 3)

(df <- data.frame(x) %>%
    as_tibble())

df$random1<- runif(nrow(df),min=min(df$x),max=max(df$x))
#Important step 1: The mediator = 0,5*x * 0,5*random variable
df$mediator <- df$x*0.5+ df$random1*0.5

#Correct?
cor(df$x, df$random1)
cor(df$x, df$mediator)


df$random2<- runif(nrow(df),min=min(df$mediator),max=max(df$mediator))
#Important step 2: y = 0,5*random variable + 0,5*mediator
cor(df$random2, df$mediator)

df$y<- 0.5*df$mediator + 0.5*df$random2

df

fit.x=lm(y~x, df)
summary(fit.x)

fit.mediator=lm(y~mediator,df)
summary(fit.mediator)

fit.model=lm(y~ x + mediator,df)
summary(fit.model)





#Collider################################
x <- 1 + rnorm(1000, 5, 3)
#y <- rnorm(1000, 10, 1) 
y <- rnorm(1000, 10, 1) + 1*x

collider <-  1*x + 1*y + rnorm(1000, 1, 1)

data <- data.frame(x, y, collider) %>%
    as_tibble()


m1 <- lm(y ~ x)
summary(m1)

m2 <- lm(y ~ x + collider)
summary(m2)

#jtools
library(jtools)
#export_summs(fm1, fm2)

export_summs(m1, m2, scale = TRUE, model.info = FALSE)


#install.packages("gtsummary")
library(gtsummary)

t1 <- tbl_regression(m1)
t2 <- tbl_regression(m2)



tbl_merge(
    tbls = list(t1, t2),
    tab_spanner = c("**Model 1**", "**Model 2**")
  )



#BS:Mediator O/1################################
set.seed(12334)


x <-  rnorm(1000, 10, 3)

(df <- data.frame(x) %>%
    as_tibble())

df$men <- rep(c(0,1), 500)


df$random1<- runif(nrow(df),min=min(df$x),max=max(df$x))
#Important step 1: The mediator = 0,5*x * 0,5*random variable
df$mediator <- (df$x*0.5)*df$men +  df$random1*0.5

#Correct?
cor(df$x, df$random1)
cor(df$x, df$mediator)


df$random2<- runif(nrow(df),min=min(df$mediator),max=max(df$mediator))
#Important step 2: y = 0,5*random variable + 0,5*mediator
cor(df$random2, df$mediator)

df$y<- 0.5*df$mediator + 0.5*df$random2

df

fit.x=lm(y~x, df)
summary(fit.x)

fit.mediator=lm(y~mediator,df)
summary(fit.mediator)

fit.model=lm(y~ x + mediator,df)
summary(fit.model)


#in Graphs?
ggplot(df, aes(x=x, y = y))+
  geom_point()+
  geom_smooth()+
  facet_wrap(. ~ men, ncol=2)


#Simpsons Paradox###############
library(GGally)
library(ggplot2)
library(tidyverse)
library(viridis)


# Create data
set.seed(1)
a <- data.frame(x = 5 + rnorm(100), y = 5 + rnorm(100)) %>% mutate(y = y-x/4)
c <- a %>% mutate(x=x+2) %>% mutate(y=y+2)
data <- do.call(rbind, list(a,c))
data <- data %>% mutate(Sex=rep(c("Men", "Women"), each=100))


p1<- ggplot(data, aes(x=x, y=y)) +
  geom_point(size=2, color="#8A8FA1") +
  theme_minimal()+
  geom_smooth(method = "lm", formula = y ~ x, color="#29303B") 


p2 <- ggplot(data, aes(x=x, y=y, color=Sex)) +
  geom_point(size=2) +
  scale_colour_manual(values =c ("#8A8FA1", "#0057AD"))+
  theme_minimal()+
  theme(legend.position="none")

gridExtra::grid.arrange(p1, p2, ncol=2)



df_text <- data.frame(
  x = c(8, 8),
  y = c(5.5, 2.9),
  text = c("Women", "Men")
)


ggplot(data) +
  geom_smooth(aes(x=x, y=y), method = "lm", 
              formula = y ~ x, se=TRUE, color="#29303B", fullrange=TRUE) +
  geom_point(aes(x=x, y=y, color=Sex), size=2) +
  geom_smooth(aes(x=x, y=y, color=Sex), 
              method = "lm", formula = y ~ x, se=FALSE, fullrange=TRUE) +
  scale_colour_manual(values =c ("#8A8FA1", "#0057AD"))+
  theme_minimal()+
  theme(legend.position="none")+
  geom_label(data = df_text, 
             aes(x = x, y = y, label = text) ,
             fill= c("#0057AD", "#8A8FA1"),
             size = 3,
             color= c("white", "white"))


```

## Further raw material
```r
#*FakeR*
#*
#*

#Confounder/Colider Functions###################

confounder <- function(n, r) {
  z <- rnorm(n, 1, 1)
  x <- rnorm(n, 1, 1) + r*z
  y <- rnorm(n, 1, 1) + r*z
  data.frame(x, y, z)
  
}

confounder(n= 500, r = 0.2)



collider <- function(n, r) {
  x <- rnorm(n, 5, 3)
  y <- rnorm(n, 10, 1) 
  #y <- rnorm(n, 10, 1) + 1*x
  collider <-  r*x + r*y + rnorm(n, 1, 1)
  data.frame(x, y, collider)
  
}

collider(n = 500, r = 1)


mediator <- function(n, m) {
  x <-  rnorm(n, 10, 3)
  random1<- runif(n, min=min(x),max=max(x))
  #Important step 1: The mediator = 0,5*x * 0,5*random variable
  mediator <- x*m+ random1*(1-m)
  
  random2<- runif(n, min=min(mediator), max=max(mediator))
  #Important step 2: y = 0,5*random variable + 0,5*mediator
  y <- m*mediator + (1-m)* random2
  
  data.frame(x, y, mediator)

}

df <- mediator(n = 2000, m = .5)

fm <- lm(y ~ x, df)
summary(fm)

fm <- lm(y ~ x + mediator, df)
summary(fm)

ggplot(data=df, aes(x=x, y=y)) +
  geom_smooth()+
  geom_point()


#Binary#######
var_binary <- function(x, a, b) {
  set.seed(12334)
  foo <- as.factor(rbinom(x, 1, .5))
  binary <- factor(foo, 
                   labels = c(noquote(a), 
                              noquote(b)))
  return(binary)

}

women <- var_binary(100, "Men", "Women")


#Nominal variable##########
var_nominal <- function(n, groups, labels) {
  var <- factor(rep(c(1:groups), times = n), 
                levels = c(1:groups),
                labels = sort(labels))
  sample(var, size = n, replace = TRUE)
  
}

var_nominal(n = 500, 
           groups = 4, 
           labels = c("Sehr", "Arsch", "Medium", "Bauer"))


#Ordinal##########
var_ordinal <- function(n, groups, labels, seed=NULL) {
  set.seed(seed)
  var <- factor(rep(c(1:groups), times = n), 
                levels = c(1:groups),
                labels = labels)
  sample(var, size = n, replace = TRUE)
  
}

rating <- var_ordinal(n = 100,
            groups = 3, 
            labels = c("Sehr gut", "Mittel", "Sehr schlecht"))

rating


df <- data.frame(women, rating)
head(df)



library(ggplot2)
library(tidyverse)

df2 <- df %>%
  group_by(women)%>%
  count(rating)

ggplot(data=df2, aes(x=rating, y=n, fill=women)) +
  geom_bar(stat="identity", position=position_dodge())


#Shoesexexample#######################
var_confounder <- function(n, y, sd, bonus) {
  set.seed(12334)
  sex <- rbinom(n, 1, .5)
  schoesize <- rnorm(n, 36, 4) + sex*rnorm(n, 4, 2)
  bonus <- sex*rnorm(n, bonus, sd)
  income <- rnorm(n, y, sd) + sex*rnorm(n, bonus, sd)
  sex <- as.factor(sex)
  sex <- factor(sex,
                levels = c(0, 1),
                labels = c("Female", "Male"))
  df <- data.frame(sex, schoesize, income)
}

var_confounder(n = 10, 
               y = 2000, 
               sd = 250,
               bonus = 1000)

df <- var_confounder(n = 1000, 
        y = 2000, 
        sd = 250,
        bonus = 1000)



cor(df$schoesize, df$income)

m1 <- summary(lm(income~schoesize, data=df))
m1



ggplot(data=df, aes(x=schoesize, y=income)) +
  geom_smooth(method = lm)+
  geom_point()

ggplot(data=df, aes(x=schoesize, y=income, color=sex)) +
  geom_smooth(method = lm)+
  geom_point()

```
