variable "region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-east-1"         #change to us-east-1 if you are in the east coast
}

variable "instance_type" {
    description = "The type of instance to use for the server"
    type        = string
    default     = "t4g.medium"  #medium should work for 2-3 players. 
                                #if you have more consider changing to a larger size 
                                #(i.e. t4g.large, t4g.xlarge, etc)

                                #warning, bigger size = more money
                                #see https://aws.amazon.com/ec2/pricing/on-demand/
}

variable "ami" {
    description = "The AMI to use for the server"
    type        = string
    default     = "ami-0293e1152bc276de0" #Amazon Linux 2 ARM64 AMI for us-east-1
}

variable "instance_name" {
    description = "The name tag for the EC2 instance"
    type        = string
    default     = "paper-with-foof"  #default name, can be overridden
}

variable "ec2_instance_connect_prefix_list_id" {
    description = "The prefix list ID for EC2 Instance Connect in the specified region"
    type        = string
    default     = "pl-0e4bcff02b13bef1e"  #EC2 Instance Connect prefix list for us-east-1
                                          #us-west-1: pl-0e99958a47b22d6ab
                                          #us-west-2: pl-0ba236e1ec84c6094
                                          #eu-west-1: pl-034d1e7b6a7096b1e
}