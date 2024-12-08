
```r
library(readr)
library(tidyverse)
library(janitor)

survey_lung_cancer <- read_csv("~/Downloads/survey lung cancer.csv")
survey_lung_cancer <- drop_na(survey_lung_cancer)
survey_lung_cancer <- as.data.frame(survey_lung_cancer)
head(survey_lung_cancer)
#View(survey_lung_cancer)


df <- survey_lung_cancer |> 
  select(GENDER, AGE, SMOKING, LUNG_CANCER)|> 
  clean_names()

head(df)

df$male <-  if_else(df$gender == "M", 0, 1)
df$smoker <-  if_else(df$smoking == "1", 0, 1)
df$cancer <-  if_else(df$lung_cancer == "NO", 0, 1)


# Minimal code to run a logistic regression
logit_model <- glm(cancer ~ male + smoker,
                   family = binomial(link = "logit"),
                   data = df
)

# Print a summary
summary(logit_model)


#Train
df_train <- df[1:250, ]
df_test <- df[251:309, ]

df
#Train Labels
df_train_labels <- df[1:250, 4]
df_test_labels <- df[251:309, 4]
length(df_train_labels)

df_train <- df_train |> select(age, male, smoker)
df_test <- df_test |> select(age, male, smoker)
length(df_train$age)

library(class)
knn_result <- knn(train = df_train, test = df_test, cl = df_train_labels, k = 3) 
knn_result



library(caret)
confusionMatrix(data = knn_result, reference = as.factor(df_test_labels))



#As Graph
cm <-confusionMatrix(data = knn_result, reference = as.factor(df_test_labels))
plt <- as.data.frame(cm$table)


ggplot(plt, aes(x = Reference, y = Prediction, fill= Freq)) +
  geom_tile() + 
  geom_text(aes(label=Freq)) +
  scale_fill_gradient(low="white", high="darkred") +
  labs(x = "Reference",
       y = "Prediction")+
  theme_minimal()

```
