use role SYSADMIN;

create warehouse if not exists {{company_name}}_{{env_name}}_WH
WAREHOUSE_SIZE = XSMALL
AUTO_SUSPEND = 600--seconds
COMMENT = "Used for  {{company_name}} ELT";

-- ------------------------------------------------------------
-- Create environment Manager Roles
-- ------------------------------------------------------------

use role USERADMIN;
create or replace role {{company_name}}_{{env_name}}_ROLE_ADMIN;
create or replace role {{company_name}}_{{env_name}}_SYS_ADMIN;

-- ------------------------------------------------------------
-- Grant new roles to system roles to maintain the role hierarchy at Account level.
-- ------------------------------------------------------------

grant role {{company_name}}_{{env_name}}_ROLE_ADMIN to role USERADMIN;
grant role {{company_name}}_{{env_name}}_SYS_ADMIN to role SYSADMIN;

-- ------------------------------------------------------------
-- Grant  Privileges
-- ------------------------------------------------------------
use role SYSADMIN;
grant create database on account to role {{company_name}}_{{env_name}}_SYS_ADMIN;
grant usage on warehouse {{company_name}}_{{env_name}}_WH to role {{company_name}}_{{env_name}}_SYS_ADMIN;

use role USERADMIN;
grant create role on account to role {{company_name}}_{{env_name}}_ROLE_ADMIN;
grant create user on account to role {{company_name}}_{{env_name}}_ROLE_ADMIN;

-- ------------------------------------------------------------
-- Create Functional Roles and set ownership
-- ------------------------------------------------------------
use role {{company_name}}_{{env_name}}_ROLE_ADMIN;
create role if not exists {{company_name}}_{{env_name}}_DEVOPS;
create role if not exists {{company_name}}_{{env_name}}_ANALYST;
create role if not exists {{company_name}}_{{env_name}}_DEVELOPER;

-- ------------------------------------------------------------
-- Grant Functional Roles to ENV_SYS_ADMIN - to manage these
-- ------------------------------------------------------------
use role {{company_name}}_{{env_name}}_ROLE_ADMIN;

grant role {{company_name}}_{{env_name}}_DEVOPS      to role {{company_name}}_{{env_name}}_SYS_ADMIN;
grant role {{company_name}}_{{env_name}}_ANALYST	    to role {{company_name}}_{{env_name}}_SYS_ADMIN;
grant role {{company_name}}_{{env_name}}_DEVELOPER	    to role {{company_name}}_{{env_name}}_SYS_ADMIN;


-- ------------------------------------------------------------
-- Create Database
-- ------------------------------------------------------------
use role {{company_name}}_{{env_name}}_SYS_ADMIN;
create database if not exists {{company_name}}_{{db_region}}_{{env_name}};

-- *********************************************************************************************
-- The following section should be repeated for each schema.
-- *********************************************************************************************
use role {{company_name}}_{{env_name}}_SYS_ADMIN;
use database {{company_name}}_{{db_region}}_{{env_name}};
create schema if not exists {{schema_name}} with managed access;


-- ------------------------------------------------------------
-- Create Access Roles and set ownership
-- ------------------------------------------------------------

use role useradmin;

create or replace role {{company_name}}_{{env_name}}_{{schema_name}}_SR;
create or replace role {{company_name}}_{{env_name}}_{{schema_name}}_SRW;
create or replace role {{company_name}}_{{env_name}}_{{schema_name}}_SFULL;

grant ownership on role {{company_name}}_{{env_name}}_{{schema_name}}_SR         to role {{company_name}}_{{env_name}}_ROLE_ADMIN;
grant ownership on role {{company_name}}_{{env_name}}_{{schema_name}}_SRW        to role {{company_name}}_{{env_name}}_ROLE_ADMIN;
grant ownership on role {{company_name}}_{{env_name}}_{{schema_name}}_SFULL      to role {{company_name}}_{{env_name}}_ROLE_ADMIN;

-- ------------------------------------------------------------
-- Grant Access Roles to ENV_SYS_ADMIN - to manage these
-- ------------------------------------------------------------

use role {{company_name}}_{{env_name}}_ROLE_ADMIN;

--Create the Role hierarchy:

grant role {{company_name}}_{{env_name}}_{{schema_name}}_SR		to role {{company_name}}_{{env_name}}_SYS_ADMIN;
grant role {{company_name}}_{{env_name}}_{{schema_name}}_SRW		to role {{company_name}}_{{env_name}}_SYS_ADMIN;
grant role {{company_name}}_{{env_name}}_{{schema_name}}_SFULL	      to role {{company_name}}_{{env_name}}_SYS_ADMIN;


