# QuantCDN Deploy

Deploy projects to QuantCDN using Github Actions.

## Getting Started

To get started using the action make sure you have the standard workflow structure set up (.github/workflows) create a file called `deploy.yml` with the following contents.

```
name: Deploy to QuantCDN
on:
  push:
    branches:
      - master
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      # Build the artefact or restore a cached copy.
      # - name: Build the deploy artefact
      #   run: npm run build
      - uses: quantcdn/deploy-action@v1.0.1
        with:
          customer: <quant-customer-id>
          project: <quant-project-id>
          token: ${{ secrets.QUANT_TOKEN }}
          dir: <build>
          skip-unpublish: true

```

Replace the placeholders with values for your project, these can be found in the [Quant dashboard](https://docs.quantcdn.io/docs/dashboard).

## Adding secrets

Navigate to your repositories Settings page and find **Secrets**. Once there click on new secret, enter **QUANT_TOKEN** as the secret name and paste your provided Quant API token.

You can learn more about [secrets](https://docs.github.com/en/actions/reference/encrypted-secrets) and [actions](https://docs.github.com/en/actions).

## Inputs

```
customer:
  description: "Your customer account name"
  required: true
project:
  description: "Your project name"
  required: true
token:
  description: "Your API token"
  required: true
dir:
  description: "The directory to deploy"
  required: true
skip-unpublish:
  description: 'Skip automatic unpublishing of assets'
  required: false
  default: false
skip-purge:
  description: 'Skip automatic purge of cached assets in CDN'
  required: false
  default: false
chunk-size:
  description: 'Alter the concurrency of deployment'
  required: false
  default: 10
```
