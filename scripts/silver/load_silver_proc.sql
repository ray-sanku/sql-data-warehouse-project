/*
=============================================================
Silver Procedure with load data into Tables
=============================================================
Script Purpose:
Stored procedure to load data into Tables

-------------------------Execution--------------------------
call silver.load_silver();
*/
CREATE OR REPLACE PROCEDURE SILVER.LOAD_SILVER () LANGUAGE PLPGSQL AS $$
DECLARE
	st_time TIMESTAMP;
	ed_time TIMESTAMP;
	time_diff TIMESTAMP;
begin
	BEGIN
		raise info '---------- Starting loading process ------------';
		raise info 'Truncating cust_info table! - SILVER.CRM_CUST_INFO';

		SELECT NOW() INTO st_time;

		TRUNCATE SILVER.CRM_CUST_INFO;
		raise info 'Truncate completed, starting INSERT....';
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
	RAISE INFO 'Insert complete for table - CRM_CUST_INFO Table.';
	SELECT NOW() INTO ed_time;
	
	--time_diff := ed_time - st_time;
	RAISE INFO 'Execution time: %', EXTRACT(EPOCH FROM (ed_time::TIMESTAMP - st_time::TIMESTAMP));

	RAISE INFO 'Truncating CRM_PRD_INFO table!';

	TRUNCATE SILVER.CRM_PRD_INFO;
	RAISE INFO 'Truncate completed, starting INSERT....';

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
	RAISE INFO 'Insert completed for table - SILVER.CRM_PRD_INFO';
	
	RAISE INFO 'Truncating CRM_SALES_DETAILS table!';

	TRUNCATE SILVER.CRM_SALES_DETAILS;
	RAISE INFO 'Truncate completed, starting INSERT....';
	
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
	RAISE INFO 'Insert completed for table - SILVER.CRM_SALES_DETAILS';

	RAISE INFO 'Truncating ERP_CUST_AZ12 table!';
	TRUNCATE SILVER.ERP_CUST_AZ12;
	
	RAISE INFO 'Truncate completed, starting INSERT....';
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
	RAISE INFO 'Insert completed for table - SILVER.ERP_CUST_AZ12';

	RAISE INFO 'Truncating ERP_LOC_A101 table!';
	TRUNCATE SILVER.ERP_LOC_A101;
	
	RAISE INFO 'Truncate completed, starting INSERT....';
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
	END as CNTRY
FROM
	BRONZE.ERP_LOC_A101;
	RAISE INFO 'Insert completed for table - SILVER.ERP_LOC_A101';

	RAISE INFO 'Truncating ERP_PX_CAT_G1V2 table!';
	TRUNCATE SILVER.ERP_PX_CAT_G1V2;
	
	RAISE INFO 'Truncate completed, starting INSERT....';
	INSERT INTO
	SILVER.ERP_PX_CAT_G1V2 (ID, CAT, SUBCAT, MAINTENANCE)
SELECT
	ID,
	CAT,
	SUBCAT,
	MAINTENANCE
FROM
	BRONZE.ERP_PX_CAT_G1V2;
	RAISE INFO 'Insert completed for table - SILVER.ERP_PX_CAT_G1V2';

	EXCEPTION
		WHEN OTHERS THEN
			RAISE NOTICE 'An unknown error occurred: %', SQLERRM;
	END;

End; $$;