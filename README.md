# Optimizing Social Media Ads Based on Demographic Data
This project analyzes customer behavior in response to social media advertisements using a dataset from Kaggle. The dataset consists of 400 records with information about individuals and their responses to specific ad campaigns..
https://www.kaggle.com/code/sakshisatre/customer-behavior-analysis-for-social-media-ads/input

# Data Statistics
## Descriptive Statistics
1. Age: Mean = 26.99, Std Dev = 7.86, Min = 18, Max = 50
2. EstimatedSalary: Mean = 56, Std Dev = 25, Min = 15, Max = 90
3. Purchased: Mean = 0.52, Std Dev = 0.50, Min = 0, Max = 1

## Data Distribution
1. Age: Evenly distributed, slightly skewed towards younger ages.
2. EstimatedSalary: Evenly distributed, slightly skewed towards higher salaries.
Purchased: Almost balanced with 52% making a purchase and 48% not.

# Data Preprocessing
## Stratification and Sampling
The data was stratified into five age groups: 18-25, 26-35, 36-45, 46-55, and 56-65. Sampling was done using Slovin's formula to ensure a representative sample, resulting in 200 samples. Proportional allocation was used to determine the sample size for each age group.

# Exploratory Data Analysis (EDA)
## Correlation Matrix
1. Purchased and AgeGroup: Moderate positive correlation (0.61).
2. Purchased and EstimatedSalary: Weaker positive correlation (0.30).
   
## Multicollinearity Check
Variance Inflation Factor (VIF) values for Age and EstimatedSalary were around 1.31, indicating no significant multicollinearity.

## Leverage and Outlier Detection
1. Leverage: Variations in hat values indicate significant influence by some observations.
2. Outliers: Some outliers detected, especially in Age and EstimatedSalary, but they do not significantly impact the overall data distribution.
3. Logistic Regression Model
Model Equation

# Logit(Y)=−14.17+0.271⋅Age+0.00005⋅EstimatedSalary

## Model Performance
1. Accuracy: 85.45%
2. Precision: 96.88%
3. Recall: 81.58%
4. F1 Score: 88.57%
   
# Goodness of Fit
1. Hosmer-Lemeshow Test: Chi-square = 15.409, p-value = 0.05167 (indicating good fit).
2. Shapiro-Wilk Test: p-value = 0.0001443 (some deviation from normality).
   
## Conclusion
The logistic regression model shows significant relationships between the predictors (Age and EstimatedSalary) and the response variable (Purchased). The model performs well with high accuracy, precision, recall, and F1 score, and passes the goodness-of-fit tests. Some outliers and leverage points are present but do not significantly affect the overall model performance.

