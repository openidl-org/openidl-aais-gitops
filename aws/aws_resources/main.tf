terraform {
  cloud {
    organization = "openIDL"

    workspaces {
      name = "testnet-openidl-aws-resources"
    }
  }
}