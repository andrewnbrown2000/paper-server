variable "region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-west-1"         #change to us-east-1 if you are in the east coast
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
    default     = "ami-0844c1660a272290f" #later can build different configs of paper/minecraft servers
}