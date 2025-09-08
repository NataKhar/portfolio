
all_handles_merged <- readRDS("C:/Users/khari/OneDrive/Desktop/Master Thesis/CSA_tweets/all_handles_merged.rds")
# Filter: Only Tweets in EN
library(dplyr)
read.twitterdata.EN <- all_handles_merged %>%
  dplyr::filter(grepl("^en$", lang))

# Filter: Original tweets
raw.data <- read.twitterdata.EN %>%
  dplyr::filter_at(vars(starts_with("in_reply_to_user_id")), any_vars(is.na(.))) 

#Sample
set.seed(101)
sample_coding_CSA <- ogposts.twitter %>%
  dplyr::slice_sample(n = 9931)

# Import: Coded file
library(readxl)
sample <- read_excel("sample_coding_CSA.xlsx")

library <- c("tm", "textstem", "text2vec", "twitteR", "rtweet", "lubridate", "stringr", "tidytext", "wordcloud", 
             "ggplot2", "plotly","ggrepel", "ggpubr", "gridExtra", 
             "dplyr", "tidyverse", "reshape2", "stargazer", "extrafont",
             "caret", "glmnet", "ROAuth", "scutr", "Metrics", "fastDummies", "car", "lmtest", "lm.beta", "emmeans", "sjPlot", "pscl", "MASS",
             "writexl", "readxl")

# Pre-processing functions
clean_tweets <- function(x) {
  x %>%
    # Remove URLs
    str_remove_all(" ?(f|ht)(tp)(s?)(://)(.*)[.|/](.*)") %>%
    # Remove mentions e.g. "@my_account"
    str_remove_all("@[[:alnum:]_]{4,}") %>%
    # Remove hashtags
    str_remove_all("#[[:alnum:]_]+") %>%
    # Replace "&" character reference with "and"
    str_replace_all("&amp;", "and") %>%
    # Remove puntucation, using a standard character class
    str_remove_all("[[:punct:]]") %>%
    # Remove special characters 
    str_replace_all("[^[:alnum:]]", " ") %>%
    # Remove "RT: " from beginning of retweets
    str_remove_all("^RT:?") %>%
    # Remove Numbers 
    str_remove_all("[[:digit:]]") %>%
    # Replace any newline characters with a space
    str_replace_all("\\\n", " ") %>%
    # Make everything lowercase
    str_to_lower() %>%
    # Remove any trailing whitespace around the text
    str_trim("both") %>%
    # Emojis & Everything else
    rtweet::plain_tweets() %>%
    # Remove more than double white space
    str_squish() %>%
    # Lemmatize
    lemmatize_strings() %>%
    # Stopwords
    removeWords(stop) %>%
    
    return(x)
}

clean_timestamp <- function(y) {
  y %>%
    # Add whitespace after date
    stringr::str_replace("(.{10})(.*)", "\\1 \\2") %>%
    # Remove last 5 characters
    str_replace("(.{5}$)", " ") %>%
    # Remove T
    str_remove("[T]") %>%
    # Remove any trailing whitespace around the text
    str_trim("both") %>%
    # As date time
    ymd_hms() %>%
    
    return(y)
}

# Stopwords
stop = read.table("stopwords.txt", header = TRUE)
stop = as.vector(stop$x)

install_or_load_pack <- function(pack){
  create.pkg <- pack[!(pack %in% installed.packages()[, "Package"])]
  if (length(create.pkg))
    install.packages(create.pkg, dependencies = TRUE)
  sapply(pack, require, character.only = TRUE)
}

### MACHINE LEARNING CSA PREDICTION
library(stringr)
library(textstem)
library(tm)
library(rtweet)

## Pre-processing data set: Standardization, Normalization & Lemmatization
raw.dataCLEAN <- raw.data %>%
  mutate(across(text, clean_tweets)) 


# Pre-processing Prediction: Time stamp (for plotting)
library(lubridate)
raw.dataCLEAN <- raw.dataCLEAN %>%
  mutate(across(created_at, clean_timestamp)) 

