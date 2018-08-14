# Skrip ini digunakan untuk:
# 1. extract username dari column text
# 2. extract hashtag dari column text
# 3. user_all = gabungan username dari dalam text (user_inv)+ user pengirim (sender)

library(tidyverse)
library(qdap)
library(textclean)
library(tidytext)

# fungsi ----
tweet_wrangler <- function(data, # data frame
                           column1, # kolom teks
                           column2) # kolom pengirim twit
  {
  # involved
  user_inv <- as.character(data[ ,column1])
  user_inv <- sapply(str_extract_all(user_inv, "(@[[:alnum:]_]*)", 
                                     simplify = FALSE), paste, collapse=", ")
  user_inv <- data_frame(user_inv)
  # sender
  user_send <- as.character(data[ ,column2])
  user_send <- data_frame(paste0("@", user_send))
  colnames(user_send) <- "sender"
  
  # user_all
  user_all <- bind_cols(user_send, user_inv)
  user_all <- unite(data = user_all, col = user_all, sep = ", ", remove = TRUE)
  
  # removing punctuation between user
  user_all$user_all <- gsub("[^[:alnum:][:space:]@_]", "", user_all$user_all)
  # removing white space at the start and at the end of string
  user_all$user_all <- gsub("^[[:space:]]+", "", user_all$user_all)
  user_all$user_all <- gsub("[[:space:]]+$", "", user_all$user_all)
  # user count
  user_all$user_count <- sapply(user_all$user_all, function(x) 
    length(unlist(strsplit(as.character(x), "\\S+"))))
  
  # hashtag
  hashtag <- as.character(data[ ,column1])
  hashtag <- sapply(str_extract_all(data_tweet$text, "(#[[:alnum:]_]*)", 
                                    simplify = FALSE), paste, collapse=", ")
  hashtag <- data_frame(hashtag)
  
  data_all <- bind_cols(user_send, user_inv, user_all, hashtag)
}

# tesss ----

data_tweet <-read.csv(text=getURL("https://raw.githubusercontent.com/eppofahmi/belajaR/master/cdc-workshop/latihan-cdc.csv"), header=T, sep = ",", stringsAsFactors = FALSE)

tweet_user <- tweet_wrangler(data = data_tweet, column1 = 2, column2 = 12)