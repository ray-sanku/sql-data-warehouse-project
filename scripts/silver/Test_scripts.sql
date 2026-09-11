select * from bronze.crm_cust_info;

SELECT
	CST_ID,
	COUNT(1)
FROM
	BRONZE.CRM_CUST_INFO
GROUP BY
	CST_ID
HAVING
	COUNT(1) > 1;

SELECT
	*
FROM
	(
		SELECT
			CST_ID,
			CST_KEY,
			CST_FIRSTNAME,
			CST_LASTNAME,
			CST_MARITAL_STATUS,
			CST_GNDR,
			CST_CREATE_DATE,
			ROW_NUMBER() OVER (
				PARTITION BY
					CST_ID
				ORDER BY
					CST_CREATE_DATE DESC
			) AS SELECTION_RANK
		FROM
			BRONZE.CRM_CUST_INFO
			--where cst_id = 29433
	)
WHERE
	SELECTION_RANK = 1;

SELECT
	CST_ID,
	CST_KEY,
	TRIM(CST_FIRSTNAME),
	TRIM(CST_LASTNAME),
	CASE UPPER(TRIM(CST_MARITAL_STATUS))
		WHEN 'M' THEN 'Married'
		WHEN 'S' THEN 'Single'
		ELSE 'n/a'
	END AS CST_MARITAL_STATUS,
	CASE UPPER(TRIM(CST_GNDR))
		WHEN 'M' THEN 'Male'
		WHEN 'F' THEN 'Female'
		ELSE 'n/a'
	END AS CST_GNDR,
	CST_CREATE_DATE
FROM
	(
		SELECT
			CST_ID,
			CST_KEY,
			CST_FIRSTNAME,
			CST_LASTNAME,
			CST_MARITAL_STATUS,
			CST_GNDR,
			CST_CREATE_DATE,
			ROW_NUMBER() OVER (
				PARTITION BY
					CST_ID
				ORDER BY
					CST_CREATE_DATE DESC
			) AS SELECTION_RANK
		FROM
			BRONZE.CRM_CUST_INFO
	)
WHERE
	SELECTION_RANK = 1;  --- select the most recent records

select * from silver.crm_cust_info;	

ALTER TABLE SILVER.CRM_CUST_INFO
ALTER COLUMN CST_MARITAL_STATUS TYPE VARCHAR(15),
ALTER COLUMN CST_GNDR TYPE VARCHAR(15);
---------------------------------------------
---------- INSERT --------------------------


TRUNCATE SILVER.CRM_CUST_INFO;

INSERT INTO
	SILVER.CRM_CUST_INFO (
		CST_ID,
		CST_KEY,
		CST_FIRSTNAME,
		CST_LASTNAME,
		CST_MARITAL_STATUS,
		CST_GNDR,
		CST_CREATE_DATE
	)
SELECT
	CST_ID,
	CST_KEY,
	TRIM(CST_FIRSTNAME),
	TRIM(CST_LASTNAME),
	CASE UPPER(TRIM(CST_MARITAL_STATUS))
		WHEN 'M' THEN 'Married'
		WHEN 'S' THEN 'Single'
		ELSE 'n/a'
	END AS CST_MARITAL_STATUS,
	CASE UPPER(TRIM(CST_GNDR))
		WHEN 'M' THEN 'Male'
		WHEN 'F' THEN 'Female'
		ELSE 'n/a'
	END AS CST_GNDR,
	CST_CREATE_DATE
FROM
	(
		SELECT
			CST_ID,
			CST_KEY,
			CST_FIRSTNAME,
			CST_LASTNAME,
			CST_MARITAL_STATUS,
			CST_GNDR,
			CST_CREATE_DATE,
			ROW_NUMBER() OVER (
				PARTITION BY
					CST_ID
				ORDER BY
					CST_CREATE_DATE DESC
			) AS SELECTION_RANK
		FROM
			BRONZE.CRM_CUST_INFO
	)
WHERE
	SELECTION_RANK = 1;

------------------------------ 2nd table ---------------------------

select * from bronze.crm_prd_info;

select * from bronze.erp_px_cat_g1v2; -- AC_BR,CO_PD

select * from bronze.erp_loc_a101;

select * from bronze.crm_sales_details; -- BK-M82S-44,BK-M82B-48

SELECT
	PRD_ID,
	SUBSTR(PRD_KEY, 1, 5) AS CAT_ID,
	SUBSTR(PRD_KEY, 7, LENGTH(PRD_KEY)) PRD_KEY,
	PRD_NM,
	COALESCE(PRD_COST, 0) PRD_COST,
	CASE UPPER(TRIM(PRD_LINE))
		WHEN 'M' THEN 'Mountain'
		WHEN 'R' THEN 'Road'
		WHEN 'S' THEN 'Other Sales'
		WHEN 'T' THEN 'Touring'
		ELSE 'n/a'
	END AS PRD_LINE,
	PRD_START_DT,
	LEAD(PRD_START_DT) OVER (
		PARTITION BY
			PRD_KEY
		ORDER BY
			PRD_START_DT
	) -1 AS PRD_END_DT
