# Telco Customer Churn Analysis
This project analyzes telco customer churn using both descriptive analysis and predictive modeling with machine learning to identify churn patterns.

### Problem 
Acquiring new customers is often more costly than retaining existing ones, making customer loyalty a critical factor for business sustainability. A high churn rate not only reduces immediate revenue but also poses long-term risks by diminishing the potential lifetime value of customers. Understanding and addressing the drivers of churn is therefore essential to maintain profitability and ensure steady business growth.

### Goals
- Identifying strategies to maintain existing customers and strengthen loyalty.

- Developing proactive measures to reduce the risk of increasing churn rates over time.

- Analyzing customer behavior and key features that influence churn to support better decision-making.

### Analysis 

**How many customers have churned compared to those who were retained?**
![alt text](imgs\image.png)
Customer retention is at 73.4%, outpacing churn at 26.5% by 46.9%, suggesting a stable and loyal customer base.

**What is the total charges paid by churned customers versus retained customers?**
![alt text](imgs\image-1.png)
Retained customers spend more (2,549.91) than churned customers (1,531), highlighting strong loyalty despite higher expenses.

**How many churn cases occurred among customers with a significant difference between actual charges(```Totalcharges```) paid and expected charges?**
![alt text](imgs\image-2.png)
Despite a large payment discrepancy (>100 vs. avg. 0.15), 63.39% of customers remain retained, indicating that high differences do not directly trigger churn.

**What are the average monthly charges for churned and retained customers?**
![alt text](imgs\image-3.png)
Churned customers spend an average of 74.44 per month, which is higher compared to 61.27 for retained customers. This suggests that higher monthly charges may be associated with an increased likelihood of churn.

**How is churn distributed across different tenure ranges ?** 
![alt text](imgs\image-4.png)
On average, retained customers have significantly longer tenure compared to churned customers, indicating that churn typically occurs among customers with shorter subscription periods.

**What is the churn rate by contract type ?**
![alt text](imgs\image-5.png)
The majority of churned customers (88.55%) are on month-to-month contracts, significantly higher than those with one-year or two-year contracts. This reinforces the indication that shorter commitments are strongly associated with higher churn rates.

![alt text](imgs\image-6.png)
Churn is heavily concentrated within the first 0–9 months of tenure, indicating that customers are most vulnerable to leaving during the early stage of their subscription lifecycle.


**What is the average number of services subscribed by churned and retained customers ?**
![alt text](imgs\image-7.png)
More than 350 churned customers subscribed to 3–4 services, whereas over 1,000 retained customers typically used only 1–2 services. This indicates that higher service adoption does not necessarily lead to stronger customer loyalty and may even increase the likelihood of churn.

**Which specific services are more associated with churn ?**
![alt text](imgs\image-8.png)
The majority of churned customers are concentrated in Internet services (1,750) and Phone services (1,700). This highlights that these two service categories are the most vulnerable to customer attrition and should be prioritized for retention strategies.

**Which specific internet service is more associated with churn ?** 
![alt text](imgs\image-9.png)
Among churned customers, more than 1,200 (69%) are Fiber Optic users, which is significantly higher compared to DSL users. This indicates that Fiber Optic customers are more prone to churn and require focused retention strategies. 

![alt text](imgs\image-10.png)
Churned Fiber Optic customers face an average monthly charge of 90, which is 53% higher than other service types. This suggests that higher monthly expenses are a key driver of churn among Fiber Optic users.

**How many additional services (beyond basic internet service) are subscribed by churned customers?**
![alt text](imgs\image-11.png)
On average, churned customers with Fiber Optic connections subscribe to more additional services compared to DSL users. This indicates that despite adopting multiple add-ons, the higher costs associated with Fiber Optic may contribute to increased churn. 


**Which additional services are most frequently used by churned customers who subscribe to fiber optic internet?**
![alt text](imgs\image-12.png)
Among churned Fiber Optic customers, Phone Service shows the highest adoption with more than 1,200 users, followed by Multiple Lines, Streaming TV, and Streaming Movies. This suggests that even though these customers actively use multiple services, the high overall costs may contribute to their decision to churn.

**What is the average tenure of customers without dependents?** 
![alt text](imgs\image-13.png)
Customers with dependents have a higher average tenure (38 months) compared to those without dependents (30 months). This indicates that customers with greater responsibilities tend to stay loyal longer, possibly due to higher service needs or stability in their usage.

**How much is monthly charges for customers with dependents compared to not dependents ?**
![alt text](imgs\image-14.png)
Customers without dependents pay higher average monthly charges (67) compared to those with dependents (60). This may explain why their tenure is shorter, as higher costs could contribute to earlier churn despite no additional family responsibilities.

**Which type of internet service is most commonly used by customers without dependents ?**
![alt text](imgs\image-15.png)
Customers without dependents are more likely to use fiber optic internet (2,434) compared to DSL (883). This suggests that customers without family responsibilities tend to adopt higher-speed, premium services, which could also contribute to their higher monthly charges.

**What is the churn distribution between customers with dependents and those without dependents ?**
![alt text](imgs\image-16.png)
The number of churners is significantly higher among customers without dependents (1,543) compared to those with dependents (326). This indicates that customers with dependents may show greater stability and loyalty, while customers without dependents are more prone to switching providers, possibly due to fewer financial or household commitments.

### Analysis Churn using Logistic Regression and Support Vector Machine (SVM)
Logistic Regression and Support Vector Machine (SVM) were applied to identify the features influencing customer churn. Both models were trained on a preprocessed dataset that had been converted into numeric format and split into training and testing sets. The training results showed that Logistic Regression achieved an accuracy of 80%, while SVM achieved 70%. Beyond accuracy, both models were utilized to assess the relative importance of features contributing to churn.

The analysis reveals that contract types and service offerings are the primary drivers of customer churn, while pricing and demographics play a much smaller role.

- Customers with a two-year contract are less likely to churn, making long-term contracts a strong retention lever.

- Fiber optic internet service and phone service strongly influence churn, highlighting the importance of service quality and reliability.

- Payment methods such as paperless billing, electronic check, and mailed check are more associated with churn compared to automatic credit card payments, suggesting that simplifying payment options may improve retention.

- Demographic factors (senior citizen, gender, partner, dependents) and pricing factors (monthly and total charges) have minimal influence, indicating that loyalty is driven more by service and contract experience rather than customer profile or cost.


### Summary 
Customer retention remains strong at 73.4%, though 26.5% churn highlights risks, especially among month-to-month contracts and customers in their first 0–9 months. Churn is heavily concentrated among Fiber Optic users (69%), driven by higher monthly charges (53% more than other services) and greater adoption of add-on services. Customers without dependents show a higher churn rate, suggesting lower commitment and higher sensitivity to costs.

To reduce churn and increase retention, companies should:

- Promote long-term contracts with incentives.
- Introduce pricing adjustments or bundled packages for Fiber Optic services.
- Focus retention programs in the early subscription phase (0–9 months).
- Offer cost-efficient bundles for add-on services.
- Target customers without dependents with tailored offers to improve loyalty.

### Recommendations 
- Promote long-term contracts with incentives to reduce churn among month-to-month and early-stage customers (0–9 months).

- Address Fiber Optic churn risks through bundled packages, pricing adjustments, and service quality improvements.

- Offer cost-efficient bundles for add-on services to increase value perception.

- Target customers without dependents with tailored offers to improve loyalty.

- Focus retention strategies on contract flexibility, superior service quality, and optimized payment experiences rather than price cuts alone.