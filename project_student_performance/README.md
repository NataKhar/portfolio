# Student Performance Analysis
[View Student Performance Project Code](portfolio/project_student_performance/student_performance_code.ipynb)


- **Languages:** Python 
- **Libraries/Methods:** Pandas, Scikit-learn, Random Forest, Decision Trees, KNN, Regression Analysis, Clustering, Data Visualization  

## Project Overview
This project investigates factors influencing student academic performance and predicts whether students intend to pursue higher education. The goal is to identify at-risk students and understand the conditions that affect academic success, enabling targeted interventions.

## Dataset
- **Source:** UCI Machine Learning Repository (Cortez, 2014)  
- **Scope:** Students from two Portuguese schools, focusing on Mathematics performance  
- **Features:** Demographics, academic grades, study habits, family support, school support, and behavioral factors  

## Methods & Analysis
1. **Data Exploration & Preprocessing**
   - Checked for missing values (none found)  
   - Summarized categorical and numerical features  
   - Converted relevant columns to numeric  
   - Investigated clusters of students based on performance (optimal number: 4)  

2. **Clustering**
   - Identified 4 student clusters ranging from high-achievers to low-achievers  
   - Key insights: academic discipline, family support, and study efficiency strongly influence final grades  

3. **Regression Modeling**
   - Models tested: Linear Regression, LASSO, KNN, Decision Tree, Random Forest  
   - Best model: Random Forest  
   - Important factors for grades: **failures, absences, parental education, family support, study time**  
   - Performance: Test R² ~ 0.22; MAE ~ 3.25, suggesting moderate prediction accuracy  

4. **Classification Modeling (Higher Education Intent)**
   - Models tested: Logistic Regression, Decision Tree, Random Forest  
   - Best model: Random Forest (Accuracy: 97.47%, Recall: 100%, ROC AUC: 0.92)  
   - Significant predictors: **failures, total study time, parental education, family support, absence rates, average grades**  

## Key Takeaways
- Student performance is influenced by both academic and non-academic factors, with failures and absences being critical negative indicators.  
- Parental education, family support, and study habits positively influence performance and the intention to pursue higher education.  
- Random Forest provides the most reliable predictions for both grades and higher education intentions, though some limitations remain due to unobserved factors.  
- Future improvements: include additional behavioral, psychological, and cross-subject features to enhance predictive accuracy.  