FROM
	BRONZE.CRM_PRD_INFO;

select * from silver.CRM_PRD_INFO;

ALTER TABLE SILVER.CRM_PRD_INFO
ADD COLUMN CAT_ID VARCHAR(30);

ALTER TABLE SILVER.CRM_PRD_INFO
ALTER COLUMN PRD_LINE TYPE VARCHAR(30);

--------------------- INSERT ----------------------------

TRUNCATE SILVER.CRM_PRD_INFO;

INSERT INTO
	SILVER.CRM_PRD_INFO (
		PRD_ID,
		CAT_ID,
		PRD_KEY,
		PRD_NM,
		PRD_COST,
		PRD_LINE,
		PRD_START_DT,
		PRD_END_DT
	)
SELECT
	PRD_ID,
	SUBSTR(PRD_KEY, 1, 5) AS CAT_ID,
	SUBSTR(PRD_KEY, 7, LENGTH(PRD_KEY)) PRD_KEY,
	PRD_NM,
	COALESCE(PRD_COST, 0) PRD_COST,
	CASE UPPER(TRIM(PRD_LINE))
		WHEN 'M' THEN 'Mountain'
		WHEN 'R' THEN 'Road'
		WHEN 'S' THEN 'Other Sales'
		WHEN 'T' THEN 'Touring'
		ELSE 'n/a'
	END AS PRD_LINE,
	PRD_START_DT,
	LEAD(PRD_START_DT) OVER (
		PARTITION BY
			PRD_KEY
		ORDER BY
			PRD_START_DT
	) -1 AS PRD_END_DT
FROM
	BRONZE.CRM_PRD_INFO;

--------------------------------------------------

SELECT
	SLS_ORD_NUM,
	SLS_PRD_KEY,
	SLS_CUST_ID,
	CASE
		WHEN SLS_ORDER_DT = 0
		OR LENGTH(CAST(SLS_ORDER_DT AS VARCHAR)) <> 8 THEN NULL
		ELSE TO_DATE(CAST(SLS_ORDER_DT AS VARCHAR), 'yyyymmdd')
	END AS SLS_ORDER_DT,
	CASE
		WHEN SLS_SHIP_DT = 0
		OR LENGTH(CAST(SLS_SHIP_DT AS VARCHAR)) <> 8 THEN NULL
		ELSE TO_DATE(CAST(SLS_SHIP_DT AS VARCHAR), 'yyyymmdd')
	END AS SLS_SHIP_DT,
	CASE
		WHEN SLS_DUE_DT = 0
		OR LENGTH(CAST(SLS_DUE_DT AS VARCHAR)) <> 8 THEN NULL
		ELSE TO_DATE(CAST(SLS_DUE_DT AS VARCHAR), 'yyyymmdd')
	END AS SLS_DUE_DT,
	SLS_SALES,
	SLS_QUANTITY,
	SLS_PRICE
FROM
	BRONZE.CRM_SALES_DETAILS;

select TO_DATE(cast(20101229 as VARCHAR),'yyyymmdd');

select now();

select distinct SLS_ORDER_DT, sls_ship_dt, sls_due_dt
FROM
	BRONZE.CRM_SALES_DETAILS
	where length(CAST(sls_due_dt AS VARCHAR)) != 8;

select * from SILVER.CRM_SALES_DETAILS;

---------------------- INSERT ------------------------------

TRUNCATE SILVER.CRM_SALES_DETAILS;

ALTER TABLE SILVER.CRM_SALES_DETAILS
ALTER COLUMN SLS_ORDER_DT TYPE DATE USING to_date(SLS_ORDER_DT::text, 'YYYYMMDD');

ALTER TABLE SILVER.CRM_SALES_DETAILS
ALTER COLUMN SLS_SHIP_DT TYPE DATE USING TO_DATE(SLS_ORDER_DT::TEXT, 'YYYYMMDD'),
ALTER COLUMN SLS_DUE_DT TYPE DATE USING TO_DATE(SLS_ORDER_DT::TEXT, 'YYYYMMDD');

INSERT INTO
	SILVER.CRM_SALES_DETAILS (
		SLS_ORD_NUM,
		SLS_PRD_KEY,
		SLS_CUST_ID,
		SLS_ORDER_DT,
		SLS_SHIP_DT,
		SLS_DUE_DT,
		SLS_SALES,
		SLS_QUANTITY,
		SLS_PRICE
	)