raw.dataCLEAN <- raw.dataCLEAN %>% 
  mutate(created_at_month = created_at %>% 
           round_date(unit = "month"))

# Pre-processing Prediction: Whitespace & Digits final 
raw.dataCLEAN$text <- raw.dataCLEAN$text %>%
  str_remove_all("[[:digit:]]") %>%
  str_squish() %>%
  str_trim("both")

# Pre-Processing Prediction: Tokenization
library(quanteda)
library(tokenizers)
library(koRpus)
library(text2vec)

tok_fun <- tokenizers::tokenize_words

it_tweetsOG <- itoken(raw.data$text,
                      tokenizer = tok_fun,
                      ids = raw.dataCLEAN$id,
                      progressbar = TRUE)

## Pre-processing coding sample: Standardization, Normalization & Lemmatization (codingsampleCLEAN needed to build vocab for prediction)

sampleCLEAN <- sample %>%
  mutate(across(text, clean_tweets)) 

# Remove Whitespace & Numbers final
sampleCLEAN$text <- sampleCLEAN$text %>%
  str_remove_all("[[:digit:]]") %>%
  str_squish() %>%
  str_trim("both")

# As factor
sampleCLEAN$CSA <- sampleCLEAN$CSA %>%
  as.factor()

# Check Class Distribution

table(sampleCLEAN$CSA)
prop.table(table(sampleCLEAN$CSA))

# Pre-Processing: Dichotomizing
# Low, Med, High
sampleCLEAN <- sampleCLEAN %>%
  mutate(BAdich = case_when(CSA == 2 ~ 2,
                            CSA == 1 ~ 1,
                            CSA == 0 ~ 0,
                            TRUE ~ 0))

sampleCLEAN$BAdich <- sampleCLEAN$BAdich %>%
  as.factor()
table(sampleCLEAN$BAdich)

# Machine Learning: Training Algorithm
set.seed(100)
library(ggplot2)
library(caret)

#Alternative 1
trainIndex <- createDataPartition(sampleCLEAN$CSA, p = 0.8, 
                                  list = FALSE, 
                                  times = 1)
tweets_train <- sampleCLEAN[trainIndex, ]
tweets_test <- sampleCLEAN[-trainIndex, ]


it_train <- itoken(tweets_train$text, 
                   #preprocessor = prep_fun_lemm, 
                   tokenizer = tok_fun,
                   ids = tweets_train$id,
                   progressbar = TRUE)

it_test <- itoken(tweets_test$text, 
                  #preprocessor = prep_fun_lemm, 
                  tokenizer = tok_fun,
                  ids = tweets_test$id,
                  progressbar = TRUE)

# Machine Learning: Creating vocabulary to be used in prediction
vocab <- create_vocabulary(it_train) 
vectorizer <- vocab_vectorizer(vocab)
dtm_train <- create_dtm(it_train, vectorizer)
dtm_test <- create_dtm(it_test, vectorizer)

# Machine Learning: Tf-idf model to be used in prediction
tfidf <- TfIdf$new()
# Machine Learning: Fit  model to  train data and transformation with fitted model
dtm_train_tfidf <- fit_transform(dtm_train, tfidf)
dtm_test_tfidf <- fit_transform(dtm_test, tfidf)

# 1: Modeling: Train the model
library(glmnet)
glmnet_classifier <- cv.glmnet(x = dtm_train_tfidf, y = tweets_train[["CSA"]], 
                                 family = "multinomial", 
                                 # L1 penalty
                                 #alpha = 1,
                                 type.measure = "deviance",
                                 # 3-fold cross-validation
                                 nfolds = 3,
                               maxit= 1e3,
                               thresh = 1e-3
                                 # high value is less accurate, but has faster training
                                 #thresh = 1e-3,
                                 # again lower number of iterations for faster training
                                 #maxit = 1e3
)

saveRDS(glmnet_classifier, 'C:\\Users\\khari\\OneDrive\\Desktop\\Master Thesis\\CSA_tweets\\glmnet_classifier.RDS')

