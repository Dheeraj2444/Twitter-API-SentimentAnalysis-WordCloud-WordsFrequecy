# Twitter-API-SentimentAnalysis-WordCloud-WordsFrequecy
* Function for **sentiment analysis**, **wordcloud** and **word frequecy** of tweets using **twitteR**, **tm** packages and concepts of **NLP**.

* The main script to run is **twitter.R** which calls two functions in file 'tweets_cleaning.R' and 'sentiment_function.R'. 

* With the help of **tweets_cleaning.R** you can keep collating your tweets over a period of time in a .csv file which would help in better understanding of trend over long period (since as per new policy in twitter api, maximum of last 6-9 days tweets can be extracted using the api). It converts collected tweets into vector scourced corpus, further cleans tweets (removing stopwords, numbers, punctuations, whitespaces, url), does stemming of words and creates document-term matrix which is further used to analyse words frequency.

* **sentiment_function.R** is used for calculating sentiments attached with the tweet. Opinion lexicons (positive and negative) are available at https://www.cs.uic.edu/~liub/FBS/sentiment-analysis.html and can be downloaded from here. This is the compiled list of **(Hu and Liu, KDD-2004)** starting from their first paper. It contains around 6800 english words.
