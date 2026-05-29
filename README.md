# Echoes of Risk — Women, Finance & Echo Chambers

> **Module:** Text Analysis and Natural Language Processing (Spring 2026)
> **Student:** Shaleen Debeila
> **Data Scope:** December 2025 – March 2026
> **Status:** Analysis Complete

---

## Research Question

How does the sentiment of community responses (the "Echo") in female-centric financial forums correlate with the risk level of the investment advice being discussed (the "Trigger")?

Specifically: **does high-empowerment sentiment serve as a linguistic validator for high-risk financial decision-making?**

---

## Key Findings

| Finding | Result |
|---|---|
| Empowerment vs Risk Index (Spearman rho) | 0.072 (p = 0.568, not significant) |
| Sentiment Gap vs Risk Index (Spearman rho) | −0.031 (p = 0.807, not significant) |
| Mean Sentiment Gap | +0.26 (community more positive than posters) |
| Controversiality rate | 0.6% across all 3,725 comments |
| Dominant risk tier | Medium (45.2% of posts) |

**The null correlation is itself the finding.** r/wealthforwomen functions as an *affective* echo chamber — positivity is amplified broadly across all risk tiers rather than being selectively directed at high-risk content. The near-zero controversiality rate indicates virtually no content is challenged regardless of financial risk level.

---

## Data

**Source:** r/wealthforwomen — a Reddit community focused on how women earn, manage, protect, and control money.

| | Count |
|---|---|
| Posts (raw) | 96 |
| Posts (after cleaning) | 84 |
| Comments (raw) | 3,762 |
| Comments (after cleaning) | 3,725 |
| Unique commenters | 1,940 |
| Date range | December 2025 – March 2026 |
| Avg post score | 72.0 (upvote ratio: 0.88) |

---

## Risk Tier Distribution

| Risk Tier | Posts | Comments |
|---|---|---|
| High | 9 (10.7%) | 69 (1.9%) |
| Medium | 38 (45.2%) | 750 (20.1%) |
| Low | 7 (8.3%) | 369 (9.9%) |
| Unclassified | 30 (35.7%) | 2,537 (68.1%) |

---

## Methodology

A hybrid NLP pipeline implemented in **Positron (R 4.5.1)**:

| Step | Script | Purpose |
|---|---|---|
| Data Cleaning | `clean_wealthforwomen.R` | Column selection, deduplication, timestamp parsing |
| Text Preprocessing | `preprocess_text.R` | Tokenisation, stopword removal, noise filtering |
| Risk Classification | `risk_dictionary.R` | Custom regex Risk Dictionary — Low / Medium / High tiers |
| Sentiment Analysis | `sentiment_analysis.R` | AFINN scoring, NRC empowerment, Sentiment Gap, correlation |
| Visualisations | `visualisations.R` | 6 ggplot2 figures for the final report |

**Sentiment Gap:** The divergence between original poster tone and community response sentiment — the core metric for testing whether empowerment amplifies risk perception.

**Risk Index:** Per-post proportion of comments classified as High-risk — used as the dependent variable in correlation analysis.

---

## Repository Structure

```
├── data/
│   ├── r_wealthforwomen_posts.csv          # cleaned posts
│   ├── r_wealthforwomen_posts_raw.csv      # raw posts
│   ├── r_wealthforwomen_comments.csv       # cleaned comments
│   ├── r_wealthforwomen_comments_raw.csv   # raw comments
│   ├── posts_classified.csv               # risk tier classification
│   ├── comments_classified.csv            # risk tier classification
│   ├── posts_risk_index.csv               # per-post risk index
│   └── sentiment_master.csv               # full sentiment + risk analysis
├── scripts/
│   ├── clean_wealthforwomen.R
│   ├── preprocess_text.R
│   ├── risk_dictionary.R
│   ├── sentiment_analysis.R
│   └── visualisations.R
├── outputs/
│   └── figures/                            # 6 ggplot2 figures
└── README.md
```

---

## Environment

| Tool | Version |
|---|---|
| R | 4.5.1 |
| Positron | latest |
| tidyverse | 2.0.0 |
| tidytext | 0.4.5 |
| textdata | 0.4.5 |
| syuzhet | 1.0.7 |

---

## References

1. Cookson, J. A., Engelberg, J. E., & Mullins, W. (2023). Echo chambers. *The Review of Financial Studies, 36*(2), 450–500. https://doi.org/10.1093/rfs/hhac058

2. Ben-Shmuel, A. T., Hayes, A., & Drach, V. (2024). The gendered language of financial advice: Finfluencers, framing, and subconscious preferences. *Socius, 10*. https://doi.org/10.1177/23780231241267131

3. Christopher, A. R., & Nithya, A. R. (2025). Leveraging artificial intelligence to explore gendered patterns in financial literacy among teachers in academia. *Frontiers in Artificial Intelligence, 8*. https://doi.org/10.3389/frai.2025.1634640

4. Zhai, C., & Massung, S. (2016). *Text data management and analysis: A practical introduction to information retrieval and text mining*. ACM Books. https://doi.org/10.1145/2915031

---

*Data collected from a public Reddit community for academic research purposes. Spring 2026.*
