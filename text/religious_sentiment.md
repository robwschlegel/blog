# Religious Sentiment
Robert Schlegel  
15 May 2017  




## Objective
Before we begin, I would like to acknowledge that the framework for this analysis was adapted from a [blogpost](https://www.r-bloggers.com/parsing-text-for-emotion-terms-analysis-visualization-using-r/) found on the wonderfully interestingly [R-bloggers](https://www.r-bloggers.com/) website. The objective of this analysis is to use sentiment analysis on different religious texts to visualise the differences/ similarities between them. This concept is of course fraught with a host of issues. Not least of which being detractors who will likely not endeavour to engage in rational debate against the findings of this work. This is of course beyond the control of the experimental design so I rather focus here on the issue that the translations of the texts used are not modern, and none of them were written (and generally not intended to be read in) English. Therefore a sentiment analysis of these works will be given to a certain amount of inaccuracy because the sentiment database is a recent project and one must assume that the emotions attached to the words in the English language reflect modern sentiment, and not the emotive responses that were necessarily desired at the time of writing/ translation. That being said, the sentiment that these texts would elicit in a reader today (assuming that anyone actually still reads the source material for their faith) would be accurately reflected by the sentiment analysis project and so this issue is arguably a minor one. As a control group (non-religious text), we will be using _Pride and Prejudice_, by Jane Austen simply because this has already been ported into R and is readily accesible in the package 'janeaustenr'.

For more information on the sentiment analysis project one may find the home page [here](http://saifmohammad.com/WebPages/NRC-Emotion-Lexicon.htm).

## Text Downloads
The following links were used to download the religious texts used in this analysis:

- [Quran](http://www.qurandownload.com/English-Quran(Yusuf-Ali)-WB.pdf)
- [Bible(New Testament)](http://www.christistheway.com/pdfs/KJVnew.pdf)
- [Torah](http://www.ishwar.com/ebooks/judaism.html)
- [Bhagavad Gita](http://www.dlshq.org/download/bgita.pdf)
- [Egyptian Book of the Dead](http://www.holybooks.com/wp-content/uploads/Egyptian-Book-of-the-Dead.pdf)

I generally used the first link that DuckDuckGo provided when searching for pdf versions of these books. If anyone knows of better sources for these texts please let me know and I would be happy to update the data source.

## Packages
The packages required to perform the following analysis

```r
library(pdftools)
library(tidyverse)
library(tidytext)
library(janeaustenr)
library(RmarineHeatWaves)
```

## Analysis
First we convert the PDF's to text and merge them.

```r
## Load the texts
# Pride and Prejudice
pride <- data_frame(txt = prideprejudice, 
                    src = "pride")
# Quran
quran <- data_frame(txt = as.character(pdf_text("~/blog/data/EQuran.pdf")),
                    src = "quran")
# Bible
bible <- data_frame(txt = as.character(pdf_text("~/blog/data/KJBNew.pdf")),
                    src = "bible")
# Torah
torah <- data_frame(txt = as.character(pdf_text("~/blog/data/Torah.pdf")), 
                    src = "torah")
# Bhagavad Gita
gita <- data_frame(txt = as.character(pdf_text("~/blog/data/BGita.pdf")), 
                    src = "gita")
# Book of the dead
dead <- data_frame(txt = as.character(pdf_text("~/blog/data/EBoD.pdf")),
                   src = "dead")
# Combine
texts <- rbind(pride, quran, bible, torah, gita, dead)
```

After loading and merging the texts we want to run some quick word counts on them.

```r
# Total relevant words per text
total_word_count <- texts %>%
  unnest_tokens(word, txt) %>%  
  anti_join(stop_words, by = "word") %>%
  filter(!grepl('[0-9]', word)) %>%
  filter(!grepl('www.christistheway.com', word)) %>%
  left_join(get_sentiments("nrc"), by = "word") %>%
  group_by(src) %>%
  summarise(total = n()) %>%
  ungroup()

# Total emotive words per text
emotive_word_count <- texts %>% 
  unnest_tokens(word, txt) %>%                           
  anti_join(stop_words, by = "word") %>%                  
  filter(!grepl('[0-9]', word)) %>%
  filter(!grepl('www.christistheway.com', word)) %>%
  left_join(get_sentiments("nrc"), by = "word") %>%
  filter(!(sentiment == "negative" | sentiment == "positive" | sentiment == "NA")) %>%
  group_by(src) %>%
  summarise(emotions = n()) %>%
  ungroup()

# Positivity proportion
positivity_word_count <- texts %>% 
  unnest_tokens(word, txt) %>%                           
  anti_join(stop_words, by = "word") %>%                  
  filter(!grepl('[0-9]', word)) %>%
  filter(!grepl('www.christistheway.com', word)) %>%
  left_join(get_sentiments("nrc"), by = "word") %>%
  filter(sentiment == "positive" | sentiment == "negative") %>%
  group_by(src, sentiment) %>%
  summarise(emotions = n()) %>%
  summarise(positivity = emotions[sentiment == "positive"]/ emotions[sentiment == "negative"]) %>% 
  ungroup()

# Combine
word_count <- cbind(total_word_count, emotive_word_count[2], positivity_word_count[2]) %>% 
  mutate(proportion = round(emotions/total, 2))

# Lolliplot
ggplot(data = word_count, aes(x = as.factor(src), y = proportion)) +
  geom_lolli() +
  geom_point(aes(colour = positivity)) +
  geom_text(aes(y = 0.45, label = paste0("n = ", total)), colour = "red") +
  scale_y_continuous(limits = c(0,0.5)) +
  scale_color_continuous("Proportion of\nPositivity", low = "steelblue", high = "salmon") +
  labs(x = "Text", y = "Proportion of Emotive Words")
```

![Proportion of emotive words in each text to their total word counts (shown in red).](../figures/rs-lolli-1.png)

I find it somewhat surprising that The Egyptian Book of the Dead would have the highest proportion of positive sentiment to negative sentiment.

But let's take a more in depth look at the sentiment for each text.

```r
# Calculate emotions
emotions <- texts %>% 
  unnest_tokens(word, txt) %>%                           
  anti_join(stop_words, by = "word") %>%                  
  filter(!grepl('[0-9]', word)) %>%
  filter(!grepl('King James Version of the New Testament - ', word)) %>%
  filter(!grepl('www.christistheway.com', word)) %>% 
  filter(!grepl('BHAGAVAD GITA', word)) %>%
  left_join(get_sentiments("nrc"), by = "word") %>%
  filter(!(sentiment == "negative" | sentiment == "positive")) %>%
  group_by(src, sentiment) %>%
  summarize(freq = n()) %>%
  mutate(proportion = round(freq/sum(freq),2)) %>%
  # select(-freq) %>%
  ungroup()
```


```r
# Boxplot
ggplot(emotions, aes(x = sentiment, y = proportion)) +
  geom_boxplot(fill = "grey70") +
  geom_point(aes(colour = src), position = "jitter", size = 2) +
  labs(x = "Sentiment", y = "Proportion", colour = "Text")
```

![Boxplots of emotion for the texts. Individual scores shown as coloured points.](../figures/rs-box-1.png)


```r
ggplot(emotions, aes(x = sentiment, y = proportion)) +
  geom_polygon(aes(fill = src, group = src), alpha = 0.6, show.legend = FALSE) +
  coord_polar() +
  scale_y_continuous(limits = c(0, 0.3)) +
  facet_wrap(~src) +
  labs(x = "", y = "")
```

![Frequency polygons of the proportion of emotions for each text shown in facets.](../figures/rs-poly-1.png)

## Results
The frequency polygons shown here most notably outline that all of the texts emphasise trust over anything else. Another interesting pattern is the lack of surprise employed in the texts. The Bhagavad Gita seems to have the smoothest distribution of emotion, with the Quran perhaps coming in second. I found it odd that a novel, Pride and Prejudice, would employ a higher proportion of joyous sentiment than the religious texts against which it was compared. The Quran just barely nudges out the Bhagavad Gita to come out on top for angry and fearful sentiment. The Torah stands out from the other texts due to the amount of disgust expressed therein. After Pride and Prejudice, the Bible uses the largest proportion of words that elicited emotions of anticipation.

There is still much more that may or may not be deduced from these cursory results. Most notably lacking from this analysis is any test for significant differences. The reason for that being that I am not interested in supporting any sort of argument for differences between these texts. With _n_ values (word count) in excess of 3,000 significant differences between the different texts is almost guaranteed as well so any use of a _p_-value here would just be cheap p-hacking anyway.

