# ============================================================
# Script 2: Text Preprocessing
# Project: Women-Finance-Echo-Chambers-NLP
# Purpose: Tokenization, stopword removal, and frequency analysis
# Environment: Positron (R)
# ============================================================

library(tidyverse)
library(tidytext)

# ------------------------------------------------------------
# 1. LOAD CLEANED DATA
# ------------------------------------------------------------

posts_clean    <- read_csv("posts_clean.csv")
comments_clean <- read_csv("comments_clean.csv")

cat("Posts loaded:   ", nrow(posts_clean), "rows\n")
cat("Comments loaded:", nrow(comments_clean), "rows\n")

# ------------------------------------------------------------
# 2. TOKENIZATION
# Breaks text into individual words, converts to lowercase,
# and strips punctuation automatically via unnest_tokens()
# ------------------------------------------------------------

post_tokens <- posts_clean |>
  unnest_tokens(word, full_text)

comment_tokens <- comments_clean |>
  unnest_tokens(word, body_clean)

cat("\nPost tokens:   ", nrow(post_tokens), "\n")
cat("Comment tokens:", nrow(comment_tokens), "\n")

# ------------------------------------------------------------
# 3. STOPWORD REMOVAL
# Removes common function words (e.g. "the", "is", "and")
# that carry no analytical signal for sentiment or risk analysis
# ------------------------------------------------------------

data(stop_words)

post_tokens_filtered <- post_tokens |>
  anti_join(stop_words, by = "word")

comment_tokens_filtered <- comment_tokens |>
  anti_join(stop_words, by = "word")

# ------------------------------------------------------------
# 4. CUSTOM NOISE REMOVAL
# Removes pure numeric tokens and Reddit-specific noise
# (e.g. usernames, markdown artifacts, standalone symbols)
# ------------------------------------------------------------

clean_tokens <- function(df) {
  df |>
    filter(
      !str_detect(word, "^[0-9]+$"),          # pure numbers
      !str_detect(word, "^https?"),            # URLs
      !str_detect(word, "^r/|^u/"),            # Reddit handles
      !str_detect(word, "^[^a-z]+$"),          # non-alphabetic tokens
      str_length(word) > 1                     # single-character tokens
    )
}

post_tokens_final    <- clean_tokens(post_tokens_filtered)
comment_tokens_final <- clean_tokens(comment_tokens_filtered)

cat("\nPost tokens after cleaning:   ", nrow(post_tokens_final), "\n")
cat("Comment tokens after cleaning:", nrow(comment_tokens_final), "\n")

# ------------------------------------------------------------
# 5. FREQUENCY ANALYSIS
# Top words confirm the corpus is fit for purpose
# ------------------------------------------------------------

cat("\n=== TOP 15 WORDS IN POSTS ===\n")
print(post_tokens_final |> count(word, sort = TRUE) |> head(15))

cat("\n=== TOP 15 WORDS IN COMMENTS ===\n")
print(comment_tokens_final |> count(word, sort = TRUE) |> head(15))

# ------------------------------------------------------------
# 6. RISK TERM FREQUENCY CHECK
# Validates that risk-relevant vocabulary is present in corpus
# before building the Risk Dictionary in Script 3
# ------------------------------------------------------------

risk_terms <- c(
  # high risk
  "crypto", "leverage", "mlm", "options", "debt", "hustle", "moon",
  # medium risk
  "invest", "pension", "stocks", "etf", "portfolio", "property",
  # low risk
  "savings", "budget", "emergency", "insurance"
)

cat("\n=== RISK TERM FREQUENCY (COMMENTS) ===\n")
print(
  comment_tokens_final |>
    filter(word %in% risk_terms) |>
    count(word, sort = TRUE)
)

cat("\n=== RISK TERM FREQUENCY (POSTS) ===\n")
print(
  post_tokens_final |>
    filter(word %in% risk_terms) |>
    count(word, sort = TRUE)
)

# ------------------------------------------------------------
# 7. SAVE TOKENIZED DATA
# ------------------------------------------------------------

write_csv(post_tokens_final,    "post_tokens.csv")
write_csv(comment_tokens_final, "comment_tokens.csv")

cat("\nPreprocessing complete. Tokenized files saved.\n")

