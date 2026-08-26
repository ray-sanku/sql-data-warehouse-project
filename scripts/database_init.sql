/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
Here, first we are checking the postgresql database version.
-- Then creating a new database after checking the no of databases exists in the system
Additionally, the script sets up three schemas 
within the database: 'bronze', 'silver', and 'gold'.
*/
select version();

select * from pg_database;

------ Creating a new database
CREATE DATABASE psqlDataWarehouse;

---- Creating schemas in new database

CREATE SCHEMA bronze;
CREATE SCHEMA silver;
CREATE SCHEMA gold;
