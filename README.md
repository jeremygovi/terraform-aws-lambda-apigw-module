# aws-lambda-apigw-terraform-module

Terraform module to deploy nodejs/python/go webapp to AWS Lambda fronted by API Gateway

```diff
- /!\ This module is not maintained anymore. This is a very simple module with basic features. 
- For more complex needs, see: 
```
https://github.com/OpenClassrooms/terraform-aws-lambda-apigw-module

## How to use


### Create and setup a new project direcory

```
mkdir -p helloworld-app
cd helloworld-app
```

### Create a `main.js` file (or any other name/languages according to your needs, see [supported lambda runtimes](https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtimes.html))

Here is an example code you can put in the file:

```
'use strict'

exports.handler = function (event, context, callback) {
  var response = {
    statusCode: 200,
    headers: {
      'Content-Type': 'text/html; charset=utf-8',
    },
    body: '<p>Bonjour !!!</p>',
  }
  callback(null, response)
}
```


### Create a `main.tf` file containing the following:


```hcl
module "lambda-apigw-module" {
  source  = "jeremygovi/lambda-apigw-module/aws"
  version = "0.0.2"
  project_name          = "helloworld-app"
  source_path           = "./main.js"
  lambda_function_name  = "my_lambda_function_name"
  lambda_runtime        = "nodejs10.x"
  api_gateway_name      = "helloworld-app-api-gw"

  environment_variables = {
    customEnvVariable = "prod"
  }

}
```

### Add an `outputs.tf` to display quickly the base URL of the fresh deployed API Gateway. It looks like this:

```hcl
output "api_gw_url" {
  description = "The API Gateway URL to call"
  value       = module.lambda-apigw-module.api_gw_url
}

```

### Run terraform

```
terraform init
terraform plan
terraform apply
```

Then, go the generated URL displayed in the terraform output.

## BONUS: CI/CD

To automate all of this, you can do it with github actions:

## Configure AWS Credentials

Go to the github repo settings and create secrets for `AWS_ACCESS_KEY_ID`and `AWS_SECRET_ACCESS_KEY`

## Let terraform use a non local tfstate file.

Create a `backend.tf` file containing the following:

```hcl
terraform {
  backend "s3" {
    bucket = "mybucket"
    key    = "path/to/my/key"
    region = "eu-west-3"
  }
}
```

## Configure github actions

Create a `.github/workflows/terraform.yml` file in your github project, containing the following:

```hcl
name: 'Terraform'

on:
  push:
    branches:
    - master
  pull_request:

jobs:
  terraform:
    name: 'Terraform'
    runs-on: ubuntu-latest

    # Use the Bash shell regardless whether the GitHub Actions runner is ubuntu-latest, macos-latest, or windows-latest
    defaults:
      run:
        shell: bash
    env:
      GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }} 
      AWS_DEFAULT_REGION: eu-west-3
      AWS_ACCESS_KEY_ID:  ${{ secrets.AWS_ACCESS_KEY_ID }}
      AWS_SECRET_ACCESS_KEY:  ${{ secrets.AWS_SECRET_ACCESS_KEY }}

    steps:
    # Checkout the repository to the GitHub Actions runner
    - name: Checkout
      uses: actions/checkout@v2
    
    - name: Terraform fmt
      uses: dflook/terraform-fmt-check@v1
      with:
        path: .
    
    - name: Terraform plan
      uses: dflook/terraform-plan@v1
      with:
        path: .

    # On push to master, build or change infrastructure according to Terraform configuration files
    - name: Terraform Apply
      if: github.ref == 'refs/heads/master' && github.event_name == 'push'
      uses: dflook/terraform-apply@v1
      with:
        path: .
```

This pipeline will do a terraform fmt/plan for every push on master and pull requests. Apply will be done only on master changes.

Of course, you can adapt it for your needs :-)



