# Deploy to QuantCDN Action

This GitHub Action deploys your static site and/or functions to QuantCDN using the Quant CLI v6.

## Usage

### Deploy Assets
```yaml
- uses: quantcdn/action-deploy@v6
  with:
    customer: your-customer-id
    project: your-project-name
    token: ${{ secrets.QUANT_TOKEN }}
    dir: build
```

### Deploy Functions
```yaml
- uses: quantcdn/action-deploy@v6
  with:
    customer: your-customer-id
    project: your-project-name
    token: ${{ secrets.QUANT_TOKEN }}
    functions: './functions.json'
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
| `api-token` | Project-scoped portal API token for rules (`QUANT_API_TOKEN`); required with `rules` | No | - |
| `api-base-url` | Portal API base URL including `/api/v2` (`QUANT_BASE_URL`); required with `rules` | No | - |
| `rules-force` | Overwrite managed rules changed outside code (never takes over another rule) | No | `false` |

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
        uses: quantcdn/action-deploy@v6
        with:
          customer: your-customer-id
          project: your-project-name
          token: ${{ secrets.QUANT_TOKEN }}
          dir: build
```

### Functions Deployment

Create a functions configuration file (e.g., `functions.json`):
```json
[
  {
    "type": "auth",
    "path": "./functions/auth.js",
    "description": "Authentication function",
    "uuid": "11111111-1111-4111-a111-111111111111"
  },
  {
    "type": "filter",
    "path": "./functions/filter.js",
    "description": "Filter function",
    "uuid": "22222222-2222-4222-a222-222222222222"
  },
  {
    "type": "function",
    "path": "./functions/function.js",
    "description": "Edge function",
    "uuid": "33333333-3333-4333-a333-333333333333"
  }
]
```

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
        uses: quantcdn/action-deploy@v6
        with:
          customer: your-customer-id
          project: your-project-name
          token: ${{ secrets.QUANT_TOKEN }}
          functions: './functions.json'
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
        uses: quantcdn/action-deploy@v6
        with:
          customer: your-customer-id
          project: your-project-name
          token: ${{ secrets.QUANT_TOKEN }}
          dir: build
          functions: './functions.json'
```

## Notes

- This action uses Quant CLI v6
- For search functionality, please use the dedicated search action
- Make sure your `QUANT_TOKEN` is stored securely in your repository secrets

## Edge rules

Provide `rules: edge-rules.json`, `functions: edge-functions.json`,
`api-token: ${{ secrets.QUANT_API_TOKEN }}` and
`api-base-url: ${{ vars.QUANT_BASE_URL }}` alongside the normal deployment inputs.
The Quant portal injects the project-scoped API secret and the environment-specific
portal `/api/v2` URL when a static or Studio template includes `edge-rules.json`.
Uploads continue to use the separate `token` input. Never substitute the content
write token for `api-token`.

The action runs in this order:

1. **Validate rules inputs.** `rules`, `functions`, `customer` and `project` must be
   plain paths or slugs (no spaces, quotes or leading `-`), and `api-token` and
   `api-base-url` must be set.
2. **Validate rules access** with a dry run: token scope, manifest and drift are
   checked before anything is uploaded.
3. Deploy functions, then assets.
4. **Deploy rules.**

Rules deployed this way are managed in code and are read-only in the dashboard.
If one was changed outside code anyway, step 2 fails before any upload and the
log lists the changed fields. Set `rules-force: true` for one run to overwrite
those rules with the manifest; it never takes over a rule the manifest did not
create.

If step 4 fails after the uploads (for example a transient portal error), the new
assets are live with the previous rules. Re-run the workflow: deploys are
idempotent, so the rules step converges and unchanged assets are skipped.

## License

MIT License
