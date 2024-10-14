terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket         = "s3dumb-frontend-host-terraform-state-dynamodb"
    key            = "terraform/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "s3dumb-frontend-host-running-locks"
  }
}

provider "aws" {
  region = "us-east-1"
}

locals {
  lambdas = {
    "api/v1/hello" = {
      name = "serverless_lambda"
      handler = "main.handler"
      path = "${path.cwd}/go-al2/hello-world"
      key = "hello-world.zip"
      env = "dev"
    }
  }
}

module "aws_lambda" {
  source = "./modules/lambda"
  for_each = local.lambdas
  bucket_name = "s3lambda-helloworld-dev"
  name = each.value.name
  handler = each.value.name
  path = each.value.path
  key = each.value.key
  env = each.value.env
}

module "api_gateway" {
  source = "./modules/api_gateway"
  name = "serverless_http_api"
  env = "dev"
  lambda_arn = module.aws_lambda["api/v1/hello"].arn
  function_name = module.aws_lambda["api/v1/hello"].function_name
}
