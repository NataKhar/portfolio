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
 <details>
<summary>Click to view visual proof</summary>

![Visual Proof](./screenshots/visual_proof.png)

</details>

</details>

---

## Results & Visualizations

<details>
<summary>Click to expand</summary>

### 1️⃣ Engagement Overview

- **Dependent variable:** `Engagement` — the sum of likes, replies, quotes, and shares.  
- Distribution is highly right-skewed → most tweets have low engagement.  
- Scatterplots showed:  
  - Most data points belong to the group **without CSA**.  
  - Each group exhibits its **own engagement pattern**: higher engagement corresponds to fewer tweets.  

**Visualization:**  

![Engagement Distribution](./screenshots/engagement_distribution.png)  
*Figure 1: Distribution of total engagement per tweet*

---

### 2️⃣ Violin & Boxplots

- **Violin plots with embedded boxplots** were created for two main groups:  
  - Social CSA  
  - Political CSA  

**Key observations:**  
- Data distribution differs between the two groups.  
- Tweets with political context show **higher density at large engagement values**.  
- Median: political CSA < social CSA  
- Range: political CSA > social CSA  

**Visualization:**  

![Violin Plot](./screenshots/violin_plot.png)  
*Figure 2: Violin plot of engagement for social vs political CSA*

---

### 3️⃣ Statistical Testing

- **Variance check:** unequal → used **non-parametric test**  
- **Kruskal-Wallis test:** p-value = 0.005075 < 0.05 → statistically significant differences between groups

---

### 4️⃣ Regression Analysis

- **Data characteristics:** count data with strong over-dispersion → ordinary linear models are not suitable  
- **Chosen model:** Negative Binomial (NB) Regression  

**Over-dispersion check:**  
- Variance / Mean = 179,379 → much greater than 1 → NB regression justified  

**Model formula:** Engagement ~ CSA context + Time controls (year, month, time of day)  

**NB regression results (summary):**  
![NB regression results](./screenshots/regression.png) 

**Differences by engagement type:**  
![engagement](./screenshots/engagement.png) 

- **Conclusion:** Coefficients differ in magnitude and direction → groups significantly differ in their impact on engagement.  
- **Model evaluation:** AIC = 117,792, BIC = 1,178,118 → best among four tested models

</details>


---

## Key Takeaways
<details>
<summary>Click to expand</summary>

- Social CSA messages generate more **positive engagement** than political CSA  
- Machine learning + semantic analysis is effective for **large-scale text classification**  
- Findings can guide marketers in **optimizing brand messaging** on social media  
</details>

