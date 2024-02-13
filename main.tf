module "eu-west-1" {
  source = "./modules/infra"

  vpc-cidr      = "10.11.10.0/24"
  subnet-cidr-a = "10.11.10.0/27"
  subnet-cidr-b = "10.11.10.32/27"
  subnet-cidr-c = "10.11.10.64/27"
  subnet-cidr-d = "10.11.10.128/27"
  ami-name      = "ami-0766b4b472db7e3b9"

  providers = {
    aws.region = aws.eu-west-1
  }
}

# module "eu-west-3" {
#   source = "./modules/infra"

#   vpc-cidr      = "10.10.10.0/24"
#   subnet-cidr-a = "10.10.10.0/27"
#   subnet-cidr-b = "10.10.10.32/27"
#   subnet-cidr-c = "10.10.10.64/27"

#   providers = {
#     aws.region = aws.eu-west-1
#   }
# }