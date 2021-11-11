library(tidytext)
library(tidyverse)
library(ggplot2)
library(forcats)
library(wordcloud)
library(textdata)
library(lda)
library(tm)
library(topicmodels)
```

# We will start by loading our data set

twitter_data <- read.csv("Tweets.csv", stringsAsFactors = FALSE, header = T)
head(twitter_data)


# As our next step we will tokenize the tweets i.e., we will extract words from complete texts

tidy_twitter <- twitter_data %>% 
  # Tokenize the twitter data
  unnest_tokens(word, text) #choosing the column name to tokenize which is the "text" column

tidy_twitter #we have a new column that is called "word" in the new data frame which consists of tokenized words

# Now, we will compute word counts and arrange them in descending order

tidy_twitter %>% 
  count(word) %>%  # Compute word counts
  arrange(desc(n)) # Arrange the counts in descending order

# Looking at the word counts we are going to decide on some custom stop words which we will remove froum our data set

custom_stop_words <- tribble(
  # Column names should match stop_words
  ~word,  ~lexicon,
  # Add http, win, and t.co as custom stop words
  "http", "CUSTOM",
  "win",  "CUSTOM",
  "t.co", "CUSTOM",
  "1", "CUSTOM",
  "2", "CUSTOM",
  "3", "CUSTOM",
  "ı", "CUSTOM"
)


# We will join our custom stop words with the standard stop words 

# Bind the custom stop words to stop_words
stop_words2 <- stop_words %>% 
  bind_rows(custom_stop_words)


# Remove all the stop words from the data set

tidy_twitter <- twitter_data %>% 
  unnest_tokens(word, text) %>% # Tokenize the twitter data
  anti_join(stop_words2) # Remove stop words


# Again we will look our word counts and include only those greater than 100

word_counts <- tidy_twitter %>% 
  count(word) %>% 
  filter(n>100) %>% # Keep words with count greater than 100
  arrange(desc(n))


# Visualize our word counts

ggplot(word_counts, aes(word, n)) +
  geom_col() +
  coord_flip()  # Flip the plot coordinates

# From above you can see that our visualization does not make much sense so we will reorder our words 

word_counts <- tidy_twitter %>% 
  count(word) %>%   # Keep terms that occur more than 100 times
  filter(n > 100) %>% 
  mutate(word2 = fct_reorder(word, n))  # Reorder word as an ordered factor by word counts


# Again, the plot below is a bit complicated but at least it is ordered by the word counts

ggplot(word_counts, aes(x = word2, y = n)) +
  geom_col() +
  coord_flip() +
  ggtitle("Word Counts")

# For the sake of simplicity we will keep the top 30 words by word count

word_counts <- tidy_twitter %>%
  count(word) %>%
  top_n(30, n) %>% # Keep the top 30 words
  mutate(word2 = fct_reorder(word, n)) 


# Visualize our top counted words that mentioned above

ggplot(word_counts, aes(x = word2, y = n)) +
  geom_col(show.legend = FALSE) +   # Exclude the legend for the column plot
  coord_flip() +  # Flip the coordinates 
  ggtitle("Twitter Word Counts") # Add a title: "Twitter Word Counts

# Now, we will compute a word count of 30 words, those words that are counted more will de shown bigger in the visualization

# Compute word counts and assign to word_counts
word_counts <- tidy_twitter %>% 
  count(word)

wordcloud(
  words = word_counts$word,  # Assign the word column to words
  freq = word_counts$n, # Assign the count column to freq
  max.words = 30,
  colors = "blue"
) 

# Since we have visualized and examined our words the next step will be to establish sentiments with the one of the most popular dictionaries called NRC

# Count the number of words associated with each sentiment in nrc
get_sentiments("nrc") %>% 
  count(sentiment) %>% 
  arrange(desc(n)) # Arrange the counts in descending order

# Above you can see the kinds of sentiments that are included in the NRC dictionary. Now we will reorder our sentiment counts

sentiment_counts <- get_sentiments("nrc") %>% 
  count(sentiment) %>% 
  mutate(sentiment2 = fct_reorder(sentiment, n))


# Next step will be to visualize the sentiment counts

# Visualize sentiment_counts using the new sentiment factor column
ggplot(sentiment_counts, aes(sentiment2, n)) +
  geom_col() +
  coord_flip() +
  labs(
    title = "Sentiment Counts in NRC",
    x = "Sentiment",
    y = "Counts"
  )

# Finally we will NRC dictionary with the Twitter data

# Join tidy_twitter and the NRC sentiment dictionary
sentiment_twitter <- tidy_twitter %>% 
  inner_join(get_sentiments("nrc"))


# Count our sentiments and then arrange by descending order

# Count the sentiments in sentiment_twitter
sentiment_twitter %>% 
  count(sentiment) %>% 
  arrange(desc(n))  # Arrange the sentiment counts in descending order

# Now we will look at different sentiments based on our choices and top words 

word_counts <- tidy_twitter %>% 
  # Append the NRC dictionary and filter for positive, fear, and trust
  inner_join(get_sentiments("nrc")) %>% 
  filter(sentiment %in% c("positive", "negative", "trust", "anticipation", "sadness")) %>%
  count(word, sentiment) %>%   # Count by word and sentiment 
  group_by(sentiment) %>% 
  top_n(20, n) %>% # Take the top 20 of each
  ungroup() %>% 
  mutate(word2 = fct_reorder(word, n)) # Create a factor called word2 that has each word ordered by the count


# Now, we will visualize our sentiments

# Create a bar plot out of the word counts colored by sentiment
ggplot(word_counts, aes(x = word2, y = n, fill = sentiment)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ sentiment, scales = "free") +  # Create a separate facet for each sentiment with free axes
  coord_flip() +
  labs(
    title = "Sentiment Word Counts",
    x = "Words"
  )

# Above, we visualized 5 different sentiments of our choice and each sentiment cluster consists of 20 words based on the count of the words that are associated with that cluster
# Now, we will spread the NRC dictionary to look like a matrix where the numbers indicate the word counts and the words are matched with their sentiments

word_counts %>% 
  # Append the NRC sentiment dictionary
  inner_join(get_sentiments("nrc")) %>% 
  # Spread the sentiment and count columns
  spread(sentiment, n)

# As our next step we will ddiscover the afinn dictionary which is another popular sentiment dictionary. 
# Afinn dictionary gives numeric values to every word. Negative numbers indicate negative feelings, positive numbers indicate positive feelings of the word

afinn_twitter <- tidy_twitter  %>%
  inner_join(get_sentiments("afinn")) %>%  # Append the afinn sentiment dictionary
  group_by(word) %>%
  summarize(aggregate_value = sum(value))
afinn_twitter

# As our final step we will run a latent Dirichlet allocation (LDA) model and for this to happen we need to convert our data set into a matrix

# Assign the DTM to dtm_twitter
dtm_twitter <- tidy_twitter %>% 
  count(word, tweet_id) %>% 
  # Cast the word counts by tweet into a DTM
  cast_dtm(tweet_id, word, n)



matrix_twitter <- as.matrix(dtm_twitter)


# It is time to run our LDA model with 2 topics. Topics are actually self-explanatory concepts. 
# They indicate the grouped words that have similar sentiments or structures. 
#You can try different number of topics to see what they are useful for, you only need to change the number of the parameter "k"

# Run an LDA with 2 topics and a Gibbs sampler
lda_out <- LDA(
  matrix_twitter, # matrix to be used
  k = 4, # indicates the number of topics
  method = "Gibbs", # indicates the lda method
  control = list(seed = 42)
)


# We will explore our LDA model with 4 topics and arrange word probabilites by descending order

# Glimpse the topic model output
glimpse(lda_out)

# Tidy the matrix of word probabilities
lda_topics <- lda_out %>% 
  tidy(matrix = "beta")

# Arrange the topics by word probabilities in descending order
lda_topics %>% 
  arrange(desc(beta))


# Next we will select top 15 words based on their counts and reorder the model based on the word probabilities

# Select the top 15 terms by topic and reorder term
word_probs2 <- lda_topics %>% 
  group_by(topic) %>% 
  top_n(15, beta) %>% 
  ungroup() %>%
  mutate(term2 = fct_reorder(term, beta))


# As the final step we will visualize our LDA model based on the topics and word probabilities

# Plot word probs, color and facet based on topic
ggplot(
  word_probs2, 
  aes(term2, beta, fill = as.factor(topic))
) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  coord_flip()

# A Short Note From the Author
# This notebook was aimed to give a brief introduction to Sentiment Analysis. 
# I consider myself as the student of this work and not as the author of it. 
# I am also in a learning process and further contribution to this notebook is more than welcomed. 
# I strongly believe in open source argument and I believe that as a community we can learn from each other by sharing our work. 
# I hope this notebook will be useful to some people out there.




