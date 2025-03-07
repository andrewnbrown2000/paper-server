output "public_dns" {                           # this is just for testing. in the deployed state this
  value = aws_instance.paper_server.public_dns  # information is passed to the user from the api call
}

output "api_gateway_url" {                    # share this with users. a link to launch the server
  value = "${aws_apigatewayv2_api.lambda.api_endpoint}/"
}