SELECT
	SLS_ORD_NUM,
	SLS_PRD_KEY,
	SLS_CUST_ID,
	CASE
		WHEN SLS_ORDER_DT = 0
		OR LENGTH(CAST(SLS_ORDER_DT AS VARCHAR)) <> 8 THEN NULL
		ELSE TO_DATE(CAST(SLS_ORDER_DT AS VARCHAR), 'yyyymmdd')
	END AS SLS_ORDER_DT,
	CASE
		WHEN SLS_SHIP_DT = 0
		OR LENGTH(CAST(SLS_SHIP_DT AS VARCHAR)) <> 8 THEN NULL
		ELSE TO_DATE(CAST(SLS_SHIP_DT AS VARCHAR), 'yyyymmdd')
	END AS SLS_SHIP_DT,
	CASE
		WHEN SLS_DUE_DT = 0
		OR LENGTH(CAST(SLS_DUE_DT AS VARCHAR)) <> 8 THEN NULL
		ELSE TO_DATE(CAST(SLS_DUE_DT AS VARCHAR), 'yyyymmdd')
	END AS SLS_DUE_DT,
	SLS_SALES,
	SLS_QUANTITY,
	SLS_PRICE
FROM
	BRONZE.CRM_SALES_DETAILS;

-------------- Test silver load -----------------------------------
call silver.load_silver();
--------------------------------------------------------------------

-------------------- ERP tables --------------------------
select * from bronze.erp_cust_az12;

select * from silver.crm_cust_info
where cst_key in (select substr(cid, 4, length(cid)) from bronze.erp_cust_az12);

SELECT
	SUBSTR(CID, 4, LENGTH(CID)) CID,
	BDATE,
	CASE 
		WHEN UPPER(TRIM(GEN)) in ('M', 'MALE') THEN 'Male'
		WHEN UPPER(TRIM(GEN)) in ('F', 'FEMALE') THEN 'Female'
		ELSE 'n/a'
	END AS GEN
FROM
	BRONZE.ERP_CUST_AZ12;

select * from SILVER.ERP_CUST_AZ12;

------------------INSERT -------------------------
TRUNCATE SILVER.ERP_CUST_AZ12;

INSERT INTO
	SILVER.ERP_CUST_AZ12 (CID, BDATE, GEN)
SELECT
	SUBSTR(CID, 4, LENGTH(CID)) CID,
	BDATE,
	CASE
		WHEN UPPER(TRIM(GEN)) IN ('M', 'MALE') THEN 'Male'
		WHEN UPPER(TRIM(GEN)) IN ('F', 'FEMALE') THEN 'Female'
		ELSE 'n/a'
	END AS GEN
FROM
	BRONZE.ERP_CUST_AZ12;

------------------------------------------------
select * from bronze.erp_loc_a101;

SELECT
	REPLACE(CID, '-', '') CID,
	CASE
		WHEN UPPER(TRIM(CNTRY)) IN ('DE') THEN 'Germany'
		WHEN UPPER(TRIM(CNTRY)) IN ('US', 'USA') THEN 'United States'
		WHEN UPPER(TRIM(CNTRY)) = ''
		OR UPPER(TRIM(CNTRY)) IS NULL THEN 'n/a'
		ELSE CNTRY
	END CNTRY
FROM
	BRONZE.ERP_LOC_A101;

SELECT
	*
FROM
	SILVER.ERP_LOC_A101;
----------INSERT --------------------------

TRUNCATE SILVER.ERP_LOC_A101;

INSERT INTO
	SILVER.ERP_LOC_A101 (CID, CNTRY)
SELECT
	REPLACE(CID, '-', '') CID,
	CASE
		WHEN UPPER(TRIM(CNTRY)) IN ('DE') THEN 'Germany'
		WHEN UPPER(TRIM(CNTRY)) IN ('US', 'USA') THEN 'United States'
		WHEN UPPER(TRIM(CNTRY)) = ''
		OR UPPER(TRIM(CNTRY)) IS NULL THEN 'n/a'
		ELSE CNTRY
	END CNTRY
FROM
	BRONZE.ERP_LOC_A101;

----------------------------------------------------

select * from bronze.erp_px_cat_g1v2;

select * from silver.erp_px_cat_g1v2;
---------------------INSERT--------------------
TRUNCATE SILVER.ERP_PX_CAT_G1V2;

INSERT INTO
	SILVER.ERP_PX_CAT_G1V2 (ID, CAT, SUBCAT, MAINTENANCE)
SELECT
	ID,
	CAT,
	SUBCAT,
	MAINTENANCE
FROM
	BRONZE.ERP_PX_CAT_G1V2;




