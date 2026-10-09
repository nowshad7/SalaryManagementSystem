# Contributing to PaySQL

Thanks for your interest in improving PaySQL! This project is in active modernization
(see the [roadmap](./docs/PROPOSAL.md)), so there's plenty to do.

## Ways to contribute

- 🐛 Report bugs and 💡 suggest features via [Issues](../../issues).
- 🧱 Improve the data model, PL/SQL packages, or the payroll engine.
- 🧪 Add [utPLSQL](https://www.utplsql.org/) tests.
- 📚 Improve documentation under `docs/`.
- 🌍 Add country-specific tax/statutory rule sets.

## Development workflow

1. Fork and create a feature branch (`feat/short-description`).
2. Keep changes focused; one logical change per pull request.
3. Follow the conventions below.
4. Open a pull request using the template; link the issue it closes.

## Conventions

- **Database objects:** `snake_case`, singular table names, no abbreviations with typos
  (e.g. `transaction`, not `transection`). Money as `NUMBER(p,s)`, dates as `DATE`/`TIMESTAMP`.
- **Packages:** one domain per package (`pkg_employee`, `pkg_payroll`, ...), spec and body in
  separate files under `db/packages/`.
- **Migrations:** every schema change is a Flyway migration under `db/migrations/`
  (`V<version>__description.sql`); package bodies are repeatable migrations (`R__...`).
- **Errors:** raise typed exceptions and log to the error table — never swallow with a generic
  message.
- **Commits:** [Conventional Commits](https://www.conventionalcommits.org/)
  (`feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`).

## Releasing (maintainers)

1. Update `CHANGELOG.md`: move `Unreleased` items under a new `## [x.y.z] - YYYY-MM-DD` heading.
2. Bump `version` / `date-released` in `CITATION.cff` and the release badge in `README.md`.
3. Tag and push: `git tag -a vX.Y.Z -m "PaySQL vX.Y.Z" && git push origin vX.Y.Z`.
4. Create a GitHub Release from the tag, pasting the changelog section as the notes.

## Code of Conduct

Participation is governed by our [Code of Conduct](./CODE_OF_CONDUCT.md).
