# ============================================================
# Script 4: Sentiment Analysis
# Project: Women-Finance-Echo-Chambers-NLP
# Purpose: Score sentiment of posts and comments using
#          AFINN (positive/negative) and NRC (empowerment)
#          then compute Sentiment Gap per post
# Environment: Positron (R)
# ============================================================

library(tidyverse)
library(tidytext)
library(textdata)
library(syuzhet)

# ------------------------------------------------------------
# 1. LOAD CLASSIFIED DATA
# ------------------------------------------------------------

posts_classified    <- read_csv("posts_classified.csv")
comments_classified <- read_csv("comments_classified.csv")
posts_risk_index    <- read_csv("posts_risk_index.csv")

cat("Posts loaded:   ", nrow(posts_classified), "\n")
cat("Comments loaded:", nrow(comments_classified), "\n")

# ------------------------------------------------------------
# 2. LOAD SENTIMENT LEXICONS
# AFINN: words scored -5 (most negative) to +5 (most positive)
# NRC: words tagged with emotions including joy, trust, anticipation
# Note: first run will prompt download - type 1 to confirm
# ------------------------------------------------------------

afinn  <- get_sentiments("afinn")
nrc    <- get_sentiments("nrc")

cat("AFINN lexicon loaded:", nrow(afinn), "words\n")
cat("NRC lexicon loaded:  ", nrow(nrc), "words\n")

# ------------------------------------------------------------
# 3. TOKENIZE TEXT FOR SENTIMENT SCORING
# ------------------------------------------------------------

# Tokenize posts
post_tokens <- posts_classified |>
  select(post_id, full_text, risk_tier) |>
  unnest_tokens(word, full_text)

# Tokenize comments
comment_tokens <- comments_classified |>
  select(comment_id, post_id, body, risk_tier, comment_depth) |>
  unnest_tokens(word, body)

cat("\nPost tokens:   ", nrow(post_tokens), "\n")
cat("Comment tokens:", nrow(comment_tokens), "\n")

# ------------------------------------------------------------
# 4. AFINN SENTIMENT SCORING
# Score = sum of word values / number of scored words
# Normalised so longer texts don't dominate
# ------------------------------------------------------------

# Posts AFINN score
post_afinn <- post_tokens |>
  inner_join(afinn, by = "word") |>
  group_by(post_id, risk_tier) |>
  summarise(
    afinn_sum   = sum(value),
    afinn_words = n(),
    afinn_score = round(afinn_sum / afinn_words, 3),
    .groups = "drop"
  )

cat("\n=== POST AFINN SENTIMENT SUMMARY ===\n")
print(summary(post_afinn$afinn_score))
cat("Posts scored:", nrow(post_afinn), "of", nrow(posts_classified), "\n")

# Comments AFINN score
comment_afinn <- comment_tokens |>
  inner_join(afinn, by = "word") |>
  group_by(comment_id, post_id, risk_tier, comment_depth) |>
  summarise(
    afinn_sum   = sum(value),
    afinn_words = n(),
    afinn_score = round(afinn_sum / afinn_words, 3),
    .groups = "drop"
  )

cat("\n=== COMMENT AFINN SENTIMENT SUMMARY ===\n")
print(summary(comment_afinn$afinn_score))
cat("Comments scored:", nrow(comment_afinn), "of", nrow(comments_classified), "\n")

# ------------------------------------------------------------
# 5. NRC EMPOWERMENT SCORE
# Empowerment = joy + trust + anticipation emotions combined
# These are the "high-empowerment" markers from the RQ
# ------------------------------------------------------------

empowerment_emotions <- c("joy", "trust", "anticipation")

# Posts empowerment score
post_empowerment <- post_tokens |>
  inner_join(nrc, by = "word") |>
  filter(sentiment %in% empowerment_emotions) |>
  group_by(post_id) |>
  summarise(
    empowerment_score = n(),  # count of empowerment words
    .groups = "drop"
  )

