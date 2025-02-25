SELECT * FROM grocery;


-- Data Cleaning
-- 1. item fat content should be identified

SELECT DISTINCT item_fat_content FROM grocery;

/*
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
/*
"item_fat_content"
"Regular"
"Low Fat"
*/

-- Total Sales
SELECT SUM(total_sales) AS Total_Sales
FROM grocery;

SELECT 
    CAST(SUM(total_sales) / 1000000 AS DECIMAL(10,2)) 
    || ' Millions' AS Total_Sales_in_Millions
FROM grocery;

-- Total Sales of Low Fat Items only:
SELECT 
    CAST(SUM(total_sales) / 1000000 AS DECIMAL(10,2)) 
    || ' Millions' AS Low_Fat_Total_Sales
FROM grocery
WHERE item_fat_content = 'Low Fat';

-- Average Sales
SELECT AVG(total_sales) AS Average_Sales
FROM grocery;

SELECT 
    CAST(AVG(total_sales) AS INT) 
    || ' USD per sale' AS Average_Sales
FROM grocery;

-- Number of Items
SELECT COUNT(*) AS Number_of_Items
FROM grocery;

-- Average Rating
SELECT AVG(rating) AS Average_Rating
FROM grocery;

SELECT 
    CAST(AVG(rating) AS DECIMAL(10,2)) 
    || ' Stars' AS Average_Rating
FROM grocery;


-- Total Sales by Fat Content
SELECT 
    item_fat_content,
    CAST(SUM(total_sales) AS DECIMAL(10,2)) AS Total_Sales
FROM grocery
GROUP BY item_fat_content
ORDER BY Total_Sales DESC;

SELECT 
    item_fat_content,
    CAST(SUM(total_sales)/1000 AS DECIMAL(10,2)) || ' K' AS Total_Sales_in_Thousands,
    CAST(AVG(total_sales) AS DECIMAL(10,1)) AS Average_Sales,
    COUNT(*) AS Number_of_Items,
    CAST(AVG(rating) AS DECIMAL(10,2)) AS Average_Rating
FROM grocery
--WHERE outlet_establishment_year = 2022
GROUP BY item_fat_content
ORDER BY Total_Sales_in_Thousands DESC;


-- Total Sales by Item Type
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


-- Fat Content by Outlet for Total Sales
SELECT 
    item_fat_content,
    outlet_location_type, 
    SUM(Total_Sales)
FROM grocery
GROUP BY 
    item_fat_content,
    outlet_location_type
;

-- better
SELECT
    outlet_location_type,
    CAST(SUM(CASE WHEN item_fat_content = 'Low Fat' THEN total_sales END) AS DECIMAL(10,2)) AS low_fat,
    CAST(SUM(CASE WHEN item_fat_content = 'Regular' THEN total_sales END) AS DECIMAL(10,2)) AS Regular
FROM
    grocery
GROUP BY outlet_location_type
ORDER BY outlet_location_type
;


--4.Total Sales by Outlet Establishment
SELECT 
    outlet_establishment_year, 
    CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS total_sales
FROM grocery
GROUP BY 
    outlet_establishment_year
ORDER BY outlet_establishment_year
;


--5. Percentage of Sales by Outlet Size
SELECT 
    Outlet_Size, 
    CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales,
    CAST((SUM(Total_Sales) * 100.0 / SUM(SUM(Total_Sales)) OVER()) AS DECIMAL(10,2)) AS Sales_Percentage
FROM grocery
GROUP BY Outlet_Size
ORDER BY Total_Sales DESC;


--6. Sales by Outlet Location
SELECT 
    outlet_location_type, 
    CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales,
    CAST((SUM(Total_Sales) * 100.0 / SUM(SUM(Total_Sales)) OVER()) AS DECIMAL(10,2)) AS Sales_Percentage
FROM grocery
GROUP BY outlet_location_type
ORDER BY Total_Sales DESC;


--H. All Metrics by Outlet Type:
SELECT Outlet_Type, 
CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales,
		CAST(AVG(Total_Sales) AS DECIMAL(10,0)) AS Avg_Sales,
		COUNT(*) AS No_Of_Items,
		CAST(AVG(Rating) AS DECIMAL(10,2)) AS Avg_Rating,
		CAST(AVG(Item_Visibility) AS DECIMAL(10,2)) AS Item_Visibility
FROM grocery
GROUP BY Outlet_Type
ORDER BY Total_Sales DESC