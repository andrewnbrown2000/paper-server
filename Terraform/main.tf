terraform { 
  cloud { 
    organization = "andrewnbrown" 
    workspaces { 
      name = "paper_server_infrastructure" 
    } 
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.67.0"
    }
  }
}

provider "aws" {
  region = var.region
}

#security group
resource "aws_security_group" "paper_sg" {
  name        = "paper-sg"

  ingress { #ssh
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { #minecraft server port
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { #just for instance connect 
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    prefix_list_ids = ["pl-0e99958a47b22d6ab"] #AWS prefix list id for ec2 instances in us-west-1
  }

  egress { #allows all outbout traffic of any type
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#ec2
resource "aws_instance" "paper_server" {
  ami                    = var.ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.paper_sg.id] # Reference the security group

  tags = {
    Name = "paper_server_from_terraform"
  }
}

#s3 bucket and permission settings
resource "random_pet" "lambda_bucket_name" { #basically rng name generator
  prefix = "lambda-bucket"
  length = 4
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = random_pet.lambda_bucket_name.id #append the rng name to the bucket name
}

resource "aws_s3_bucket_ownership_controls" "lambda_bucket" {
  bucket = aws_s3_bucket.lambda_bucket.id #fetch the bucket id created above
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "lambda_bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.lambda_bucket] #not sure this is even necessary since tf should infer

  bucket = aws_s3_bucket.lambda_bucket.id
  acl    = "private"
}

data "archive_file" "lambda_ec2_starter" { #create archive format file for putting in s3
  type = "zip"

  source_dir = "${path.module}/scripts"
  output_path = "${path.module}/scripts.zip"
}

resource "aws_s3_object" "lambda_ec2_starter" {
  bucket = aws_s3_bucket.lambda_bucket.id

  source = data.archive_file.lambda_ec2_starter.output_path #local path to archive format file
  key    = "paper_boot_lambda_function.zip" #name of file in the source (path)

  etag = filemd5(data.archive_file.lambda_ec2_starter.output_path) #creates a hash of the file for verification? something like that
}

#lambda
resource "aws_lambda_function" "paper_boot" {
  function_name = "paper_boot"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_ec2_starter.key

  runtime = "python3.9"
  handler = "ec2_launch_ondemand_w_dnsmapping.lambda_handler"

  source_code_hash = data.archive_file.lambda_ec2_starter.output_base64sha256

  role = aws_iam_role.lambda_exec.arn

  timeout = 120 #timeout set to 2 minutes (120 seconds)

  environment {
    variables = {
      #pass in as an environment variables
      INSTANCE_ID = aws_instance.paper_server.id
      REGION = var.region
    }
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_ec2_access" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_route53_access" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

#HTTP api
resource "aws_apigatewayv2_api" "lambda" {
  name          = "lambda_gw"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "paper_boot" {
  api_id = aws_apigatewayv2_api.lambda.id

  integration_uri    = aws_lambda_function.paper_boot.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "paper_boot" {
  api_id = aws_apigatewayv2_api.lambda.id

  route_key = "GET /{proxy+}" #should handle any GET request (i.e. clicking the url)
  target    = "integrations/${aws_apigatewayv2_integration.paper_boot.id}"
}

resource "aws_apigatewayv2_stage" "default" { #only required from tf, not from aws console. whatever
  api_id = aws_apigatewayv2_api.lambda.id
  name   = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.paper_boot.function_name
  principal     = "apigateway.amazonaws.com" #entity performing the action is gw NOT lambda

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}
