# API

PaySQL exposes a REST API via **Oracle REST Data Services (ORDS)**. The definitions live under
[`api/`](../api) and call the Phase 2 PL/SQL engine directly, so REST and SQL share the same
business rules. Full setup is in [`api/README.md`](../api/README.md).

## Base URL

```
https://<host>/ords/paysql/v1/
```

## Endpoints

| Method | Path | Purpose |
|---|---|---|
| `GET`  | `/employees` | List employees |
| `POST` | `/employees` | Create an employee |
| `GET`  | `/employees/{id}` | Employee detail |
| `GET`  | `/employees/{id}/payslips` | Payslip history |
| `GET`  | `/payslips/{id}` | Payslip line items |
| `GET`  | `/payruns` | All pay runs (register summary) |
| `POST` | `/payruns` | Calculate a run for a period |
| `POST` | `/payruns/{id}/approve` | Approve a run |
| `POST` | `/payruns/{id}/post` | Post a run |
| `POST` | `/payruns/{id}/pay` | Pay a run from a fund |
| `POST` | `/payruns/{id}/close` | Close a run |
| `GET`  | `/payruns/{id}/register` | Register for one run |

## Example: run payroll end-to-end

```bash
BASE=https://localhost:8080/ords/paysql/v1
AUTH="Authorization: Bearer $TOKEN"

# 1. Calculate
RUN=$(curl -s -H "$AUTH" -H 'Content-Type: application/json' \
     -d '{"period_code":"2026-01"}' $BASE/payruns | jq .pay_run_id)

# 2-5. Approve -> Post -> Pay -> Close
curl -s -H "$AUTH" -H 'Content-Type: application/json' -d '{"approved_by":"alice"}' $BASE/payruns/$RUN/approve
curl -s -H "$AUTH" -d '' $BASE/payruns/$RUN/post
curl -s -H "$AUTH" -H 'Content-Type: application/json' -d '{"fund_code":"MAIN"}' $BASE/payruns/$RUN/pay
curl -s -H "$AUTH" -d '' $BASE/payruns/$RUN/close

# Register
curl -s -H "$AUTH" $BASE/payruns/$RUN/register
```

More ready-to-run requests: [`examples/rest-api.http`](../examples/rest-api.http).

## Authentication & roles

The API is protected by ORDS roles mapped to the four PaySQL personas. See
[Roles & Security](./roles-and-security.md) for the model and OAuth2 client setup.
