# BlinkIT Grocery Data Analysis
[Dataset from kaggle](https://www.kaggle.com/datasets/arunkumaroraon/blinkit-grocery-dataset/data)

The "Blinkit Grocery Dataset" appears to be a fictional dataset designed for a grocery or retail scenario, possibly for analytical purposes.
## **1. Data Cleaning**
Whenever I work with categorical columns, my first step is to verify that each category is consistently written across all rows.

```sql
SELECT DISTINCT item_fat_content 
FROM grocery;

/*Output:
"item_fat_content"
"Low Fat"
"low fat"
"Regular"
"reg"
"LF"
*/

UPDATE grocery
SET item_fat_content = 
CASE 
    WHEN item_fat_content IN ('Low Fat', 'low fat', 'LF') THEN 'Low Fat'
    WHEN item_fat_content IN ('Regular', 'reg') THEN 'Regular'
    ELSE item_fat_content
END;

/*Output:
"item_fat_content"
"Regular"
"Low Fat"
*/
```
## **2. Data Analysis**
### **2.1. KPI's Requirments**

### **2.1.1. Total Sales:**
The overall revenue generated from all items sold
```sql
SELECT SUM(total_sales) AS Total_Sales
FROM grocery;

/*Output:
"total_sales"
1201681.4808000035
*/
```
Let's clean the result a little bit by displaying it in millions, rounding to two decimal places, and adding "Million" after the number
```sql
SELECT 
    CAST(SUM(total_sales) / 1000000 AS DECIMAL(10,2))
    || ' Millions' AS Total_Sales_in_Millions
FROM grocery;

/*Output:
"total_sales_in_millions"
"1.20 Millions"

*/
```
Now, it's easy to apply a filter and dive deeper. Let's find the total sales for Low Fat only
```sql
SELECT 
    CAST(SUM(total_sales) / 1000000 AS DECIMAL(10,2)) 
    || ' Millions' AS Total_Sales_in_Millions
FROM grocery
WHERE item_fat_content = 'Low Fat';

/*Output:
"Low_Fat_Total_Sales"
"0.78 Millions"
*/
```

### **2.1.2. Average Sales:**
The average revenue per sale
```sql
SELECT AVG(total_sales) AS Average_Sales
FROM grocery;

/*Output:
"average_sales"
140.9927819781771
*/

-- some cleaning
SELECT 
    CAST(AVG(total_sales) AS INT) 
    || ' USD per sale' AS Average_Sales
FROM grocery;

/*Output:
"average_sales"
"141 USD per sale"

*/
```
### **2.1.3. Number of Items:** 
The total count of different items sold
```sql
SELECT COUNT(*) AS Number_of_Items
FROM grocery;

/*Output:
"number_of_items"
"8523"
*/

```
### **2.1.4. Average Rating: The average customer rating for items sold**
```sql
SELECT 
    CAST(AVG(rating) AS DECIMAL(10,2)) 
    || ' Stars' AS Average_Rating
FROM grocery;

/*Output:
"average_rating"
"3.97 Stars"
*/

```
### **2.2. Granular Requirements**
### 2.2.1. **Total Sales by Fat Content:**
*	**Objective:** This analysis examines how fat content influences total sales, providing insights into consumer preferences.
*	**Additional KPI Metrics:** Assess how other KPIs (Average Sales, Number of Items, Average Rating) vary with fat content.
```sql
--Let's start simple:
SELECT 
    item_fat_content,
    CAST(SUM(total_sales) AS DECIMAL(10,2)) AS Total_Sales
FROM grocery
GROUP BY item_fat_content
ORDER BY Total_Sales DESC;

/*Output:
[
  {
    "item_fat_content": "Low Fat",
    "total_sales": "776319.68"
  },
  {
    "item_fat_content": "Regular",
    "total_sales": "425361.80"
  }
]
*/
```
Now, let's build on our previous analysis to uncover meaningful insights. By examining total sales, average sales, number of items, and average rating, we can gain a clearer understanding. This will help identify the best-performing fat content category and how other KPIs vary accordingly.

```sql
SELECT 
    item_fat_content,
    CAST(SUM(total_sales)/1000 AS DECIMAL(10,2)) 
        || ' K' AS Total_Sales_in_Thousands,
    CAST(AVG(total_sales) AS DECIMAL(10,1)) AS Average_Sales,
    COUNT(*) AS Number_of_Items,
    CAST(AVG(rating) AS DECIMAL(10,2)) AS Average_Rating
FROM grocery
-- WHERE outlet_establishment_year = 2022 --(if we want to focus on 1 year)
GROUP BY item_fat_content
ORDER BY Total_Sales_in_Thousands DESC;

```
Output:
| item_fat_content |  total_sales_in_thousands | average_sales   |number_of_items|average_rating|
|------------------|---------------------------|-----------------|---------------|--------------|
|Low Fat           |776.32 K                   | 140.7           |5517           |3.97          |
|Regular           |425.36 K                   | 141.5           |3006           |3.97          |


![Total Sales by Fat Content](https://github.com/EimanDaoud/Blinkit-Project/blob/main/Images/output.png?raw=true)
Charts codes? Check them out here: [Chart Python Code](charts.ipynb).

**Findings:**
* The insights from this data suggest that **both fat content categories are nearly equal in popularity**, as indicated by the similar average sales (140.7 vs. 141.5) and identical average ratings (3.97). 
* However, **the total sales for Low Fat (776.32K) are significantly higher than Regular (425.36K). This difference is mainly due to the wider variety of items available (5517 vs. 3006)** rather than differences in individual product performance. 
* Essentially, **the higher variety in Low Fat products contributed to its higher overall sales**, rather than a preference for one fat content over the other.

### 2.2.2. **Total Sales by Item Type:**
*	**Objective:** Identify the performance of different item types in terms of total sales.
*	**Additional KPI Metrics:** Assess how other KPIs (Average Sales, Number of Items, Average Rating) vary with fat content.

```sql
SELECT 
    item_type,
    CAST(SUM(total_sales) AS DECIMAL(10,2)) AS Total_Sales,
    CAST(AVG(total_sales) AS DECIMAL(10,1)) AS Average_Sales,
    COUNT(*) AS Number_of_Items,
    CAST(AVG(rating) AS DECIMAL(10,2)) AS Average_Rating
FROM grocery
--WHERE outlet_establishment_year = 2022
GROUP BY item_type
ORDER BY Total_Sales DESC;

```
![Total Sales by Item Type](https://github.com/EimanDaoud/Blinkit-Project/blob/main/Images/Comparison%20of%20Item%20Types%20Across%20Metrics.png?raw=true)
Charts codes? Check them out here: [Chart Python Code](charts.ipynb).


**Findings:**
* The data reveals that **Fruits and Vegetables lead in total sales** ($178.12K), closely followed by Snack Foods ($175.43K). Despite their high sales, their average sales per item are slightly lower than categories like Household ($149.4) and Dairy ($148.5), which suggests that those categories may **have fewer but higher-selling items.**

* **Household items** rank third in total sales ($135.98K) but **have one of the highest average ratings (4.00)**, indicating strong customer satisfaction. **Meat has the highest average rating (4.02)**, even though its total sales are much lower ($59.45K), suggesting it may be a niche but well-liked category.

* Interestingly, **Breakfast items and Seafood rank at the bottom in total sales**, with Seafood having the lowest sales ($9.08K), despite a respectable average sales per item ($141.8). **This could indicate limited availability rather than low demand.**

* Overall, total sales do not always correlate with average sales per item or customer ratings, making it important to look at multiple KPIs to understand performance across categories.





### 2.2.3. **Fat Content by Outlet for Total Sales:**
*	**Objective:** Compare total sales across different outlets segmented by fat content.
*	**Additional KPI Metrics:** Assess how other KPIs (Average Sales, Number of Items, Average Rating) vary with fat content.

```sql
SELECT
    outlet_location_type,
    CAST(SUM(CASE WHEN item_fat_content = 'Low Fat' THEN total_sales END) AS DECIMAL(10,2)) AS low_fat,
    CAST(SUM(CASE WHEN item_fat_content = 'Regular' THEN total_sales END) AS DECIMAL(10,2)) AS Regular
FROM
    grocery
GROUP BY outlet_location_type
ORDER BY outlet_location_type


```
Output:
| outlet_location_type |  low_fat | Regular   |
|----------------------|----------|-----------|
|Tier 1                |215047.91 | 121349.90 |
|Tier 2                |254464.77 | 138685.87 |
|Tier 3                |306806.99 |  165326.03|


### 2.2.4. **Total Sales by Outlet Establishment:**
*	**Objective:** Evaluate how the age or type of outlet establishment influences total sales.

```sql
SELECT 
    outlet_establishment_year, 
    CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS total_sales
FROM grocery
GROUP BY 
    outlet_establishment_year
ORDER BY outlet_establishment_year

```
![Total Sales by Outlet Establishment](https://github.com/EimanDaoud/Blinkit-Project/blob/main/Images/Total%20Sales%20by%20Outlet%20Establishment%20Year.png?raw=true)

Charts codes? Check them out here: [Chart Python Code](charts.ipynb).

### **2.3. Chart Requirements**
### **2.3.1 Percentage of Sales by Outlet Size:
**Objective:** Analyze the correlation between outlet size and total sales.
```sql
SELECT 
    Outlet_Size, 
    CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales,
    CAST((SUM(Total_Sales) * 100.0 / SUM(SUM(Total_Sales)) OVER()) AS DECIMAL(10,2)) AS Sales_Percentage
FROM grocery
GROUP BY Outlet_Size
ORDER BY Total_Sales DESC;
```
Output:
| outlet_size |  total_sales | sales_percentage|
|-------------|--------------|-----------------|
|Medium       |507895.73     | 42.27           |
|Small        |444794.17     | 37.01           |
|High         |248991.58     | 20.72           |


### **2.3.2 Sales by Outlet Location:
**Objective:** Assess the geographic distribution of sales across different locations.
```sql
SELECT 
    outlet_location_type, 
    CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales,
    CAST((SUM(Total_Sales) * 100.0 / SUM(SUM(Total_Sales)) OVER()) AS DECIMAL(10,2)) AS Sales_Percentage
FROM grocery
GROUP BY outlet_location_type
ORDER BY Total_Sales DESC;
```
Output:
| outlet_location_type |  total_sales | sales_percentage|
|----------------------|--------------|-----------------|
|Tier 3                |472133.03     | 39.29           |
|Tier 2                |393150.64     | 32.72           |
|Tier 1                |336397.81     | 27.99           |


### **2.3.3 All Metrics by Outlet Type:
**Objective:** Provide a comprehensive view of all key metrics (Total Sales, Average Sales, Number of 	Items, Average Rating) broken down by different outlet types.
```sql
SELECT Outlet_Type, 
CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales,
		CAST(AVG(Total_Sales) AS DECIMAL(10,0)) AS Avg_Sales,
		COUNT(*) AS No_Of_Items,
		CAST(AVG(Rating) AS DECIMAL(10,2)) AS Avg_Rating,
		CAST(AVG(Item_Visibility) AS DECIMAL(10,2)) AS Item_Visibility
FROM grocery
GROUP BY Outlet_Type
ORDER BY Total_Sales DESC
```
Output:
| outlet_type       |  total_sales | avg_sales|no_of_items|avg_rating|item_visibility|
|-------------------|--------------|----------|-----------|----------|---------------|
|Supermarket Type1  |787549.89     | 141      |5577       |3.96      |0.06           |
|Grocery Store      |151939.15     | 140      |1083       |3.99      |0.10           |
|Supermarket Type2  |131477.77     | 142      |928        |3.97      |0.06           |
|Supermarket Type3  |130714.67     | 140      |935        |3.95      |0.06           |


![BlinkIT Power BI Dashboard](https://github.com/EimanDaoud/Blinkit-Project/blob/main/Images/BlinkIT%20Power%20BI%20Dashboard.png?raw=true)