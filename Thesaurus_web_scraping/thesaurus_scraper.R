#############################
# Title : Web scraping for synonyms and antonyms from thesaurus.com site
# Author : Prasad Kharde
# Date : 13th Feb 2020
#############################

#Execution Flow : 
# 1. Load the dataset for letter and links and total page numbers for each letter
# 2. Get all the words for letter
# 3. For each word, get the first synonym and antonym
# 4. Final output should be a dataframe consisting of following columns:
#     | Word | Synonym | Antonym | Link |
#
#Note: Synonym and antonym should be placed in same row 
#     as a single entry with words separated by ';'.
#
#Reference: https://www.analyticsvidhya.com/blog/2017/03/beginners-guide-on-web-scraping-in-r-using-rvest-with-hands-on-knowledge/
#
#################################################
#rm(list=ls())
# load the library
library(rvest)
library(stringr)
#################################################


#################################################
# Step 1
# Load the data for letter
thesaurus_data <- read.csv("~/R/Thesaurus_web_scraping/thesaurus_letter_page_number.csv")
#################################################


#################################################
# Step 2 
# Get all the words from website
all_words <- data.frame(word=character(0))
total_letters <- 26

#took around 6 minutes 30 seconds
for (i in 1:total_letters) {
  base_url <- as.character(thesaurus_data[i,2])
  letter_total_page <- thesaurus_data[i,3]
  letter_page_link <- character(length(letter_total_page))
  for(j in 1:letter_total_page) {
    letter_url <- paste(base_url,j,sep = "")
    letter_webpage <- read_html(letter_url)
    letter_html_words <- html_nodes(letter_webpage, '.e1j8zk4s1')
    letter_page_words <- html_text(letter_html_words)
    letter_page_words <- as.data.frame(letter_page_words,row.names = NULL)
    all_words <- rbind(all_words, letter_page_words)
  }
}

#write.csv(all_words, file = "all_words.csv", row.names = FALSE)
#################################################


#################################################
# Step 3
# Get the synonym and antonym for the each word
#rm(list=ls())
#took around 52 hours 8 minutes

word_data <- read.csv("~/R/Thesaurus_web_scraping/all_words.csv", sep="", stringsAsFactors=FALSE)
total_word <- nrow(word_data)
browse_url <- "https://www.thesaurus.com/browse/"
thesaurus <- data.frame(word=character(0),browser_word=character(0),
                       url=character(0),synoyms=character(0),antonyms=character(0))

for (i in 131903:total_word) {
  actual_word <- word_data[i,1]
  current_word <- str_replace_all(actual_word, " ","%20")
  current_word <- str_replace_all(current_word, "'","%27")
  current_url <-paste(browse_url,current_word,sep = "")
  word_webpage <- read_html(current_url)
  
  #Get all synonym words
  syn_words_html <- html_nodes(word_webpage, '.en1b8750+ .e1qo4u830 .et6tpn80')
  syn_words <- html_text(html_children(syn_words_html[1]))
  
  #Get all antonym words
  ant_words_html <- html_nodes(word_webpage, '.em66cyi0+ .e1qo4u830 .et6tpn80')
  ant_words <- html_text(html_children(ant_words_html[1]))
  
  #update the dataframe
  synoyms <- toString(syn_words)
  antonyms <- toString(ant_words)
  temp_data <- data.frame(actual_word,current_word,current_url,synoyms,antonyms)
  thesaurus <- rbind(thesaurus,temp_data)
  
  print(paste0("passed number: ", i, " word : ", current_word))
}


write.csv(thesaurus, file = "thesaurus_all_of_it.csv", row.names = FALSE)
