/*
=============================================================
Create Tables for Bronze
=============================================================
Script Purpose:
Creating the TABLES
*/

---------- CRM Customer info table ------------------
CREATE TABLE IF NOT EXISTS bronze.crm_cust_info(
cst_id INT,
cst_key VARCHAR(50),
cst_firstname VARCHAR(100),
cst_lastname VARCHAR(100),
cst_marital_status VARCHAR(5),
cst_gndr VARCHAR(5),
cst_create_date DATE
);

---------------- CRM Product Info table------------------
CREATE TABLE IF NOT EXISTS bronze.crm_prd_info(
prd_id INT,
prd_key VARCHAR(50),
prd_nm VARCHAR(100),
prd_cost NUMERIC,
prd_line VARCHAR(5),
prd_start_dt DATE,
prd_end_dt DATE
);

------------CRM Sales Table ----------------------------
CREATE TABLE IF NOT EXISTS bronze.crm_sales_details(
sls_ord_num VARCHAR(50),
sls_prd_key VARCHAR(50),
sls_cust_id INT,
sls_order_dt INT,
sls_ship_dt INT,
sls_due_dt INT,
sls_sales INT,
sls_quantity INT,
sls_price INT
);

--------------ERP Customer table -----------------------
CREATE TABLE IF NOT EXISTS bronze.erp_cust_az12(
CID VARCHAR(50),
BDATE DATE,
GEN VARCHAR(10)
);

--------------ERP Location table ----------------------- 
CREATE TABLE IF NOT EXISTS bronze.erp_loc_a101(
CID VARCHAR(50),
CNTRY VARCHAR(50)
);

---------------ERP Category table ----------------------
CREATE TABLE IF NOT EXISTS bronze.erp_px_cat_g1v2(
ID VARCHAR(10),
CAT VARCHAR(50),
SUBCAT VARCHAR(50),
MAINTENANCE VARCHAR(50)
);
