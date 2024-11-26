# Deploy to QuantCDN Action

This GitHub Action deploys your static site and/or functions to QuantCDN using the Quant CLI v5.

## Usage

### Deploy Assets
```yaml
- uses: quantcdn/action-deploy@v5
  with:
    customer: your-customer-id
    project: your-project-name
    token: ${{ secrets.QUANT_TOKEN }}
    dir: build
```

### Deploy Functions
```yaml
- uses: quantcdn/action-deploy@v5
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
| `token` | Your QuantCDN API token | Yes | - |
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
      - uses: actions/checkout@v4
      
      - name: Build site
        run: |
          npm install
          npm run build
          
      - name: Deploy to QuantCDN
        uses: quantcdn/action-deploy@v5
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
      - uses: actions/checkout@v4
      
      - name: Deploy Functions
        uses: quantcdn/action-deploy@v5
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
      - uses: actions/checkout@v4
      
      - name: Build site
        run: |
          npm install
          npm run build
          
      - name: Deploy to QuantCDN
        uses: quantcdn/action-deploy@v5
        with:
          customer: your-customer-id
          project: your-project-name
          token: ${{ secrets.QUANT_TOKEN }}
          dir: build
          functions: './functions.json'
```

## Notes

- This action uses Quant CLI v5
- For search functionality, please use the dedicated search action
- Make sure your `QUANT_TOKEN` is stored securely in your repository secrets

## License

MIT License
