# Deploy to QuantCDN Action

This GitHub Action deploys your static site or assets to QuantCDN using the Quant CLI v5.

## Usage

```yaml
- uses: quantcdn/action-deploy@v5
  with:
    customer: your-customer-id
    project: your-project-name
    token: ${{ secrets.QUANT_TOKEN }}
    dir: build
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `customer` | Your QuantCDN customer account name | Yes | - |
| `project` | Your QuantCDN project name | Yes | - |
| `token` | Your QuantCDN API token | Yes | - |
| `dir` | The directory to deploy | Yes | - |
| `skip-unpublish` | Skip automatic unpublishing of assets | No | `false` |
| `skip-unpublish-regex` | Skip automatic unpublishing of assets matching regex pattern | No | - |
| `skip-purge` | Skip automatic purge of cached assets in CDN | No | `false` |
| `force` | Force the deployment of assets (skip md5 check) | No | `false` |
| `chunk-size` | Alter the concurrency of deployment | No | `10` |
| `endpoint` | Specify the QuantCDN API endpoint | No | `https://api.quantcdn.io/v1` |
| `revision-log` | Specify a location for the local revision log file | No | `false` |
| `enable-index-html` | Enable index.html creation in Quant | No | `false` |
| `functions` | JSON array of functions to deploy. Each object should contain: type (auth|filter|edge), description, path, and uuid | No | - |
| `functions-file` | Path to JSON file containing functions configuration | No | - |

## Example Workflows

### Basic Deployment

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

### Advanced Deployment

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
          skip-unpublish: false
          chunk-size: 20
          force: true
```

### Multiple Functions Deployment Example

```yaml
name: Deploy to QuantCDN with Multiple Functions
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
          functions: |
            [
              {
                "type": "auth",
                "path": "./functions/auth.js",
                "description": "Custom authentication function",
                "uuid": "019361ae-2516-788a-8f50-e803ff561c34"
              },
              {
                "type": "edge",
                "path": "./functions/edge.js",
                "description": "Custom edge function",
                "uuid": "019361ae-2516-788a-8f50-e803ff561c35"
              },
              {
                "type": "filter",
                "path": "./functions/filter.js",
                "description": "Custom filter function",
                "uuid": "019361ae-2516-788a-8f50-e803ff561c36"
              }
            ]
```

The `functions` input accepts a JSON array where each object must contain:
- `type`: Either "auth", "filter", or "edge"
- `path`: Path to the function file (e.g., "./functions/auth.js")
- `description`: Description of the function
- `uuid`: Valid UUID for the function

Functions will automatically be deployed to `/fn/{uuid}`.

### Functions Configuration

You can configure functions either directly in the workflow or via a JSON file:

#### Option 1: Direct Configuration

```yaml
      - name: Deploy to QuantCDN
        uses: quantcdn/action-deploy@v5
        with:
          customer: your-customer-id
          project: your-project-name
          token: ${{ secrets.QUANT_TOKEN }}
          dir: build
          functions: |
            [
              {
                "type": "auth",
                "path": "./functions/auth.js",
                "description": "Custom authentication function",
                "uuid": "019361ae-2516-788a-8f50-e803ff561c34"
              }
            ]
```

#### Option 2: JSON File Configuration

Create a JSON file (e.g., `functions.json`):
```json
[
  {
    "type": "auth",
    "path": "./functions/auth.js",
    "description": "Custom authentication function",
    "uuid": "019361ae-2516-788a-8f50-e803ff561c34"
  },
  {
    "type": "edge",
    "path": "./functions/edge.js",
    "description": "Custom edge function",
    "uuid": "019361ae-2516-788a-8f50-e803ff561c35"
  }
]
```

Then reference it in your workflow:
```yaml
      - name: Deploy to QuantCDN
        uses: quantcdn/action-deploy@v5
        with:
          customer: your-customer-id
          project: your-project-name
          token: ${{ secrets.QUANT_TOKEN }}
          dir: build
          functions-file: './functions.json'
```

The function configuration requires:
- `type`: Either "auth", "filter", or "edge"
- `path`: Path to the function file (e.g., "./functions/auth.js")
- `description`: Description of the function
- `uuid`: Valid UUID for the function

Functions will automatically be deployed to `/fn/{uuid}`.

## Notes

- This action uses Quant CLI v5
- For search functionality, please use the dedicated search action
- Make sure your `QUANT_TOKEN` is stored securely in your repository secrets

## License

MIT License
