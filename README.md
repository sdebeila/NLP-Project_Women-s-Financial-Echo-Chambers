# Echoes of Risk — Women, Finance & Echo Chambers

> **Module:** Text Analysis and Natural Language Processing (Spring 2026)
> **Student:** Shaleen Debeila
> **Data Scope:** December 2025 – March 2026

---

## 1. Research Question

How does the sentiment of community responses (the "Echo") in female-centric financial forums correlate with the risk level of the investment advice being discussed (the "Trigger")? Specifically, does a high degree of "empowerment" sentiment serve as a linguistic validator for high-risk financial decision-making?

---

## 2. Importance

While digital "safe spaces" provide essential social capital for women, they can also function as echo chambers where emotional support inadvertently bypasses rational financial due diligence. This is evidenced directly in the dataset: only 24 of 3,725 comments (0.6%) are flagged as controversial, suggesting a community that reinforces rather than challenges financial claims. Identifying these dynamics is critical for improving financial literacy and protecting users from predatory schemes — such as MLMs — that thrive on community validation rather than technical merit.

---

## 3. Deficiencies in Previous Work

Current NLP research in finance heavily prioritises broad market sentiment (Bloomberg, Reuters) or gender-neutral platforms such as r/wallstreetbets and r/investing. There is a significant gap in understanding gendered digital discourse. Previous work fails to account for how "supportive" or "empowering" linguistic markers — unique to these communities — impact the perception of financial risk, leading to information siloing in specialised forums (Cookson et al., 2023). The community studied here (r/wealthforwomen) was founded in late 2025 and has no prior academic treatment, making this dataset a genuinely novel contribution.

---

## 4. Value Added

### Dataset

| | |
|---|---|
| Posts (Triggers) | 84 original threads |
| Comments (Echoes) | 3,725 community responses |
| Unique authors | 1,935 participants |
| Posts with engagement | 73 of 84 threads received comments |
| Avg post score | 72.0 (upvote ratio: 0.88) |
| Echo chamber signal | 0.6% controversiality rate across all comments |

### NLP Pipeline

| Step | Tool | Purpose |
|---|---|---|
| Lexical analysis | Regex (R) | Custom Risk Dictionary — low / medium / high risk tiers |
| Sentiment mining | BERTweet (Python) | Conversational social media syntax |
| Financial classification | FinBERT (Python) | Financial topic tone |
| Correlation | R (`ggplot2`) | Sentiment Gap × Risk Index |

**Sentiment Gap:** The divergence between original poster tone and community response sentiment — the core metric for testing whether empowerment amplifies risk perception.

### Repository Structure
```
├── data/
│   ├── r_wealthforwomen_posts_raw.csv         # raw posts
│   ├── r_wealthforwomen_comments_raw.csv      # raw comments
│   ├── r_wealthforwomen_posts.csv          # cleaned & preprocessed
│   └── r_wealthforwomen_comments.csv       # cleaned & preprocessed
├── scripts/
│   ├── clean_wealthforwomen.R
│   ├── preprocess_text.R
│   ├── risk_dictionary.R
│   ├── sentiment_analysis.py
│   └── analysis.R
├── outputs/
│   └── figures/
└── README.md
```

---

## 5. The Takeaway

This project tests whether community sentiment functions as a leading indicator of risk adoption in female-centric financial echo chambers. The near-zero controversiality rate (0.6%) combined with high community engagement across diverse risk topics provides a strong empirical basis for examining whether linguistic empowerment patterns precede or accompany high-risk financial discourse. The findings aim to offer academic and regulatory communities a new lens for assessing the influence of digital peer groups on financial stability.

---

## References

1. Cookson, J. A., Engelberg, J. E., & Mullins, W. (2023). Echo chambers. *The Review of Financial Studies, 36*(2), 450–500. https://doi.org/10.1093/rfs/hhac058
2. Ben-Shmuel, A. T., Hayes, A., & Drach, V. (2024). The gendered language of financial advice: Finfluencers, framing, and subconscious preferences. *Socius, 10*. https://doi.org/10.1177/23780231241267131
3. Christopher, A. R., & Nithya, A. R. (2025). Leveraging artificial intelligence to explore gendered patterns in financial literacy among teachers in academia. *Frontiers in Artificial Intelligence, 8*. https://doi.org/10.3389/frai.2025.1634640
4. Zhai, C., & Massung, S. (2016). *Text data management and analysis: A practical introduction to information retrieval and text mining*. ACM Books. https://doi.org/10.1145/2915031

---

*Data collected from a public Reddit community for academic research purposes.*
