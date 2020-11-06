# aws-lambda-apigw-terraform-module

Terraform module to deploy nodejs/python/go webapp to AWS Lambda fronted by API Gateway

## How to use

### Create and setup a new project direcory/repo

```
mkdir -p helloworld-app
cd helloworld-app
```

### create a `main.js` file (or any other name according to your needs)

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


### create a ```main.tf``` file containing the following:


```hcl
module "hello-world-app" {
  source                = "github.com/jeremyjgov/aws-lambda-apigw-terraform-module"
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

### Run terraform

```
terraform init
terraform plan
terraform apply
```
