locals {
  azs = ["us-east-1a", "us-east-1b"]

  public_subnets = [
    {
      name = "public-1"
      cidr = "10.0.1.0/24"
      az   = local.azs[0]
    }
  ]

  private_subnets = [
    {
      name = "private-1"
      cidr = "10.0.2.0/24"
      az   = local.azs[1]
    }
  ]
}

