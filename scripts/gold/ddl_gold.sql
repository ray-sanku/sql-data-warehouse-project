/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

-- =============================================================================
-- Create Dimension: gold.dim_customers
-- =============================================================================
CREATE OR REPLACE VIEW GOLD.DIM_CUSTOMERS AS
SELECT
	ROW_NUMBER() OVER (
		ORDER BY
			CCI.CST_ID
	) CUSTOMER_KEY,
	CCI.CST_ID AS CUSTOMER_ID,
	CCI.CST_KEY AS CUSTOMER_NUMBER,
	CCI.CST_FIRSTNAME AS FIRSTNAME,
	CCI.CST_LASTNAME AS LASTNAME,
	LA.CNTRY AS COUNTRY,
	CCI.CST_MARITAL_STATUS AS MARITAL_STATUS,
	CASE
		WHEN CCI.CST_GNDR != 'n/a' THEN CCI.CST_GNDR
		ELSE COALESCE(CA.GEN, 'n/a')
	END AS GENDER,
	CA.BDATE BIRTHDAY,
	--CCI.CST_GNDR,
	CCI.CST_CREATE_DATE
	--CA.GEN,	
FROM
	SILVER.CRM_CUST_INFO CCI
	LEFT JOIN SILVER.ERP_CUST_AZ12 CA ON CCI.CST_KEY = CA.CID
	LEFT JOIN SILVER.ERP_LOC_A101 LA ON CCI.CST_KEY = LA.CID;

-- =============================================================================
-- Create Dimension: gold.dim_products
-- =============================================================================
CREATE OR REPLACE VIEW GOLD.DIM_PRODUCTS AS
SELECT
	ROW_NUMBER() OVER (
		ORDER BY
			PD.PRD_START_DT,
			PD.PRD_KEY
	) AS PRODUCT_KEY,
	PD.PRD_ID AS PRODUCT_ID,
	PD.PRD_KEY AS PRODUCT_NUMBER,
	PD.PRD_NM AS PRODUCT_NAME,
	PD.CAT_ID AS CATEGORY_ID,
	CAT.CAT AS CATEGORY,
	CAT.SUBCAT AS SUBCATEGORY,
	CAT.MAINTENANCE,
	PD.PRD_COST AS PRODUCT_COST,
	PD.PRD_LINE AS PRODUCT_LINE,
	PD.PRD_START_DT AS START_DATE
FROM
	SILVER.CRM_PRD_INFO PD
	LEFT JOIN SILVER.ERP_PX_CAT_G1V2 CAT ON CAT.ID = PD.CAT_ID
WHERE
	PD.PRD_END_DT IS NULL ---- Removing historical records
	OR PD.PRD_END_DT >= NOW();

-- =============================================================================
-- Create Facts: gold.facts_sales
-- =============================================================================
CREATE OR REPLACE VIEW GOLD.FACT_SALES AS
SELECT
	SAL.SLS_ORD_NUM,
	PD.PRODUCT_KEY,
	CUS.CUSTOMER_KEY,
	SAL.SLS_ORDER_DT AS ORDER_DATE,
	SAL.SLS_SHIP_DT AS SHIP_DATE,
	SAL.SLS_DUE_DT AS DUE_DATE,
	SAL.SLS_SALES AS SALES,
	SAL.SLS_QUANTITY AS QUANTITY,
	SAL.SLS_PRICE AS PRICE
FROM
	SILVER.CRM_SALES_DETAILS SAL
	LEFT JOIN GOLD.DIM_PRODUCTS PD ON PD.PRODUCT_NUMBER = SAL.SLS_PRD_KEY
	LEFT JOIN GOLD.DIM_CUSTOMERS CUS ON CUS.CUSTOMER_ID = SAL.SLS_CUST_ID;
