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

-- Schema (versioned migrations, in order)
@@migrations/V1.0.0__reference_data_tables.sql
@@migrations/V1.1.0__core_hr.sql
@@migrations/V1.2.0__compensation.sql
@@migrations/V1.3.0__payroll.sql
@@migrations/V1.4.0__audit_logging.sql

-- Demo data (comment out for a production install).
-- Runs before the repeatable objects below, matching Flyway's ordering.
@@seed/V1.900.0__seed_demo_data.sql

-- Packages, triggers and views (repeatable; numeric prefixes = compile order)
@@migrations/repeatable/R__01_pkg_error.sql
@@migrations/repeatable/R__02_pkg_tax.sql
@@migrations/repeatable/R__03_pkg_leave.sql
@@migrations/repeatable/R__04_pkg_employee.sql
@@migrations/repeatable/R__05_pkg_payroll.sql
@@migrations/repeatable/R__06_audit_triggers.sql
@@migrations/repeatable/R__reporting_views.sql

PROMPT PaySQL schema installed.
