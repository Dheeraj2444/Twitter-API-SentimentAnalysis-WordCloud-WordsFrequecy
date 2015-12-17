#!/bin/usr/Rscript

#sentiment
score.sentiment <- function(sentences, pos.words, neg.words){
  cat('\n sentiment started')
  scores <- laply(sentences, function(sentence, pos.words, neg.words){
    sentence <- gsub('[[:punct:]]', "", sentence)
    sentence <- gsub("http\\w+", "", sentence) # remove html links
    sentence <- gsub('[[:cntrl:]]', "", sentence) #removing control character
    sentence <- gsub("(RT|via)((?:\\b\\W*@\\w+)+)", "", sentence) # remove retweet entities
    sentence <- gsub("@\\w+", "", sentence) # remove at people 
    sentence <- gsub('\\d+', "", sentence) #replacing digits
    sentence <- tolower(sentence)
    word.list <- str_split(sentence, '\\s+')
    words <- unlist(word.list)
    pos.matches <- match(words, pos.words)
    neg.matches <- match(words, neg.words)
    pos.matches <- !is.na(pos.matches)
    neg.matches <- !is.na(neg.matches)
    score <- sum(pos.matches) - sum(neg.matches)
    return(score)
  }, pos.words, neg.words)
  scores.df <- data.frame(score=scores, text=sentences)
  return(scores.df)
}