# Comments empowerment score
comment_empowerment <- comment_tokens |>
  inner_join(nrc, by = "word") |>
  filter(sentiment %in% empowerment_emotions) |>
  group_by(comment_id, post_id) |>
  summarise(
    empowerment_score = n(),
    .groups = "drop"
  )

cat("\n=== POST EMPOWERMENT SCORE SUMMARY ===\n")
print(summary(post_empowerment$empowerment_score))

cat("\n=== COMMENT EMPOWERMENT SCORE SUMMARY ===\n")
print(summary(comment_empowerment$empowerment_score))

# ------------------------------------------------------------
# 6. AGGREGATE COMMENT SENTIMENT TO POST LEVEL
# For each post: average comment sentiment and empowerment
# ------------------------------------------------------------

comment_sentiment_by_post <- comment_afinn |>
  group_by(post_id) |>
  summarise(
    avg_comment_afinn     = round(mean(afinn_score), 3),
    median_comment_afinn  = round(median(afinn_score), 3),
    sd_comment_afinn      = round(sd(afinn_score), 3),
    n_scored_comments     = n(),
    .groups = "drop"
  )

comment_empowerment_by_post <- comment_empowerment |>
  group_by(post_id) |>
  summarise(
    avg_comment_empowerment = round(mean(empowerment_score), 3),
    .groups = "drop"
  )

# ------------------------------------------------------------
# 7. COMPUTE SENTIMENT GAP
# Sentiment Gap = avg comment AFINN score - post AFINN score
# Positive gap = community more positive than original poster
# Negative gap = community more negative than original poster
# ------------------------------------------------------------

sentiment_master <- posts_risk_index |>
  left_join(post_afinn |> select(post_id, post_afinn_score = afinn_score),
            by = "post_id") |>
  left_join(post_empowerment,          by = "post_id") |>
  left_join(comment_sentiment_by_post, by = "post_id") |>
  left_join(comment_empowerment_by_post, by = "post_id") |>
  mutate(
    sentiment_gap = round(avg_comment_afinn - post_afinn_score, 3)
  )

cat("\n=== SENTIMENT GAP SUMMARY ===\n")
print(summary(sentiment_master$sentiment_gap))

cat("\nPosts with largest positive Sentiment Gap (community more positive):\n")
sentiment_master |>
  filter(!is.na(sentiment_gap)) |>
  arrange(desc(sentiment_gap)) |>
  select(title, risk_tier, post_afinn_score, avg_comment_afinn,
         sentiment_gap, risk_index) |>
  head(8) |>
  print()

cat("\nPosts with largest negative Sentiment Gap (community more negative):\n")
sentiment_master |>
  filter(!is.na(sentiment_gap)) |>
  arrange(sentiment_gap) |>
  select(title, risk_tier, post_afinn_score, avg_comment_afinn,
         sentiment_gap, risk_index) |>
  head(8) |>
  print()

# ------------------------------------------------------------
# 8. KEY FINDING: Empowerment vs Risk Index correlation
# This directly tests the research question
# ------------------------------------------------------------

cat("\n=== CORRELATION: Empowerment Score vs Risk Index ===\n")
cor_test <- cor.test(
  sentiment_master$empowerment_score,
  sentiment_master$risk_index,
  use    = "complete.obs",
  method = "spearman"
)
print(cor_test)

cat("\n=== CORRELATION: Sentiment Gap vs Risk Index ===\n")
cor_test2 <- cor.test(
  sentiment_master$sentiment_gap,
  sentiment_master$risk_index,
  use    = "complete.obs",
  method = "spearman"
)
print(cor_test2)

# ------------------------------------------------------------
# 9. SAVE OUTPUTS
# ------------------------------------------------------------

write_csv(sentiment_master,   "sentiment_master.csv")
write_csv(post_afinn,         "post_afinn_scores.csv")
write_csv(comment_afinn,      "comment_afinn_scores.csv")

cat("\nSentiment analysis complete. Files saved.\n")
