--------------------------------------------------------------------------------
-- PaySQL :: Manual installer (SQL*Plus / SQLcl)
--
-- For users who prefer not to use Flyway. Connect as the PAYSQL application user
-- and run:
--     @db/install.sql
--
-- Applies the same migrations Flyway would, in order, then the demo seed data.
-- Remove the seed line for a clean (production) install.
--------------------------------------------------------------------------------
SET DEFINE OFF
SET ECHO ON

@@migrations/V1.0.0__reference_data_tables.sql
@@migrations/V1.1.0__core_hr.sql
@@migrations/V1.2.0__compensation.sql
@@migrations/V1.3.0__payroll.sql
@@migrations/V1.4.0__audit_logging.sql
@@migrations/repeatable/R__reporting_views.sql

-- Demo data (comment out for a production install):
@@seed/V1.900.0__seed_demo_data.sql

PROMPT PaySQL schema installed.