### Table 2: Evaluation measures 
# Without upsampling
assess.glmnet(glmnet_classifier, dtm_train_tfidf, tweets_train[["CSA"]])

predict(glmnet_classifier, dtm_test_tfidf, s = "lambda.min", type = "class")
pred1 <- predict(glmnet_classifier, dtm_test_tfidf, s = "lambda.min", type = "class")
pred1 <- as.numeric(pred1)

msepred <- data.frame(pred = pred1, actual = tweets_test$CSA)
msepred$actual <- as.numeric(as.character(msepred$actual))

mae(msepred$actual, msepred$pred) 
mse(msepred$actual, msepred$pred)

#confusion.glmnet(glmnet_classifier, dtm_train_tfidf, tweets_train["CSA"])

# Prediction: Creating vocabulary and document-term matrix
dtm_tweetsOG <- create_dtm(it_tweetsOG, vectorizer)

# Prediction: Transforming data with tf-idf
dtm_tweets_tfidfOG <- fit_transform(dtm_tweetsOG, tfidf)
# Prediction: Predict probabilities of tweets being political or social content (Accuracy 90% train and 89% test)
preds_tweetsOG <- predict(glmnet_classifier, dtm_tweets_tfidfOG, type = "class")
### PREDICTION: ADDING RATES TO INITIAL DATA SET
raw.dataCLEAN$CSA <- preds_tweetsOG

raw.dataCLEAN$CSA <- as.numeric(raw.dataCLEAN$CSA)
raw.dataCLEAN$CSA <- as.factor(raw.dataCLEAN$CSA)
summary(raw.dataCLEAN$CSA)

saveRDS(raw.dataCLEAN, 'C:\\Users\\khari\\OneDrive\\Desktop\\Master Thesis\\CSA_tweets\\Done.data.rds')

####################################################################
################# Exploratory Data Analaysis Social Tweets vs. Political Tweets
# Pre-Processing: Tidy Text Format
library(tidytext)
CSA.TIDY <- raw.dataCLEAN %>%
  dplyr::select(conversation_id, text, CSA) %>%
  unnest_tokens(word, text) %>%
  arrange(conversation_id)

### Social:Word cloud
Social <- raw.dataCLEAN[raw.dataCLEAN$CSA == '1', ]

Social.TIDY <- Social %>%
  dplyr::select(conversation_id, text, CSA) %>%
  unnest_tokens(word, text) %>%
  arrange(conversation_id)

social.wordcloud <- Social.TIDY %>%
  count(word, sort = TRUE) %>%
  with(wordcloud(word, n, max.words = 80, scale=c(2.4,0.25)))

### Political: Word cloud
Political <- raw.dataCLEAN[raw.dataCLEAN$CSA == '2', ]

Political.TIDY <- Political %>%
  dplyr::select(conversation_id, text, CSA) %>%
  unnest_tokens(word, text) %>%
  arrange(conversation_id)

political.wordcloud <- Political.TIDY %>%
  count(word, sort = TRUE) %>%
  with(wordcloud(word, n, max.words = 80, scale=c(2.4,0.25)))

####################################################################
################# PREPARATORY CODE FOR ANALYSIS

######Prep control variables
#Year, Month
raw.dataCLEAN <- raw.dataCLEAN %>% 
  mutate(date = created_at %>%
           substring(1,10)) %>%
  mutate(year = created_at %>%
           substring(1,4)) %>%
  mutate(month = created_at %>% 
           substring(6,7)) %>%
  mutate(time = created_at %>%
           substring(12,16))

#Time of the day 
raw.dataCLEAN <- raw.dataCLEAN %>%
  mutate(daytime = case_when(grepl("^06|^07|^08|^09|^10", time) ~ "morning",
                             grepl("^11|^12|^13|^14", time) ~ "midday",
                             grepl("^15|^16|^17", time) ~ "afternoon",
                             grepl("^18|^19|^20|^21", time) ~ "evening",
                             TRUE ~ "night"))


#Day of the week
raw.dataCLEAN$date <- as.character.Date(raw.dataCLEAN$date)

