# PaySQL tests

Unit tests use [utPLSQL v3](https://www.utplsql.org/).

## Prerequisites

1. A PaySQL database with migrations **and** the demo seed data applied
   (`docker compose up`, or Flyway with the `db/seed` location).
2. utPLSQL v3 installed in the database and granted to the `paysql` user.

## Install the test package

```sql
-- connect as paysql
@tests/ut_payroll.pkg.sql
```

## Run

```sql
SET SERVEROUTPUT ON
EXEC ut.run('ut_payroll');
```

Or with the [utPLSQL-cli](https://github.com/utPLSQL/utPLSQL-cli):

```bash
utplsql run paysql/your-password@//localhost:1521/FREEPDB1 -p=ut_payroll -f=ut_documentation_reporter
```

Each test runs inside an automatic savepoint and rolls back afterwards, so the
seed data is left untouched.

> CI note: wiring utPLSQL into GitHub Actions (Oracle Free service + utPLSQL-cli)
> is tracked for the CI hardening step. The workflow currently validates
> migrations statically.
