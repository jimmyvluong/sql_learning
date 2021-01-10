-- Return the total spent per each customer ordered highest to lowest spending customers.
SELECT I.CustomerId, Country, Sum(Total) AS Total_Spent
FROM Invoice AS I
JOIN Customer AS C
ON I.CustomerId = C.CustomerId
GROUP BY I.CustomerId
ORDER BY SUM(Total) DESC
;

WITH CTE
AS 
(
SELECT
	Sales_Id
	, SUM(Line_Total) AS total
FROM Sales _Details
GROUP BY Sales_Id
)

SELECT * FROM CTE AS A
INNER JOIN Sales_Details AS B
	ON A.Sales_Id = B.Sales_Id

SELECT   * FROM Invoice;
	
-- Window Functions
-- Take a look at data of interest
SELECT  CustomerId
			, InvoiceId
			, InvoiceDate
			, BillingPostalCode
			, Total AS Total_Donation
FROM invoice

-- Give me the total spent per CustomerId
SELECT  CustomerId
			, SUM(Total) AS Total_Donation_Per_Person
FROM invoice
GROUP BY CustomerId

-- To get total spent per customer and the associated information, you would need to run queries against the table two times.

-- Window Functions let you run one query. It's much cleaner and more efficient.
-- We haven't had to write a CTE to group the data, and then join back to the table again. 
SELECT  CustomerId
			, InvoiceId
			, InvoiceDate
			, BillingPostalCode
			, Total AS Total_Donation
			, SUM(Total) OVER(PARTITION BY CustomerId) AS donor_total
-- OVER lets us divide the data into windows
-- PARTITION further divides the data down into individual partitions, similar to GROUP BY
-- Each salesId will represent an individual partition
FROM invoice

-- How many donations per each customer?
-- What is the average donation per each individual customer?
-- This can let us segment donors - by some thresholds ($) and by frequency and timing (date of donations)
SELECT  CustomerId
			, InvoiceId
			, InvoiceDate
			, BillingPostalCode
			, Total AS Total_Donation
			, COUNT(Total) OVER(PARTITION BY CustomerId) AS number_of_donations
			, SUM(Total) OVER(PARTITION BY CustomerId) AS donor_total
			, SUM(Total) OVER(PARTITION BY CustomerId) /COUNT(Total) OVER(PARTITION BY CustomerId)  AS average_donation_per_donor
-- OVER lets us divide the data into windows
-- PARTITION further divides the data down into individual partitions, similar to GROUP BY
-- Each salesId will represent an individual partition
FROM invoice

-- What percent of total donations did this donor contribute?
-- What are the daily total donation amounts?
SELECT  CustomerId
			, InvoiceId
			, InvoiceDate
			, BillingPostalCode
			, Total AS Total_Donation
			, COUNT(Total) OVER(PARTITION BY CustomerId) AS number_of_donations
			, SUM(Total) OVER(PARTITION BY CustomerId) AS donor_total
			, SUM(Total) OVER() AS overall_total_donations
-- OVER() looks at data as a whole because we haven't partitioned it
FROM invoice

-- Census Data: At SFC we use census data to look at delivery of credits in terms of widening participation.
-- Can help you answer questions like: Given our understanding of past donor behavior and donor demographics,
-- Is there an opportunity to increase donor participation in X region?
SELECT  DISTINCT CustomerId
			, BillingPostalCode
			, SUM(Total) OVER(PARTITION BY CustomerId) /COUNT(Total) OVER(PARTITION BY CustomerId)  AS average_donation_per_donor
			, SUM(Total) OVER()/COUNT(Total) OVER() AS overall_average_donation
			, CASE	
				WHEN SUM(Total) OVER(PARTITION BY CustomerId) /COUNT(Total) OVER(PARTITION BY CustomerId)  > 
				(SUM(Total) OVER()/COUNT(Total) OVER()) THEN 'Super Donor'
				ELSE 'Normal Donor'
			END AS donor_class
FROM invoice
