# biject GitHub Actions

The GitHub Actions for [biject](https://biject-demo.fly.dev), the API migration platform:
`samirovsky/biject-actions/<name>@v<version>`. Each installs the `api-migrations` CLI
release binary attached to this repository's release of that version (`install-cli.sh`).

| Action | Where | What it does | Needs |
|--------|-------|--------------|-------|
| `verify` | client CI, on `pull_request` | On biject's migration PRs (`biject/migrate/…`): checks out the PR head, re-checks trust against your pinned policy, checks the PR is exactly the verified patch (and reproduces a deterministic one), and runs your tests against the contract mock. Other PRs are skipped. | `id-token: write`; your build toolchain set up before it |
| `migrate` | client CI, written by biject | Only in the workflow biject pushes on a `biject/run/<run>` branch when migrations run in your GitHub Actions: checks trust, applies the signed migration, runs your tests against the contract mock, and reports the patch and the evidence. Your code stays in the job. | `id-token: write` (the generated workflow sets it) |
| `extract` | provider CI, on `pull_request` and pushes | Uploads generated (`generate:`) or deployed (`staging_url:`) specs for the commit or PR. Committed specs need nothing. | `id-token: write`; your generator's toolchain |
| `sign` | provider CI | `what: statements` after a signing PR merges (signs only the statements the push added); `what: lock` on a release (signs the lock release). Keyless, with the workflow's identity, which your trust policy must name. | `id-token: write` |

A client usually adds nothing by hand: biject's setup PR adds the `verify` workflow, and
biject writes the `migrate` workflow on each run branch.

```yaml
# .github/workflows/biject.yml (provider)
permissions:
  contents: read
  id-token: write
jobs:
  specs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: samirovsky/biject-actions/extract@v0.1.0
        with:
          server: https://biject-demo.fly.dev
```

This repository is published from the `actions/` directory of biject's source
(`scripts/push-actions.sh`); **Release** (Actions → Release → Run workflow) tags a version
and attaches the CLI binaries for Linux (x86_64, arm64) and macOS (arm64, x86_64).
