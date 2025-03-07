# Paper Server Deployment with AWS and Terraform

## Overview

This project aims to compete with Microsoft's Minecraft Realms service and other Minecraft hosting services by providing an easy and cost-effective deployment solution for Minecraft servers. The architecture is designed to support servers of any player volume using AWS cloud infrastructure and Terraform for deployment.

## Features

- **Cost-Effective**: The server architecture is designed to boot on-demand, reducing costs by only running when needed.
- **Easy Deployment**: A Terraform module is provided to deploy the preconfigured architecture to any AWS account.
- **On-Demand Server Start**: Users can start the server via an API call, and the server address will be provided as a response, visible in the browser.

## Architecture

The project leverages AWS services and Terraform to create a scalable and cost-effective solution. The key components include:

- **AWS EC2**: For running the Minecraft server.
- **AWS Lambda**: For handling the on-demand server start.
- **AWS API Gateway**: For providing an API endpoint to start the server.
- **AWS S3**: For storing the Lambda function code.
- **Terraform**: For infrastructure as code, making deployment easy and repeatable.

## Future Plans

If the project gains popularity, future improvements will include:

- **Enhanced User Experience**: Making the deployment process less confusing for beginners.
- **Domain Support**: Providing a separate script for users who already own a domain.
- **YouTube Tutorial**: Creating a YouTube tutorial for setting up the project.

## Getting Started

To deploy the server, follow these steps:

1. **Clone the Repository**: Clone this repository to your local machine.
2. **Create an AWS Account**: Create an AWS account and generate an access key with admin role permissions.
3. **Install Terraform**: Download and install Terraform from [terraform.io](https://www.terraform.io/downloads.html).
4. **Configure AWS Credentials**: Configure your AWS credentials on your local machine.
5. **Modify Variables**: Change the variables in the Terraform files to suit your needs.
6. **Deploy with Terraform**: Run the Terraform module to deploy the architecture.
   ```sh
   terraform init
   terraform apply
   ```
7. **Start the Server**: Use the provided API endpoint to start the server.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.

## License

This project is licensed under the MIT License

## Contact

For any questions or support, please contact andrewbrown.n2000@gmail.com (or comment on YouTube video)