#####Prep DV
#Add DV 
allmetrics <- raw.dataCLEAN$public_metrics
allmetrics <- allmetrics %>%
  mutate(summetrics = rowSums(across(retweet_count:quote_count), na.rm = T)) 
raw.dataCLEAN <- cbind(raw.dataCLEAN, allmetrics)

raw.dataCLEAN <- raw.dataCLEAN %>%
  mutate(CSAfac = as.factor(CSA)) 
#summary(raw.dataCLEAN$CSAfac)

#Transform Controls and CSA topics variable to factor
raw.dataCLEAN <- raw.dataCLEAN %>% 
  mutate(across(c(year, month, daytime), as.factor)) %>%
  mutate(CSAfac = as.factor(CSA))

####################################################################
################# ANALYISIS: NEGATIVE BINOMIAL MODEL
#Figure 7: Distribution of Engagement
ggplot(raw.dataCLEAN, aes(x=summetrics)) + 
  geom_histogram(bins=15) + scale_x_continuous(limits = c(0,50000)) + ylim (0, 2000) + 
  geom_vline(aes(xintercept=mean(summetrics)), color="blue", linetype="dashed", size=1) + 
  xlab("Sum engagement") +
  ylab("Frequency") +
  ggtitle ("Distribution of engagement") +
  theme_minimal() +
  theme(text=element_text(family="Times New Roman", size=12), plot.title = element_text(hjust = 0.5, color = "#666666"))
#+stat_bin(geom="text", colour = "white", size=2.5 ,aes(label=..count..), position=position_stack(vjust=0.5)) 

#DV over-dispersed and Count Variable. Negative Binomial Model or Poisson might be a fit.

#Figure 2: Scatterplots
library(scales)
ggplot(raw.dataCLEAN, 
       aes(x = factor(CSA,
                      labels = c("Not political or social",
                                 "Social context",
                                 "Political context")), 
           y = summetrics, 
           color = CSA)) +
  geom_jitter(alpha = 0.7, 
              size= 1.5) + 
  scale_y_continuous(limits = c(0,5000)) +
  labs(title = "Sum engagement per tweet and CSA", 
       x = "",
       y = "Sum of Engagement") +
  theme_minimal() +
  theme(legend.position = "none")

library(scales)

# Filter data for CSA groups 1 and 2
csa_data <- raw.dataCLEAN %>% filter(CSA %in% c(1,2))

# Figure 3: Violin plots with boxplots 
  ggplot(csa_data, 
         aes(x = CSA,
             y = summetrics)) +
    geom_violin() +
    scale_y_continuous(limits = c(0,200)) +
    geom_violin(fill = "cornflowerblue") +
    geom_boxplot(width = .2, 
                 fill = "orange",
                 outlier.color = "orange",
                 outlier.size = 2) + 
    labs(title = "Sum engagement per tweet and CSA")+
    xlab("CSA context (1- social, 2 - political") + ylab("Sum engagement")

  # log version
  ggplot(csa_data, 
         aes(x = CSA,
             y = log(summetrics))) +
    geom_violin() +
    scale_y_continuous(limits = c(0,15)) +
    geom_violin(fill = "cornflowerblue") +
    geom_boxplot(width = .2, 
                 fill = "orange",
                 outlier.color = "orange",
                 outlier.size = 2) + 
    labs(title = "Sum engagement (log-scale)  per tweet and CSA")+
    xlab("CSA context (1- social, 2 - political") + ylab("Sum engagement")
  
  #a non-parametric test Kruskal-Wallis test (does not assume that the data is normally distributed or that the variances are equal)
  kruskal.test(summetrics ~ CSA, data = raw.dataCLEAN) #YES
  ## p-value is less than 0.05 (0.005075), we can reject the null hypothesis and conclude that there is a significant difference between at least two of the groups.
  
  raw.dataCLEAN$CSA <- factor(raw.dataCLEAN$CSA)
  
 ##The ratio of the variance to the mean
  
 # Calculate the mean and variance of the count data
  mean_count <- mean(raw.dataCLEAN$summetrics)
  var_count <- var(raw.dataCLEAN$summetrics)
  
  # Calculate the variance-to-mean ratio
  vmr <- var_count / mean_count
  
  # Print the variance-to-mean ratio
  print(vmr) #more than 1 (179379) the data is likely over-dispersed and a negative binomial model may be more appropriate than a Poisson model
 
  #Conducting simple NB Model
  nb_model1 <- glm.nb(summetrics ~ CSA, data = raw.dataCLEAN)
  summary(nb_model1) 
  
  #Test for Over-dispersion
  odTest(nb_model1) 
