# Getting Started

!!! note "Coming in Phase 1–3"
    One-command setup (Docker Compose with Oracle Free + ORDS + Flyway migrations) and REST
    endpoints are being built. This page will carry the full install and quickstart once Phase 1
    lands. Track progress in the [roadmap](./PROPOSAL.md).

## Planned quickstart (target)

```bash
git clone https://github.com/nowshad7/SalaryManagementSystem.git
cd SalaryManagementSystem
docker compose up        # Oracle Free + ORDS + auto-applied migrations + seed data
```

Then explore the REST API (see [API](./api.md)).

## Legacy scripts

The original university coursework is preserved under `SalaryManagement/` and at the
`v0-university` git tag. It is for historical reference only and should not be deployed.
