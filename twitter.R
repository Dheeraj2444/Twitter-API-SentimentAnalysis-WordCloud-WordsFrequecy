#!/bin/usr/Rscript

library(twitteR)
library(tm)
library(ggplot2)
library(wordcloud)
library(RColorBrewer)
library(plyr)
library(dplyr)
library(stringr)

#connect to API
# download.file(url='http://curl.haxx.se/ca/cacert.pem', destfile='cacert.pem')
reqURL <- 'https://api.twitter.com/oauth/request_token'
accessURL <- 'https://api.twitter.com/oauth/access_token'
authURL <- 'https://api.twitter.com/oauth/authorize'
#Add you consumer key and consumer secret
consumerKey <- '' 
consumerSecret <- ''  
Cred <- OAuthFactory$new(consumerKey=consumerKey,
                          consumerSecret=consumerSecret,
                          requestURL=reqURL,
                          accessURL=accessURL,
                          authURL=authURL)
 Cred$handshake(cainfo = system.file('CurlSSL', 'cacert.pem', package = 'RCurl')) #There is URL in Console. You need to go to, get code and enter it in Console
 save(Cred, file='/home/dheeraj/r_codes/twitter_sentiment/twitter_authentication.Rdata')

################################################## Just load the auth object to connect again ################################################

load('/home/dheeraj/r_codes/twitter_sentiment/twitter_authentication.Rdata') 
setup_twitter_oauth(consumerKey, consumerSecret, access_token=NULL, access_secret=NULL)

#Analyse twitter
pos <- scan('/home/dheeraj/r_codes/twitter_sentiment/positive_words.txt', what='character', comment.char=';') 
neg <- scan('/home/dheeraj/r_codes/twitter_sentiment/negative_words.txt', what='character', comment.char=';') 
#positive and negative words should be updated as per your account need or business need
pos.words <- c(pos, 'upgrade', 'tasty')
neg.words <- c(neg, 'wtf', 'wait', 'waiting', 'epicfail', 'late', 'delay', 'refund', 'fail', 'apologize', 'regret')
names <- c('Flipkart', 'amazon' 'snapdeal') #change these twitter handle for which you need to analyse
rm(list = c('pos', 'neg'))

source('/home/dheeraj/r_codes/twitter_sentiment/twitter_test.R')
source('/home/dheeraj/r_codes/twitter_sentiment/sentiment_function.R')

      for(i in names){
        twitter_analysis(i)
        # word freq plot
        ggplot(term_freq_df, aes(x= term, y= freq)) + geom_bar(stat= 'identity') + xlab('words') + ylab('count') + coord_flip()
        ggsave(paste('/home/dheeraj/r_codes/twitter_sentiment/', i, '_word_freg.jpg'))
        #word_cloud
        jpeg(paste('/home/dheeraj/r_codes/twitter_sentiment/', i, '_word_cloud.jpg'), width= 12, height= 8, units= "in", res= 300)
        wordcloud(term_freq_df$term, term_freq_df$freq, random.order= FALSE, colors= brewer.pal(8, "Dark2"))
        dev.off()
        #sentiment
        Dataset <- tweet_data
        Dataset$text <- as.factor(Dataset$text)
        Dataset <- subset(Dataset, select = c('created', 'text'))
        Dataset$text <- sapply(Dataset$text, function(row) iconv(row, "latin1", "ASCII", sub=""))
        scores <- score.sentiment(Dataset$text, pos.words, neg.words)
        write.csv(scores, file= paste('/home/dheeraj/r_codes/twitter_sentiment/', i, '_scores.csv'), row.names = F) #save evaluation results into the file
        #total evaluation: positive / negative / neutral
        stat <- scores
        stat$created <- Dataset$created
        stat$created <- as.Date(stat$created)
        stat <- mutate(stat, tweet=ifelse(stat$score > 0, 'positive', ifelse(stat$score < 0, 'negative', 'neutral')))
        by.tweet <- group_by(stat, tweet, created)
        by.tweet <- summarise(by.tweet, number=n())
        # write.csv(by.tweet, file=paste('/home/dheeraj/r_codes/twitter_sentiment/' ,names, '_opin.csv'), row.names=TRUE)
        #create chart
        ggplot(by.tweet, aes(created, number)) + geom_line(aes(group=tweet, color=tweet), size=2) +
          geom_point(aes(group=tweet, color=tweet), size=4) +
          theme(text = element_text(size=18), axis.text.x = element_text(angle=90, vjust=1)) + ggtitle(i)
        ggsave(file=paste('/home/dheeraj/r_codes/twitter_sentiment/', i, '_plot.jpeg'))
      }
