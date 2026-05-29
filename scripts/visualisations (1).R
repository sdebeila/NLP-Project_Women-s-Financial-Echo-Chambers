# ============================================================
# Script 5: Visualisations
# Project: Women-Finance-Echo-Chambers-NLP
# Purpose: Generate ggplot2 figures for the final report
# Environment: Positron (R)
# ============================================================

library(tidyverse)

# ------------------------------------------------------------
# 1. LOAD DATA
# ------------------------------------------------------------

sentiment_master     <- read_csv("sentiment_master.csv")
posts_classified     <- read_csv("posts_classified.csv")
comments_classified  <- read_csv("comments_classified.csv")
post_afinn           <- read_csv("post_afinn_scores.csv")
comment_afinn        <- read_csv("comment_afinn_scores.csv")

# Create output folder for figures
dir.create("figures", showWarnings = FALSE)

# Shared theme for all plots
theme_nlp <- theme_minimal(base_size = 13) +
  theme(
    plot.title    = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(color = "grey40", size = 11),
    plot.caption  = element_text(color = "grey50", size = 9),
    axis.title    = element_text(size = 11),
    legend.position = "bottom"
  )

# Colour palette
risk_colours <- c(
  "High"         = "#D62728",
  "Medium"       = "#FF7F0E",
  "Low"          = "#2CA02C",
  "Unclassified" = "#AEC7E8"
)

# ------------------------------------------------------------
# FIGURE 1: Risk Tier Distribution — Posts vs Comments
# ------------------------------------------------------------

post_dist <- posts_classified |>
  count(risk_tier) |>
  mutate(source = "Posts")

comment_dist <- comments_classified |>
  count(risk_tier) |>
  mutate(source = "Comments")

risk_dist <- bind_rows(post_dist, comment_dist) |>
  mutate(risk_tier = factor(risk_tier,
         levels = c("High", "Medium", "Low", "Unclassified")))

fig1 <- ggplot(risk_dist, aes(x = risk_tier, y = n, fill = risk_tier)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~source, scales = "free_y") +
  scale_fill_manual(values = risk_colours) +
  labs(
    title    = "Figure 1: Risk Tier Distribution",
    subtitle = "Posts (n=84) and Comments (n=3,725) from r/wealthforwomen",
    x        = "Risk Tier",
    y        = "Count",
    caption  = "Data: r/wealthforwomen, Dec 2025 – Mar 2026"
  ) +
  theme_nlp

ggsave("figures/fig1_risk_distribution.png", fig1,
       width = 8, height = 5, dpi = 300)
cat("Figure 1 saved\n")

# ------------------------------------------------------------
# FIGURE 2: Post AFINN Sentiment Score by Risk Tier
# ------------------------------------------------------------

fig2 <- post_afinn |>
  mutate(risk_tier = factor(risk_tier,
         levels = c("High", "Medium", "Low", "Unclassified"))) |>
  ggplot(aes(x = risk_tier, y = afinn_score, fill = risk_tier)) +
  geom_boxplot(alpha = 0.7, outlier.shape = 21) +
  geom_jitter(width = 0.15, alpha = 0.4, size = 1.5) +
  scale_fill_manual(values = risk_colours) +
  labs(
    title    = "Figure 2: Post Sentiment Score by Risk Tier",
    subtitle = "AFINN sentiment score (normalised) per post",
    x        = "Risk Tier",
    y        = "AFINN Score (negative = negative sentiment)",
    caption  = "Higher scores indicate more positive language",
    fill     = "Risk Tier"
  ) +
  theme_nlp

ggsave("figures/fig2_post_sentiment_by_risk.png", fig2,
       width = 8, height = 5, dpi = 300)
cat("Figure 2 saved\n")

# ------------------------------------------------------------
# FIGURE 3: Sentiment Gap Distribution
# Positive = community more positive than post author
# ------------------------------------------------------------

fig3 <- sentiment_master |>
  filter(!is.na(sentiment_gap)) |>
  mutate(risk_tier = factor(risk_tier,
         levels = c("High", "Medium", "Low", "Unclassified"))) |>
  ggplot(aes(x = sentiment_gap, fill = risk_tier)) +
  geom_histogram(bins = 20, alpha = 0.8, color = "white") +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey30") +
  scale_fill_manual(values = risk_colours) +
  labs(
    title    = "Figure 3: Sentiment Gap Distribution",
    subtitle = "Positive gap = community more positive than original poster (the Echo)",
    x        = "Sentiment Gap (Comment AFINN − Post AFINN)",
    y        = "Number of Posts",
    caption  = "Dashed line = zero gap",
    fill     = "Post Risk Tier"
  ) +
  theme_nlp

ggsave("figures/fig3_sentiment_gap_distribution.png", fig3,
       width = 8, height = 5, dpi = 300)
cat("Figure 3 saved\n")