-- ------------------------------------------------------------
-- Grants from Schema/Database to Access Roles
-- ------------------------------------------------------------
use role {{company_name}}_{{env_name}}_SYS_ADMIN;

-- Database usage
grant usage on database {{company_name}}_{{db_region}}_{{env_name}} to role {{company_name}}_{{env_name}}_{{schema_name}}_SR;
grant usage on database {{company_name}}_{{db_region}}_{{env_name}} to role {{company_name}}_{{env_name}}_{{schema_name}}_SRW;
grant usage on database {{company_name}}_{{db_region}}_{{env_name}} to role {{company_name}}_{{env_name}}_{{schema_name}}_SFULL;

-- Schema usage
grant usage on schema MAIN           to role {{company_name}}_{{env_name}}_{{schema_name}}_SR;
grant usage on schema MAIN           to role {{company_name}}_{{env_name}}_{{schema_name}}_SRW;
grant all privileges on schema MAIN  to role {{company_name}}_{{env_name}}_{{schema_name}}_SFULL;


--Warehouse usage
grant usage on warehouse {{company_name}}_{{env_name}}_WH to role {{company_name}}_{{env_name}}_{{schema_name}}_SR;
grant usage on warehouse {{company_name}}_{{env_name}}_WH to role {{company_name}}_{{env_name}}_{{schema_name}}_SRW;
grant usage on warehouse {{company_name}}_{{env_name}}_WH to role {{company_name}}_{{env_name}}_{{schema_name}}_SFULL;


-- --------------------------------------------------------------------------------------
-- Current Grants
-- --------------------------------------------------------------------------------------
-- Read
grant select on all tables in               schema MAIN to role {{company_name}}_{{env_name}}_{{schema_name}}_SR;
grant select on all external tables in      schema MAIN to role {{company_name}}_{{env_name}}_{{schema_name}}_SR;
grant select on all views  in               schema MAIN to role {{company_name}}_{{env_name}}_{{schema_name}}_SR;
grant usage, read on all stages in          schema MAIN to role {{company_name}}_{{env_name}}_{{schema_name}}_SR;
grant usage on all file formats in          schema MAIN to role {{company_name}}_{{env_name}}_{{schema_name}}_SR;
grant select on all streams in              schema MAIN to role {{company_name}}_{{env_name}}_{{schema_name}}_SR;
grant usage on all procedures in            schema MAIN to role {{company_name}}_{{env_name}}_{{schema_name}}_SR;
grant usage on all functions in             schema MAIN to role {{company_name}}_{{env_name}}_{{schema_name}}_SR;
grant select on all materialized views in   schema MAIN to role {{company_name}}_{{env_name}}_{{schema_name}}_SR;

-- Read/Write
grant insert, update, delete, truncate, references on all tables in schema MAIN to role {{company_name}}_{{env_name}}_{{schema_name}}_SRW;
grant insert, update, delete, references on all external tables in schema MAIN to role {{company_name}}_{{env_name}}_{{schema_name}}_SRW;
grant write on all stages in   schema MAIN to role {{company_name}}_{{env_name}}_{{schema_name}}_SRW;
grant monitor, operate on all tasks in  schema MAIN to role {{company_name}}_{{env_name}}_{{schema_name}}_SRW;

-- Ownership (Grant full control over a table)

grant ownership on all tables in schema MAIN to role {{company_name}}_{{env_name}}_{{schema_name}}_SFULL;
grant ownership on all external tables in schema MAIN to role {{company_name}}_{{env_name}}_{{schema_name}}_SFULL;
grant ownership on all views  in schema MAIN to role {{company_name}}_{{env_name}}_{{schema_name}}_SFULL;
grant ownership on all stages in schema MAIN to role {{company_name}}_{{env_name}}_{{schema_name}}_SFULL;
grant ownership on all file formats in schema MAIN to role {{company_name}}_{{env_name}}_{{schema_name}}_SFULL;
grant ownership on all streams in schema MAIN to role {{company_name}}_{{env_name}}_{{schema_name}}_SFULL;
grant ownership on all procedures in schema MAIN to role {{company_name}}_{{env_name}}_{{schema_name}}_SFULL;
grant ownership on all functions in  schema MAIN to role {{company_name}}_{{env_name}}_{{schema_name}}_SFULL;
grant ownership on all materialized views in schema MAIN to role {{company_name}}_{{env_name}}_{{schema_name}}_SFULL;
grant ownership on all sequences in schema MAIN to role {{company_name}}_{{env_name}}_{{schema_name}}_SFULL;
grant ownership on all tasks in schema MAIN to role {{company_name}}_{{env_name}}_{{schema_name}}_SFULL;

