# PaySQL Roadmap

The modernization is organized in phases (see [docs/PROPOSAL.md](./docs/PROPOSAL.md) for the full
plan). Status as of the first release:

| Phase | Theme | Status |
|---|---|---|
| **0** | Scaffolding & cleanup (license, docs, discoverability, CI, remove legacy PDF/blog) | ✅ Done |
| **1** | Data model redesign (Flyway migrations, components, effective-dated salary, Docker, seed) | ✅ Done |
| **2** | Engine & packages (payroll lifecycle, tax/leave, audit triggers, utPLSQL tests) | ✅ Done |
| **3** | API & security (ORDS REST API, least-privilege roles) | ✅ Done |
| **4** | Polish & launch (docs site, architecture diagram, discoverability, first release) | ✅ Done |

## Beyond v1.0.0

- **Validation in CI** — Oracle Free service + Flyway migrate + utPLSQL on every PR.
- **Row-Level Security (VPD)** for true employee self-service at the database layer.
- **Base reference data** split into versioned migrations (currencies, standard components) so
  production installs work without the demo seed.
- **More payroll features** — loans/advance recovery in the engine, overtime, reimbursements,
  multi-currency pay runs, final settlement, proration for mid-period joiners/leavers.
- **Localization packs** — country-specific tax/statutory rule sets.
- **An optional APEX admin UI** on top of the same packages.

Contributions welcome — see [CONTRIBUTING.md](./CONTRIBUTING.md).
