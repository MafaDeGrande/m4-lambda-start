locals {
  name = "${var.name}-${var.env}"
  tags = {
    Name = var.name
    Env  = var.env
  }
}

module "api_gateway" {
  source = "terraform-aws-modules/apigateway-v2/aws"
  
  name = local.name 
  protocol_type = "HTTP" 

  # Disable creation of the domain name and API mapping
  create_domain_name = false

  # Disable creation of Route53 alias record(s) for the custom domain
  create_domain_records = false

  routes = {
    "POST /api/v1/hello" = {
      integration = {
        uri                    = var.lambda_arn
        type                   = "AWS_PROXY"
        payload_format_version = "2.0"
        timeout_milliseconds   = 12000
      }
    }
    "$default" = {
      integration = {
        uri = var.lambda_arn
      }
    }
  }

  tags = local.tags
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id = "AllowExecutionFromAPIGateway"
  action = "lambda:InvokeFunction"
  function_name = var.function_name
  principal = "apigateway.amazonaws.com"
  source_arn = "${module.api_gateway.api_execution_arn}/*"
}
