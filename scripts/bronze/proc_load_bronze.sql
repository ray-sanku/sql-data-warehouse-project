/*
=============================================================
Bronze Procedure with load data into Tables
=============================================================
Script Purpose:
Stored procedure to load data into Tables
*/

CREATE OR REPLACE PROCEDURE bronze.load_bronze()
language plpgsql
as $$
BEGIN
	BEGIN
		RAISE INFO '---------------Start of the loading process---------------------';
		RAISE INFO '---------------';
		
		RAISE INFO '------------Loading CRM Customer Info-----------------';
		TRUNCATE bronze.crm_cust_info;
		
		COPY bronze.crm_cust_info FROM 'D:\Learnings\Data Warehouse\postgres_warehouse\datasets\source_crm\cust_info.csv'
		WITH (FORMAT CSV, HEADER, DELIMITER ',');
		RAISE INFO '------------Loading completed----------------------';
		
		RAISE INFO '--------------- Loading CRM Product info table ---------------'; 
		TRUNCATE bronze.crm_prd_info;
		
		COPY bronze.crm_prd_info FROM 'D:\Learnings\Data Warehouse\postgres_warehouse\datasets\source_crm\prd_info.csv'
		WITH (FORMAT CSV, HEADER, DELIMITER ',');
		RAISE INFO '------------Loading completed----------------------';
		
		
		RAISE INFO '--------------- Loading CRM Loading Sales details table -----------'; 
		TRUNCATE bronze.crm_sales_details;
		
		COPY bronze.crm_sales_details FROM 'D:\Learnings\Data Warehouse\postgres_warehouse\datasets\source_crm\sales_details.csv'
		WITH (FORMAT CSV, HEADER, DELIMITER ',');
		RAISE INFO '------------Loading completed----------------------';
		
		RAISE INFO '--------------------------------------ERP Source System Load -------------------------------';
		
		RAISE INFO '--------------- Loading ERP Customer info table---------'; 
		TRUNCATE bronze.erp_cust_az12;
		
		COPY bronze.erp_cust_az12 FROM 'D:\Learnings\Data Warehouse\postgres_warehouse\datasets\source_erp\CUST_AZ12.csv'
		WITH (FORMAT CSV, HEADER, DELIMITER ',');
		RAISE INFO '------------Loading completed----------------------';
		
		RAISE INFO '--------------- Loading ERP Location info table ---------'; 
		TRUNCATE bronze.erp_loc_a101;
		
		COPY bronze.erp_loc_a101 FROM 'D:\Learnings\Data Warehouse\postgres_warehouse\datasets\source_erp\LOC_A101.csv'
		WITH (FORMAT CSV, HEADER, DELIMITER ',');
		RAISE INFO '------------Loading completed----------------------';
		
		RAISE INFO '--------------- Loading ERP Category info table ----------'; 
		TRUNCATE bronze.erp_px_cat_g1v2;
		
		COPY bronze.erp_px_cat_g1v2 FROM 'D:\Learnings\Data Warehouse\postgres_warehouse\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH (FORMAT CSV, HEADER, DELIMITER ',');
		RAISE INFO '------------Loading completed----------------------';
	
	EXCEPTION
		WHEN OTHERS THEN
			RAISE NOTICE 'An unknown error occurred: %', SQLERRM;
	
	END;

END; $$;
