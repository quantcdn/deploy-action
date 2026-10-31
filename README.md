# Deploy to QuantCDN Action

This GitHub Action deploys your static site and/or functions to QuantCDN using the Quant CLI v7.

## Usage

### Deploy Assets
```yaml
- uses: quantcdn/deploy-action@v7
  with:
    customer: your-customer-id
    project: your-project-name
    token: ${{ secrets.QUANT_TOKEN }}
    dir: build
```

### Deploy Functions
```yaml
- uses: quantcdn/deploy-action@v7
  with:
    customer: your-customer-id
    project: your-project-name
    token: ${{ secrets.QUANT_TOKEN }}
    functions: quant/edge-functions.json
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `customer` | Your QuantCDN customer account name | Yes | - |
| `project` | Your QuantCDN project name | Yes | - |
| `token` | Your content write token (uploads only; never used for rules) | Yes | - |
| `dir` | The directory to deploy | No | - |
| `functions` | Path to JSON file containing functions configuration | No | - |
| `skip-unpublish` | Skip automatic unpublishing of assets | No | `false` |
| `skip-unpublish-regex` | Skip automatic unpublishing of assets matching regex pattern | No | - |
| `skip-purge` | Skip automatic purge of cached assets in CDN | No | `false` |
| `force` | Force the deployment of assets (skip md5 check) | No | `false` |
| `chunk-size` | Alter the concurrency of deployment | No | `10` |
| `endpoint` | Specify the QuantCDN API endpoint | No | `https://api.quantcdn.io/v1` |
| `revision-log` | Specify a location for the local revision log file | No | `false` |
| `enable-index-html` | Enable index.html creation in Quant | No | `false` |
| `rules` | Path to an edge rules manifest (`edge-rules.json`) | No | - |
| `api-token` | Project-scoped portal API token (`QUANT_API_TOKEN`); required with `rules` or `kv-indexes` | No | - |
| `api-base-url` | Portal API base URL including `/api/v2` (`QUANT_BASE_URL`); required with `rules` or `kv-indexes` | No | - |
| `rules-force` | Overwrite managed rules changed outside code (never takes over another rule) | No | `false` |
| `kv-indexes` | Path to `quant/meta.json`; declares its KV indexes with `api-token` and `api-base-url` | No | - |

## Example Workflows

### Basic Asset Deployment

```yaml
name: Deploy to QuantCDN
on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6
      
      - name: Build site
        run: |
          npm install
          npm run build
          
      - name: Deploy to QuantCDN
        uses: quantcdn/deploy-action@v7
        with:
          customer: your-customer-id
          project: your-project-name
          token: ${{ secrets.QUANT_TOKEN }}
          dir: build
```

### Functions Deployment

Declare your functions in `quant/edge-functions.json`. Every entry needs a
`uuid`: it is the function's identity, so keep it in the repository and never
change it. Create entries with `quant functions-add`, which writes a new UUID:

```sh
npx @quantcdn/quant-cli@7 functions-add quant/edge-functions.json quant/edge-functions/api.js --description "API" --id my-api
```

```json
[
  {
    "type": "auth",
    "path": "quant/edge-functions/auth.js",
    "description": "Authentication function",
    "id": "gate",
    "uuid": "11111111-1111-4111-a111-111111111111"
  },
  {
    "type": "function",
    "path": "quant/edge-functions/api.js",
    "description": "Edge function",
    "id": "my-api",
    "uuid": "33333333-3333-4333-a333-333333333333"
  }
]
```

`type` is `function`, `edge`, `auth` or `filter`; `id` is optional (a lowercase
slug that rules use as `function_ref`). The whole manifest is checked before the
first upload, and a manifest entry without a `uuid` fails the step.

Then deploy using:
```yaml
name: Deploy Functions to QuantCDN
on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6
      
      - name: Deploy Functions
        uses: quantcdn/deploy-action@v7
        with:
          customer: your-customer-id
          project: your-project-name
          token: ${{ secrets.QUANT_TOKEN }}
          functions: quant/edge-functions.json
```

### Combined Deployment

