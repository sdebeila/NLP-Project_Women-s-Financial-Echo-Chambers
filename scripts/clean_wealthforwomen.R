# ============================================================
# Data Cleaning Script: r/wealthforwomen
# Project: Women-Finance-Echo-Chambers-NLP
# Environment: Positron (R)
# ============================================================

library(tidyverse)
library(lubridate)

# ------------------------------------------------------------
# 1. LOAD RAW DATA
# ------------------------------------------------------------

posts_raw    <- read_csv("r_wealthforwomen_posts.csv")
comments_raw <- read_csv("r_wealthforwomen_comments.csv")

# ------------------------------------------------------------
# 2. SELECT RELEVANT COLUMNS
# ------------------------------------------------------------

posts <- posts_raw |>
  select(
    post_id        = id,
    author,
    title,
    selftext,
    score,
    upvote_ratio,
    num_comments,
    created_utc,
    flair          = link_flair_text,
    permalink
  )

comments <- comments_raw |>
  select(
    comment_id     = id,
    post_id        = link_id,       # e.g. "t3_abc123"
    parent_id,                      # used to detect reply depth
    author,
    body,
    score,
    controversiality,
    created_utc,
    is_submitter,
    permalink
  )

# ------------------------------------------------------------
# 3. CLEAN POSTS
# ------------------------------------------------------------

posts_clean <- posts |>

  # 3a. Remove duplicate posts (same title posted twice)
  distinct(title, author, .keep_all = TRUE) |>

  # 3b. Convert Unix timestamp to datetime
  mutate(created_at = as_datetime(created_utc)) |>

  # 3c. Combine title + body into a single text field for NLP
  mutate(
    selftext   = replace_na(selftext, ""),
    full_text  = str_squish(paste(title, selftext, sep = " "))
  ) |>

  # 3d. Normalise flair (replace NA with "Unflaired")
  mutate(flair = replace_na(flair, "Unflaired")) |>

  # 3e. Drop raw timestamp (keep parsed version)
  select(-created_utc)

# ------------------------------------------------------------
# 4. CLEAN COMMENTS
# ------------------------------------------------------------

comments_clean <- comments |>

  # 4a. Remove deleted / removed content
  filter(!body %in% c("[deleted]", "[removed]")) |>

  # 4b. Remove blank / whitespace-only bodies
  filter(str_squish(body) != "") |>

  # 4c. Strip "t3_" prefix from post_id to match posts$post_id
  mutate(post_id = str_remove(post_id, "^t3_")) |>

  # 4d. Derive comment depth:
  #     parent starts with "t3_" → top-level; "t1_" → reply
  mutate(
    comment_depth = if_else(str_starts(parent_id, "t3_"), "top_level", "reply")
  ) |>

  # 4e. Convert Unix timestamp to datetime
  mutate(created_at = as_datetime(created_utc)) |>

  # 4f. Clean body text: squish whitespace, keep structure intact
  mutate(body_clean = str_squish(body)) |>

  # 4g. Drop raw timestamp
  select(-created_utc)

# ------------------------------------------------------------
# 5. QUALITY CHECKS
# ------------------------------------------------------------

cat("=== POSTS ===\n")
cat("Rows after cleaning:", nrow(posts_clean), "\n")
cat("Missing full_text:  ", sum(posts_clean$full_text == ""), "\n")
cat("Flair distribution:\n")
print(table(posts_clean$flair))

cat("\n=== COMMENTS ===\n")
cat("Rows after cleaning:    ", nrow(comments_clean), "\n")
cat("Top-level vs replies:\n")
print(table(comments_clean$comment_depth))
cat("Controversiality distribution:\n")
print(table(comments_clean$controversiality))

# ------------------------------------------------------------
# 6. SAVE CLEANED DATA
# ------------------------------------------------------------

write_csv(posts_clean,    "posts_clean.csv")
write_csv(comments_clean, "comments_clean.csv")

cat("\nDone. Cleaned files saved.\n")
