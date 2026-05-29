# ============================================================
# Script 3: Risk Dictionary & Classification
# Project: Women-Finance-Echo-Chambers-NLP
# Purpose: Classify posts into Low / Medium / High risk tiers
#          using regex patterns grounded in the actual corpus
# Environment: Positron (R)
# ============================================================

library(tidyverse)

# ------------------------------------------------------------
# 1. LOAD CLEANED DATA
# ------------------------------------------------------------

posts_clean    <- read_csv("r_wealthforwomen_posts.csv")
comments_clean <- read_csv("r_wealthforwomen_comments.csv")

cat("Posts loaded:   ", nrow(posts_clean), "\n")
cat("Comments loaded:", nrow(comments_clean), "\n")

# ------------------------------------------------------------
# 2. DEFINE RISK DICTIONARY
# Three tiers based on actual corpus language observed in data
# ------------------------------------------------------------

# HIGH RISK: speculative, irreversible, or predatory financial behaviour
# Grounded in corpus terms: MLMs, whole life insurance, gold handover,
# crypto, leverage, loans/EMIs framed as traps

high_risk_patterns <- paste(
  "crypto|cryptocurrency|bitcoin|ethereum|altcoin",
  "leverage|leveraged|margin trading|options|futures|derivatives",
  "mlm|multi.level|pyramid|scheme|network marketing",
  "whole life insurance|life insurance pitch",
  "get rich|passive income guaranteed|financial freedom fast",
  "gold jewelry.*hand over|hand over.*gold|salary.*in.?laws",
  "loan trap|emi trap|debt trap|predatory",
  "hustl|side hustle.*quick|moon|to the moon",
  "high.yield.*guaranteed|guaranteed return",
  sep = "|"
)

# MEDIUM RISK: active investment decisions with market exposure
# Grounded in corpus: index funds, stocks, retirement savings,
# property, pension, portfolio decisions

medium_risk_patterns <- paste(
  "index fund|etf|mutual fund|stock|equities|shares",
  "invest|investing|investment|portfolio",
  "pension|retirement|401k|ira|sipp|roth",
  "property|real estate|buy.to.let|rental income",
  "dividend|compound interest|capital gain",
  "high.yield savings|hysa",
  "negotiate.*salary|salary negotiation",
  "student loan|refinanc",
  sep = "|"
)

# LOW RISK: foundational financial habits and safety behaviours
# Grounded in corpus: budgeting, emergency funds, savings automation,
# disposable income tracking, protection planning

low_risk_patterns <- paste(
  "budget|budgeting|zero.based budget",
  "emergency fund|rainy day fund",
  "automat.*savings|savings.*automat|automat.*paycheck",
  "disposable income|needs vs wants|needs versus wants",
  "high.yield savings account(?!.*guaranteed)",
  "insurance(?!.*pitch|.*mlm|.*whole life)",
  "prenup|prenuptial|financial protection|protection plan",
  "mortgage.*paid off|pay off.*mortgage|no.*debt",
  "audit.*money|full audit|money audit",
  "save|saving|saver",
  sep = "|"
)

# ------------------------------------------------------------
# 3. CLASSIFICATION FUNCTION
# Returns highest matching risk tier for a text string
# Priority: HIGH > MEDIUM > LOW > Unclassified
# ------------------------------------------------------------

classify_risk <- function(text) {
  text <- tolower(text)
  case_when(
    str_detect(text, high_risk_patterns)   ~ "High",
    str_detect(text, medium_risk_patterns) ~ "Medium",
    str_detect(text, low_risk_patterns)    ~ "Low",
    TRUE                                   ~ "Unclassified"
  )
}

# ------------------------------------------------------------
# 4. APPLY TO POSTS
# ------------------------------------------------------------

posts_classified <- posts_clean |>
  mutate(
    risk_tier = classify_risk(full_text),
    # Also flag which specific pattern triggered classification
    high_flag   = str_detect(tolower(full_text), high_risk_patterns),
    medium_flag = str_detect(tolower(full_text), medium_risk_patterns),
    low_flag    = str_detect(tolower(full_text), low_risk_patterns)
  )

cat("\n=== POST RISK TIER DISTRIBUTION ===\n")
print(table(posts_classified$risk_tier))

cat("\n=== RISK TIER BY FLAIR ===\n")
print(table(posts_classified$flair, posts_classified$risk_tier))

# ------------------------------------------------------------
# 5. APPLY TO COMMENTS
# ------------------------------------------------------------

comments_classified <- comments_clean |>
  mutate(
    risk_tier   = classify_risk(body),
    high_flag   = str_detect(tolower(body), high_risk_patterns),
    medium_flag = str_detect(tolower(body), medium_risk_patterns),
    low_flag    = str_detect(tolower(body), low_risk_patterns)
  )

cat("\n=== COMMENT RISK TIER DISTRIBUTION ===\n")
print(table(comments_classified$risk_tier))

cat("\n=== COMMENT DEPTH x RISK TIER ===\n")
print(table(comments_classified$comment_depth, comments_classified$risk_tier))

# ------------------------------------------------------------
# 6. SAMPLE HIGH RISK TEXT (manual validation)
# Check that classifications look sensible before proceeding
# ------------------------------------------------------------

cat("\n=== SAMPLE HIGH RISK POSTS ===\n")
posts_classified |>
  filter(risk_tier == "High") |>
  select(post_id, title, risk_tier) |>
  head(10) |>
  print()

cat("\n=== SAMPLE HIGH RISK COMMENTS ===\n")
comments_classified |>
  filter(risk_tier == "High") |>
  select(comment_id, body, risk_tier) |>
  mutate(body = str_trunc(body, 120)) |>
  head(10) |>
  print()

# ------------------------------------------------------------
# 7. COMPUTE RISK INDEX PER POST
# Aggregate comment risk scores to post level
# Risk Index = proportion of comments classified as High risk
# ------------------------------------------------------------

comment_risk_summary <- comments_classified |>
  group_by(post_id) |>
  summarise(
    total_comments     = n(),
    high_risk_comments = sum(risk_tier == "High"),
    med_risk_comments  = sum(risk_tier == "Medium"),
    low_risk_comments  = sum(risk_tier == "Low"),
    risk_index         = round(high_risk_comments / total_comments, 3),
    .groups = "drop"
  )

# Join back to posts
posts_with_risk_index <- posts_classified |>
  left_join(comment_risk_summary, by = "post_id")

cat("\n=== RISK INDEX SUMMARY (per post) ===\n")
print(summary(posts_with_risk_index$risk_index))

cat("\nPosts with highest Risk Index:\n")
posts_with_risk_index |>
  filter(!is.na(risk_index)) |>
  arrange(desc(risk_index)) |>
  select(title, risk_tier, risk_index, total_comments) |>
  head(10) |>
  print()

# ------------------------------------------------------------
# 8. SAVE OUTPUTS
# ------------------------------------------------------------

write_csv(posts_classified,       "posts_classified.csv")
write_csv(comments_classified,    "comments_classified.csv")
write_csv(posts_with_risk_index,  "posts_risk_index.csv")

cat("\nRisk classification complete. Files saved.\n")
