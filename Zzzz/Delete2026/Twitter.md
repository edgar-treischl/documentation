OLD Twitter Code

```r
#Some Examples for future research: Content Analysis

#If packages are not available, install....
#

install.packages("twitteR")



library(ROAuth)
library(twitteR)
library(ggplot2)
library(wordcloud)
library(tm)
library(stringr)





#Get access to the Twitter: Create an application interface (API)
#https://apps.twitter.com

consumer_key <- "Insert_KEY"
consumer_secret <- "Insert_Secret"
access_token <- "Insert_KEY"
access_secret <- "Insert_Secret"

#Now tell Twitter who you are....
setup_twitter_oauth(consumer_key,consumer_secret, access_token, access_secret)




#Now we can try to search for something
searchTwitter("iphone")


#You can specify location over geocode: NYC
searchTwitter('apartment hunting', geocode='40.7361,-73.9901,5mi',  n=41, retryOnRateLimit=1)


#Lets save tweets about Trump
trump.tweets = searchTwitter("#Trump")
head(trump.tweets)

# Create data frame to see structur
data.trump = twListToDF(trump.tweets)
head(data.trump)




#Search for Authors or specific groups/persons
tweets_donald <- userTimeline('realDonaldTrump') # Rts = Retweets

donald.data = twListToDF(tweets_donald)
head(donald.data)



#Retrieve User Info and Followers
user <- getUser("realDonaldTrump")
user$toDataFrame()

#We can also have information about friends and followers
friends <- user$getFriends() # who this user follows
followers <- user$getFollowers() # this user's followers
followers2 <- followers[[1]]$getFollowers() # a follower's followers

head(friends)




################################################
#What does Donald Trump tells the world?
################################################

tweets_election<- userTimeline('realDonaldTrump', n = 3200,
                           includeRts = TRUE, excludeReplies = TRUE)

head(tweets_election)


#did it work?
length(tweets_election)


#Tell R where it shall save your data
setwd("C:/Users/etreisch/Desktop/Twitter_R")

#Finally you can save your data
write.csv(dm, file = "mydata.csv")


```
