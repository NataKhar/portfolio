# Bias Mitigation in Recommender Systems  
[View the code here](./Code_Algorithms_Mitigation.ipynb)
 

## Tech & Methods  
- **Languages/Tools:** Python, Jupyter Notebook, PyCharm  
- **Algorithms:** RAND, POP, ItemKNN, ALS, BPR, VAE, SLIM  
- **Bias Mitigation Approaches:**  
  - Inverse-Popularity Sampling  
  - Popularity-Penalized Similarity Weighting  
  - Popularity-Weighted Loss  
- **Evaluation Metrics:** %ΔMean, KL Divergence, Kendall’s τ, NDCG@10, Recall@10  

## Data  
- **LFM-2b dataset:** Subset of Last.fm (requires author permission).  
- **Book-Crossing dataset:** [Kaggle link](https://www.kaggle.com/datasets/syedjaferk/book-crossing-dataset) (CC0: Public Domain).  

This project replicates the study by **Lesota et al.** on item popularity bias in music recommender systems and extends it with bias mitigation techniques.  
We evaluate seven algorithms on the **LFM-2b dataset** (Last.fm) and replicate the experiments on the **Book-Crossing dataset** to assess generalizability.  

## Project Overview  
- **Algorithms tested:** RAND, POP, ItemKNN, ALS, BPR, VAE, SLIM  
- **Bias Mitigation:** Applied to 3 selected algorithms (RAND, ItemKNN, VAE)  
- **Datasets:**  
  - **LFM-2b** (subset of Last.fm, not publicly available – provided by original authors)  
  - **Book-Crossing dataset** (publicly available, CC0 licensed)  
- **Goal:** Compare popularity bias and gender disparities across algorithms and datasets, and test the effectiveness of mitigation strategies.  

## Key Findings  
- **RAND:** Unbiased by design; mitigation worsens performance.  
- **ItemKNN:** Strong popularity bias; mitigation reduces bias but severely hurts performance.  
- **VAE:** Most robust; low bias and maintains balance between fairness and quality even after mitigation.  
- **Generalizability:** Results on LFM-2b do not fully transfer to Book-Crossing, highlighting dataset dependency.  