## p-value is less than 0.05, indicating that the NB model provides a better fit to the data than the Poisson model

  #############################################################
  #Model comparison
  nb_model1 <- glm.nb(summetrics ~ CSA, data = raw.dataCLEAN)
  summary(nb_model1) 
  BIC(nb_model1) #1187310
  AIC(nb_model1) #1187272
  
  nb_model2 <- glm.nb(summetrics ~ CSA + year, data = raw.dataCLEAN)
  summary(nb_model2) 
  BIC(nb_model2) #1185161
  AIC(nb_model2) #1185113
  
  nb_model3 <- glm.nb(summetrics ~ CSA + year + month, data = raw.dataCLEAN)
  summary(nb_model3) 
  BIC(nb_model3) #1180064
  AIC(nb_model3) #1179912
 
  nb_model4 <- glm.nb(summetrics ~ CSA + year + month + daytime, data = raw.dataCLEAN)
  summary(nb_model4) 
  BIC(nb_model4) #1178118
  AIC(nb_model4) #1177927
  
  #Figure 8: Model comparison
  stargazer(nb_model4, omit = c("year2021", "daytimemorning", "daytimenight", "daytimemidday", "daytimeevening", "month12","month11","month10","month09","month08","month07","month06", "month05", "month04","month03","month02","month01"), column.labels=c ("Engagement count"),covariate.labels=c( "Social BA context", "Political BA context","No social ot political BA context"), add.lines=list(c("Controls", "Year, month, daytime","")), type = "text", out = "nb_model.txt")
  #Appendix D: Model comparison
  stargazer(nb_model1, nb_model2, nb_model3, nb_model4, omit = c("year2021", "daytimemorning", "daytimenight", "daytimemidday", "daytimeevening", "month12","month11","month10","month09","month08","month07","month06", "month05", "month04","month03","month02","month01"),covariate.labels=c( "Social BA context", "Political BA context","No social ot political BA context"), add.lines=list(c("model1", "Controls: no",""), c("model2", "Controls: Year", ""), c("model3", "Controls: Year, month", ""), c("model4", "Controls: Year, month, daytime", "")), type = "text", out = "modelcomparison.txt") 
  #############################################################
  
  ## Summary statistics of groups: 
  summary_stats <- raw.dataCLEAN %>%
    group_by(CSA) %>%
    summarize(mean_summetrics = mean(summetrics),
              median_summetrics = median(summetrics),
              max_summetrics = max(summetrics),
              min_summetrics = min(summetrics))
  
  summary_stats
  
  summary_stats_1 <- raw.dataCLEAN %>%
    group_by(CSA) %>%
    summarize(mean_like = mean(like_count),
              mean_quote = mean(quote_count),
              mean_reply = mean(reply_count),
              mean_retweet = mean(retweet_count))
  
  summary_stats_1
  
  # Create a dataframe with the given table data
  df <- data.frame(
    CSA = c(0, 1, 2),
    mean_like = c(342, 188, 205),
    mean_quote = c(13.1, 8.75, 114),
    mean_reply = c(22.3, 20.4, 132),
    mean_retweet = c(88.8, 105, 67.7)
  )
  
  # Convert CSA column to a factor for better categorical representation
  df$CSA <- factor(df$CSA)
  
  # Reshape the dataframe from wide to long format
  df_long <- tidyr::pivot_longer(df, cols = -CSA, names_to = "Variable", values_to = "Value")
  
  # Create the plot
  ggplot(df_long, aes(x = CSA, y = Value, fill = Variable)) +
    geom_bar(stat = "identity", position = "dodge") +
    labs(x = "CSA", y = "Mean Value", fill = "Variable") +
    theme_minimal()

  
  # Overall relative frequency: 
  
  # Calculate relative frequencies for each column within each CSA group
  freq_table_1 <- raw.dataCLEAN %>% group_by(CSA) %>% summarise(across(retweet_count:quote_count, prop.table))
  
  # Convert the data to long format
  freq_table_long_1 <- freq_table_1 %>% pivot_longer(cols = retweet_count:quote_count, names_to = "metric", values_to = "freq")
  
  # Plot the data
  library(ggplot2)
  ggplot(freq_table_long_1, aes(x = CSA, y = freq, fill = metric)) +
    geom_bar(position = "dodge", stat = "identity") +
    labs(x = "CSA group", y = "Relative frequency", fill = "Metric") +
    theme_classic()
  
  ## Figure 10. Model comparison of metrics
  stargazer(qu_model3, re_model, li_model1,  rt_model3, omit = c("year2021", "daytimemorning", "daytimenight", "daytimemidday", "daytimeevening", "month12","month11","month10","month09","month08","month07","month06", "month05", "month04","month03","month02","month01"),covariate.labels=c( "Social BA context", "Political BA context","No social ot political BA context"), add.lines=list(c("Quote count", "Controls: Year, month, daytime",""), c("reply count", "Controls: no", ""), c("like count", "Controls: Year", ""), c("retweet count", "Controls: Year, month, daytime", "")), align = "l", type = "text", out = "metrics_modelcomparison.txt")
  
  
  #############################################################
  #Appendix:E. Model comparison of quotes
  
  qu_model <- glm.nb(quote_count ~ CSA, data = raw.dataCLEAN)
  summary(qu_model) 
  BIC(qu_model) #393137.6
  AIC(qu_model) #393099.4
  
  qu_model1 <- glm.nb(quote_count ~ CSA + year, data = raw.dataCLEAN)
  summary(qu_model1) 
  BIC(qu_model1) #392678.1
  AIC(qu_model1) #392630.4
  
  qu_model2 <- glm.nb(quote_count ~ CSA + year + month, data = raw.dataCLEAN)
  summary(qu_model2) 
  BIC(qu_model2) #391393.8
  AIC(qu_model2) #391241.1
  
  qu_model3 <- glm.nb(quote_count ~ CSA + year + month + daytime, data = raw.dataCLEAN) #this one
  summary(qu_model3) 
  BIC(qu_model3) #389380.8
  AIC(qu_model3) #389189.9
  
  qu_model_results <- stargazer(qu_model, qu_model1, qu_model2, qu_model3, omit = c("year2021", "daytimemorning", "daytimenight", "daytimemidday", "daytimeevening", "month12","month11","month10","month09","month08","month07","month06", "month05", "month04","month03","month02","month01"),covariate.labels=c( "Social BA context", "Political BA context","No social ot political BA context"), add.lines=list(c("Quote count 1", "No",""), c("Quote count 2", "Controls: Year", ""), c("Quote count 3", "Controls: Year, Month", ""), c("Quote count 4", "Controls: Year, Month, Daytime", "")), type = "text", out = "quote_count.comparison.txt")

  #############################################################
  #Appendix:E. Model comparison of reply
  re_model <- glm.nb(reply_count ~ CSA, data = raw.dataCLEAN) #this one
  summary(re_model) 
  BIC(re_model) #540851.1
  AIC(re_model) #540812.9
  
  re_model1 <- glm.nb(reply_count ~ CSA + year, data = raw.dataCLEAN)
  summary(re_model1) 
  BIC(re_model1) #539911.7
  AIC(re_model1) #539864
  
  re_model2 <- glm.nb(reply_count ~ CSA + year + month, data = raw.dataCLEAN)
  summary(re_model2) 
  BIC(re_model2) #539405.3
  AIC(re_model2) #539252.6
  
  re_model3 <- glm.nb(reply_count ~ CSA + year + month + daytime, data = raw.dataCLEAN)
  summary(re_model3) 
  BIC(re_model3) #538990.9
  AIC(re_model3) #538800
  
  re_model_results <- stargazer(re_model, re_model1, re_model2, re_model3, omit = c("year2021", "daytimemorning", "daytimenight", "daytimemidday", "daytimeevening", "month12","month11","month10","month09","month08","month07","month06", "month05", "month04","month03","month02","month01"),covariate.labels=c( "Social BA context", "Political BA context","No social ot political BA context"), add.lines=list(c("Reply count 1", "No",""), c("Reply count 2", "Controls: Year", ""), c("Reply count 3", "Controls: Year, Month", ""), c("Reply count 4", "Controls: Year, Month, Daytime", "")), type = "text", out = "reply_count.comparison.txt")
 
   #############################################################
  #Appendix:E. Model comparison of likes
  li_model <- glm.nb(like_count ~ CSA, data = raw.dataCLEAN)
  summary(li_model) 
  BIC(li_model) #979970.7
  AIC(li_model) #979932.5
  
  li_model1 <- glm.nb(like_count ~ CSA + year, data = raw.dataCLEAN) #this one
  summary(li_model1) 
  BIC(li_model1) #978276.8
  AIC(li_model1) #978229.1
  
  li_model2 <- glm.nb(like_count ~ CSA + year + month, data = raw.dataCLEAN)
  summary(li_model2) 
  BIC(li_model2) #975101.4
  AIC(li_model2) #974948.7
  
  li_model3 <- glm.nb(like_count ~ CSA + year + month + daytime, data = raw.dataCLEAN)
  summary(li_model3) 
  BIC(li_model3) #973622.8
  AIC(li_model3) #973432
  
  li_model_results <- stargazer(li_model, li_model1, li_model2, li_model3, omit = c("year2021", "daytimemorning", "daytimenight", "daytimemidday", "daytimeevening", "month12","month11","month10","month09","month08","month07","month06", "month05", "month04","month03","month02","month01"),covariate.labels=c( "Social BA context", "Political BA context","No social ot political BA context"), add.lines=list(c("Like count 1", "No",""), c("Like count 2", "Controls: Year", ""), c("Like count 3", "Controls: Year, Month", ""), c("Like count 4", "Controls: Year, Month, Daytime", "")), type = "text", out = "like_count.comparison.txt")
  
  #############################################################
  #Appendix:E. Model comparison of retweets
  rt_model <- glm.nb(retweet_count ~ CSA, data = raw.dataCLEAN)
  summary(rt_model) 
  BIC(rt_model) #861348.9
  AIC(rt_model) #861310.7
  
  rt_model1 <- glm.nb(retweet_count ~ CSA + year, data = raw.dataCLEAN) 
  summary(rt_model1) 
  BIC(rt_model1) #860284.3
  AIC(rt_model1) #860236.6
  
  rt_model2 <- glm.nb(retweet_count ~ CSA + year + month, data = raw.dataCLEAN)
  summary(rt_model2) 
  BIC(rt_model2) #851934.8
  AIC(rt_model2) #851782.2
  
  rt_model3 <- glm.nb(retweet_count ~ CSA + year + month + daytime, data = raw.dataCLEAN) #this one
  summary(rt_model3) 
  BIC(rt_model3) #850220.9
  AIC(rt_model3) #850030.1
  
  rt_model_results <- stargazer(rt_model, rt_model1, rt_model2, rt_model3, omit = c("year2021", "daytimemorning", "daytimenight", "daytimemidday", "daytimeevening", "month12","month11","month10","month09","month08","month07","month06", "month05", "month04","month03","month02","month01"),covariate.labels=c( "Social BA context", "Political BA context","No social ot political BA context"), add.lines=list(c("Retweet count 1", "No",""), c("Retweet count 2", "Controls: Year", ""), c("Retweet count 3", "Controls: Year, Month", ""), c("Retweet count 4", "Controls: Year, Month, Daytime", "")), type = "text", out = "retweet_count.comparison.txt")
  