-- --------------------------------------------------------------------------------------
-- Future Grants
-- --------------------------------------------------------------------------------------

-- Read
grant select on future tables in 			schema MAIN to role {{company_name}}_{{env_name}}_{{schema_name}}_SR;
grant select on future external tables in 	schema MAIN to role {{company_name}}_{{env_name}}_{{schema_name}}_SR;
grant select on future views  in 			schema MAIN to role {{company_name}}_{{env_name}}_{{schema_name}}_SR;
grant usage, read on future stages in 		schema MAIN to role {{company_name}}_{{env_name}}_{{schema_name}}_SR;
grant usage on future file formats in 		schema MAIN to role {{company_name}}_{{env_name}}_{{schema_name}}_SR;
grant select on future streams in 			schema MAIN to role {{company_name}}_{{env_name}}_{{schema_name}}_SR;
grant usage on future procedures in 		schema MAIN to role {{company_name}}_{{env_name}}_{{schema_name}}_SR;
grant usage on future functions in 		schema MAIN to role {{company_name}}_{{env_name}}_{{schema_name}}_SR;
grant select on future materialized views in 	schema MAIN to role {{company_name}}_{{env_name}}_{{schema_name}}_SR;

-- Read/Write
grant insert, update, delete, truncate, referenceson future tables in schema MAIN to role {{company_name}}_{{env_name}}_{{schema_name}}_SRW;
grant insert, update, delete, references on future external tables in schema MAIN to role {{company_name}}_{{env_name}}_{{schema_name}}_SRW;
grant read, write on future stages in    schema MAIN to role {{company_name}}_{{env_name}}_{{schema_name}}_SRW;
grant usage on future sequences in schema MAIN to role {{company_name}}_{{env_name}}_{{schema_name}}_SRW;
grant monitor, operate on future tasks in 	schema MAIN to role {{company_name}}_{{env_name}}_{{schema_name}}_SRW;

-- Full
grant ownership on future tables in 		schema MAIN to role {{company_name}}_{{env_name}}_{{schema_name}}_SFULL;
grant ownership on future external tables in 	schema MAIN to role {{company_name}}_{{env_name}}_{{schema_name}}_SFULL;
grant ownership on future views  in 		schema MAIN to role {{company_name}}_{{env_name}}_{{schema_name}}_SFULL;
grant ownership on future stages in 		schema MAIN to role {{company_name}}_{{env_name}}_{{schema_name}}_SFULL;
grant ownership on future file formats in 	schema MAIN to role {{company_name}}_{{env_name}}_{{schema_name}}_SFULL;
grant ownership on future streams in 		schema MAIN to role {{company_name}}_{{env_name}}_{{schema_name}}_SFULL;
grant ownership on future procedures in 	schema MAIN to role {{company_name}}_{{env_name}}_{{schema_name}}_SFULL;
grant ownership on future functions in 		schema MAIN to role {{company_name}}_{{env_name}}_{{schema_name}}_SFULL;
grant ownership on future materialized views in schema MAIN to role {{company_name}}_{{env_name}}_{{schema_name}}_SFULL;
grant ownership on future sequences in 		schema MAIN to role {{company_name}}_{{env_name}}_{{schema_name}}_SFULL;
grant ownership on future tasks in 		schema MAIN to role {{company_name}}_{{env_name}}_{{schema_name}}_SFULL;
grant ownership on future pipes in 		schema MAIN to role {{company_name}}_{{env_name}}_{{schema_name}}_SFULL;

-- ------------------------------------------------------------
-- Grant to Functional Roles
-- ------------------------------------------------------------
use role {{company_name}}_{{env_name}}_ROLE_ADMIN;

grant role {{company_name}}_{{env_name}}_{{schema_name}}_SR to 		role {{company_name}}_{{env_name}}_ANALYST;
grant role {{company_name}}_{{env_name}}_{{schema_name}}_SRW to 		role {{company_name}}_{{env_name}}_DEVELOPER;
grant role {{company_name}}_{{env_name}}_{{schema_name}}_SFULL to 	role {{company_name}}_{{env_name}}_DEVOPS;