```yaml
name: Deploy Everything to QuantCDN
on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6
      
      - name: Build site
        run: |
          npm install
          npm run build
          
      - name: Deploy to QuantCDN
        uses: quantcdn/deploy-action@v7
        with:
          customer: your-customer-id
          project: your-project-name
          token: ${{ secrets.QUANT_TOKEN }}
          dir: build
          functions: quant/edge-functions.json
```

## Notes

- This action uses Quant CLI v7 (`quantcdn/cli:7.2.0@sha256:efc4cacf…`, pinned by digest)
- For search functionality, please use the dedicated search action
- Make sure your `QUANT_TOKEN` is stored securely in your repository secrets

## Edge rules

Provide `rules: quant/edge-rules.json`, `functions: quant/edge-functions.json`,
`api-token: ${{ secrets.QUANT_API_TOKEN }}` and
`api-base-url: ${{ vars.QUANT_BASE_URL }}` alongside the normal deployment inputs.
The Quant portal injects the project-scoped API secret and the environment-specific
portal `/api/v2` URL when a static or Studio template includes `quant/edge-rules.json`.
Uploads continue to use the separate `token` input. Never substitute the content
write token for `api-token`.

The action runs in this order:

1. **Validate rules inputs.** `rules`, `functions`, `customer` and `project` must be
   plain paths or slugs (no spaces, quotes or leading `-`), and `api-token` and
   `api-base-url` must be set.
2. **Validate rules access** with a dry run: token scope, manifest and drift are
   checked before anything is uploaded.
3. **Declare KV indexes**, when `kv-indexes` is set (see [KV indexes](#kv-indexes)).
4. Deploy functions, then assets.
5. **Deploy rules.**

Rules deployed this way are managed in code and are read-only in the dashboard.
If one was changed outside code anyway, step 2 fails before any upload and the
log lists the changed fields. Set `rules-force: true` for one run to overwrite
those rules with the manifest; it never takes over a rule the manifest did not
create.

If step 5 fails after the uploads (for example a transient portal error), the new
assets are live with the previous rules. Re-run the workflow: deploys are
idempotent, so the rules step converges and unchanged assets are skipped.

## KV indexes

Provide `kv-indexes: quant/meta.json` with `api-token` and `api-base-url` to
declare the KV indexes of the stores in `quant/meta.json` before the functions
deploy:

```yaml
- uses: quantcdn/deploy-action@v7
  with:
    customer: your-customer-id
    project: your-project-name
    token: ${{ secrets.QUANT_TOKEN }}
    dir: dist
    functions: quant/edge-functions.json
    kv-indexes: quant/meta.json
    api-token: ${{ secrets.QUANT_API_TOKEN }}
    api-base-url: ${{ vars.QUANT_BASE_URL }}
```

The step runs `quant kv-indexes`. It declares each index that the store does not
have yet, and it never drops or changes an index. An index with a different
definition from `meta.json` fails the step. The `api-token` needs the `kv:read`
and `kv:write` scopes. If it does not have them, the step prints a warning and
continues, and the indexes are not declared.

## License

MIT License

## Upgrading from v6 to v7

v7 runs Quant CLI 7 (7.1.1 from deploy-action v7.1.0). The only breaking change is for edge functions:

- Every entry in the `functions` manifest needs an explicit `uuid`. v6 derived
  one from `id` when it was missing. v7 fails the "Deploy Functions" step (or the
  rules dry run, when `rules` is set) before anything is uploaded, and names each
  entry. To keep a function v6 deployed by `id`, copy its UUID from the dashboard
  (Compute > Edge Functions) into the entry, or see the Quant CLI README for a
  command that prints the UUID v6 derived.
- The manifest is checked against the full schema (lowercase `type`, non-blank
  `description`, unique `uuid` and `id`).

`@v6` is not changed and keeps CLI 6.3.0.

## Runtime security

The action pins the maintained Quant CLI 7.2.0 multiarchitecture image by digest.
It includes Node 22.23.4, with the CVE-2026-111497 Brotli decoder fix.
Update the action reference to receive this image; historical pinned action
SHAs and container digests retain their original contents.
