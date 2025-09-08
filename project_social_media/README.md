# 🐦 Social vs Political Brand Activism

**Tools:** R, Twitter API, Regression Analysis  
**Date:** 2023  
**Type:** Social Media Analytics  

---

##  Project Overview
<details>
<summary>Click to expand</summary>

In recent years, **corporate social advocacy (CSA)** — brands openly expressing opinions on sensitive topics — has intensified. While most research considers CSA generally, practice shows that brands often focus on narrower topics:  

- **Social CSA example:** Black Lives Matter  
- **Political CSA example:** Pension indexation debate in France  

The research objective: determine whether **social media engagement** differs depending on whether the CSA message is political or social.  

**Impact:** The findings help marketers and content managers select messages that maximize **positive social engagement**.
</details>

---

##  Methodology Overview
<details>
<summary>Click to expand</summary>

The research followed a **semantic analysis + regression modeling** approach:  

1. **Manual Coding & Training Sample**  
   - Randomly extracted 9,931 tweets  
   - Coded according to context:  
     - `1` → Social CSA  
     - `2` → Political CSA  
     - `0` → No CSA context  

2. **Data Preprocessing**  
   - **Normalization & Cleaning** using R (`text2vec`):  
     - Remove URLs, user mentions, hashtags, punctuation, special characters, RTs, numbers, emojis  
     - Lowercase text, remove whitespace, lemmatization, remove stopwords  
   - **Tokenization** → split text into individual words  
   - **Vectorization** → Document-Term Matrix (DTM)  
   - **Feature Transformation** → TF-IDF weighting  

3. **Machine Learning Classification**  
   - **Multinomial Logistic Regression** with `glmnet` in R  
   - Training set: 80%, Test set: 20%  
   - Cross-validation with 3 folds  
   - Hyperparameter α = 1 (Laplace smoothing)  
   - Evaluation: MAE = 0.0418, MSE = 0.048 → classifier performed well despite unbalanced data  

4. **Prediction**  
   - Classifier applied to remaining 102,938 tweets:  
     - Social CSA: 4,424 tweets  
     - Political CSA: 303 tweets  

5. **Qualitative Validation**  
   - Word clouds generated to visualize most frequent words per category  
</details>

---

## Results & Visualizations
<details>
<summary>Click to expand</summary>

- **Engagement Analysis:**  
  - Social CSA → higher positive engagement  
  - Political CSA → more mixed/controversial reactions  

**Visualizations:**  

![Engagement Comparison](./screenshots/engagement_comparison.png)  
*Figure 1: Average engagement by CSA type*  

![Word Cloud](./screenshots/wordcloud_social.png)  
*Figure 2: Most frequent words in Social CSA tweets*  

![Word Cloud](./screenshots/wordcloud_political.png)  
*Figure 3: Most frequent words in Political CSA tweets*  
</details>

---

## Key Takeaways
<details>
<summary>Click to expand</summary>

- Social CSA messages generate more **positive engagement** than political CSA  
- Machine learning + semantic analysis is effective for **large-scale text classification**  
- Findings can guide marketers in **optimizing brand messaging** on social media  
</details>

