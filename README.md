# aws-lambda-apigw-terraform-module

Terraform module to deploy nodejs/python/go webapp to AWS Lambda fronted by API Gateway

## How to use

Best practices consists for example in :

+ Configuring tfstate to be in a S3 bucket

+ Versioning the code in a repository

+ Creating github actions or trigger a jenkins job to run a CI/CD pipeline

However, we will keep it simple, creating only a directory.


### Create and setup a new project direcory

```
mkdir -p helloworld-app
cd helloworld-app
```

### Create a `main.js` file (or any other name according to your needs)

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


