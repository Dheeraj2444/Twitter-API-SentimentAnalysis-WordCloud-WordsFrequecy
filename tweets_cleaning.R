#!/bin/usr/Rscript

twitter_analysis <- function(name){
  #colating tweets
  tweets <- searchTwitter(name, n = 1500)
  cat('\n tweets read')
  df <- twListToDF(tweets)
  df <- df[, order(names(df))]
  df$created <- strftime(df$created, '%Y-%m-%d')
  if (file.exists(paste('/home/dheeraj/r_codes/twitter_sentiment/', name, '_tweet_data.csv')) == FALSE) 
    write.csv(df, file= paste('/home/dheeraj/r_codes/twitter_sentiment/', name, '_tweet_data.csv'), row.names = F)
  #merge last access with cumulative file and remove duplicates
  tweet_data <<- read.csv(file= paste('/home/dheeraj/r_codes/twitter_sentiment/', name, '_tweet_data.csv'))
  tweet_data <<- rbind(tweet_data, df)
  tweet_data <<- subset(tweet_data, !duplicated(tweet_data$text))
  tweet_data <<- subset(tweet_data, tweet_data$screenName != name)
  write.csv(tweet_data, file= paste('/home/dheeraj/r_codes/twitter_sentiment/', name, '_tweet_data.csv'), row.names = F)
  cat('\n tweet_data created')
  #cleaning tweet data
  tweets.df <- tweet_data
  tweets_corpus <- Corpus(VectorSource(tweets.df$text))
  tweets_corpus <- tm_map(tweets_corpus, content_transformer(tolower), lazy = T)
  remove_url <- function(x){
    gsub("http[^[:space:]]*", "", x)
  }
  tweets_corpus <- tm_map(tweets_corpus, content_transformer(remove_url), lazy = T)
  remove_num_punc <- function(x){
    gsub("[^[:alpha:][:space:]]*", "", x)
  }
  tweets_corpus <- tm_map(tweets_corpus, content_transformer(remove_num_punc), lazy = T)
  tweets_corpus <- tm_map(tweets_corpus, removePunctuation)
  tweets_corpus <- tm_map(tweets_corpus, removeNumbers)
  my_stopwords <- c(stopwords('english'), 'via', 'rt', name)
  tweets_corpus <- tm_map(tweets_corpus, removeWords, my_stopwords, lazy = T)
  tweets_corpus <- tm_map(tweets_corpus, stripWhitespace)
  tweets_corpus <- tm_map(tweets_corpus, stemDocument)
  cat('\n tweets cleaned')
  tdm <- TermDocumentMatrix(tweets_corpus, control = list(wordLengths = c(1, Inf)))
  # freq_terms <- findFreqTerms(tdm, lowfreq = 15)
  terms_freq <<- sort(rowSums(as.matrix(tdm)), decreasing = T)
  terms_freq <<- subset(terms_freq, terms_freq >= 15)
  term_freq_df <<- data.frame(term = names(terms_freq), freq = terms_freq) 
  cat('\n calculation done..plotting plots')
}