# ------------------------------------------------------------
# FIGURE 4: Empowerment Score vs Risk Index (scatter)
# The core visual for the research question
# ------------------------------------------------------------

fig4 <- sentiment_master |>
  filter(!is.na(empowerment_score), !is.na(risk_index)) |>
  mutate(risk_tier = factor(risk_tier,
         levels = c("High", "Medium", "Low", "Unclassified"))) |>
  ggplot(aes(x = empowerment_score, y = risk_index,
             color = risk_tier, size = total_comments)) +
  geom_point(alpha = 0.7) +
  geom_smooth(method = "lm", se = TRUE, color = "grey30",
              linetype = "dashed", linewidth = 0.8) +
  scale_color_manual(values = risk_colours) +
  labs(
    title    = "Figure 4: Empowerment Score vs Risk Index",
    subtitle = "Spearman rho = 0.072, p = 0.568 (not significant)",
    x        = "Post Empowerment Score (NRC joy + trust + anticipation)",
    y        = "Risk Index (proportion of high-risk comments)",
    color    = "Post Risk Tier",
    size     = "Total Comments",
    caption  = "Each point = one post. Size = number of comments received."
  ) +
  theme_nlp

ggsave("figures/fig4_empowerment_vs_risk_index.png", fig4,
       width = 9, height = 6, dpi = 300)
cat("Figure 4 saved\n")

# ------------------------------------------------------------
# FIGURE 5: Controversiality Rate by Risk Tier
# Echo chamber signal — low controversy = reinforcement
# ------------------------------------------------------------

controversiality_summary <- comments_classified |>
  group_by(risk_tier) |>
  summarise(
    total       = n(),
    controversial = sum(controversiality == 1, na.rm = TRUE),
    rate        = round(controversial / total * 100, 2),
    .groups     = "drop"
  ) |>
  mutate(risk_tier = factor(risk_tier,
         levels = c("High", "Medium", "Low", "Unclassified")))

fig5 <- ggplot(controversiality_summary,
               aes(x = risk_tier, y = rate, fill = risk_tier)) +
  geom_col(show.legend = FALSE) +
  geom_text(aes(label = paste0(rate, "%")),
            vjust = -0.5, size = 4, fontface = "bold") +
  scale_fill_manual(values = risk_colours) +
  labs(
    title    = "Figure 5: Controversiality Rate by Risk Tier",
    subtitle = "Echo chamber signal: near-zero controversy across all tiers",
    x        = "Risk Tier",
    y        = "Controversiality Rate (%)",
    caption  = "Reddit controversiality flag: comments with near-equal up/downvotes"
  ) +
  theme_nlp

ggsave("figures/fig5_controversiality_by_risk.png", fig5,
       width = 8, height = 5, dpi = 300)
cat("Figure 5 saved\n")

# ------------------------------------------------------------
# FIGURE 6: Comment Depth x Sentiment
# Do top-level vs reply comments differ in sentiment?
# ------------------------------------------------------------

fig6 <- comment_afinn |>
  left_join(comments_classified |>
              select(comment_id, comment_depth), by = "comment_id",
            suffix = c("", ".y")) |>
  mutate(comment_depth = coalesce(comment_depth, comment_depth.y)) |>
  select(-any_of("comment_depth.y")) |>
  filter(!is.na(comment_depth)) |>
  mutate(risk_tier = factor(risk_tier,
         levels = c("High", "Medium", "Low", "Unclassified"))) |>
  ggplot(aes(x = comment_depth, y = afinn_score, fill = comment_depth)) +
  geom_boxplot(alpha = 0.7) +
  facet_wrap(~risk_tier) +
  scale_fill_manual(values = c("top_level" = "#4C72B0", "reply" = "#DD8452")) +
  labs(
    title    = "Figure 6: Comment Sentiment by Depth and Risk Tier",
    subtitle = "Do replies amplify or moderate sentiment compared to top-level comments?",
    x        = "Comment Depth",
    y        = "AFINN Sentiment Score",
    fill     = "Comment Depth",
    caption  = "Faceted by post risk tier"
  ) +
  theme_nlp

ggsave("figures/fig6_sentiment_by_depth_and_risk.png", fig6,
       width = 10, height = 6, dpi = 300)
cat("Figure 6 saved\n")

# ------------------------------------------------------------
# PRINT SUMMARY
# ------------------------------------------------------------

cat("\n=== ALL FIGURES SAVED TO figures/ FOLDER ===\n")
cat("fig1_risk_distribution.png\n")
cat("fig2_post_sentiment_by_risk.png\n")
cat("fig3_sentiment_gap_distribution.png\n")
cat("fig4_empowerment_vs_risk_index.png\n")
cat("fig5_controversiality_by_risk.png\n")
cat("fig6_sentiment_by_depth_and_risk.png\n")
cat("\nVisualisations complete.\n")
